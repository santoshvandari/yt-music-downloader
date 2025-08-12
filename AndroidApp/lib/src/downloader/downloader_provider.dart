import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// Only used on Android; safe to import cross-platform
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart' as dp28;

class DownloadLogEntry {
  final DateTime time;
  final String message;
  DownloadLogEntry(this.time, this.message);
}

enum DownloadState { idle, fetching, downloading, converting, completed, error, stopped }

class DownloaderProvider extends ChangeNotifier {
  final yt = YoutubeExplode();

  String url = '';
  Directory? outputDir;
  DownloadState state = DownloadState.idle;
  double progress = 0; // 0-100
  String speedText = '';
  String etaText = '';
  String statusText = 'Ready to download';
  String currentTitle = '';
  String totalFilesText = '';
  final List<DownloadLogEntry> logs = [];

  // internals
  bool _stop = false;
  int _lastBytes = 0;
  DateTime _lastTime = DateTime.now();

  DownloaderProvider() {
  _initDefaultDir();
  }

  Future<void> _initDefaultDir() async {
    Directory? base;
    try {
      if (Platform.isAndroid) {
        // Use public Downloads on Android
        final dir = await dp28.DownloadsPathProvider.downloadsDirectory;
        if (dir != null) base = Directory(dir.path);
      } else {
        base = await getDownloadsDirectory();
      }
    } catch (_) {}

    if (base == null) {
      // Fallback by platform
      try {
        if (Platform.isWindows) {
          final home = Platform.environment['USERPROFILE'];
          if (home != null) base = Directory(p.join(home, 'Downloads'));
        } else {
          final home = Platform.environment['HOME'];
          if (home != null) base = Directory(p.join(home, 'Downloads'));
        }
      } catch (_) {}
    }

    base ??= Directory.systemTemp;
    outputDir = Directory(p.join(base.path, 'yt-music-downloads'));
    try { if (!await outputDir!.exists()) { await outputDir!.create(recursive: true); } } catch (_) {}
    notifyListeners();
  }

  void setUrl(String v) {
    url = v.trim();
    notifyListeners();
  }

  void setOutputDir(Directory dir) {
    outputDir = dir;
    notifyListeners();
  }

  void clearLogs() {
    logs.clear();
    notifyListeners();
  }

  void _log(String msg) {
    logs.add(DownloadLogEntry(DateTime.now(), msg));
    notifyListeners();
  }

  void stop() {
    _stop = true;
    statusText = 'Stopping...';
    state = DownloadState.stopped;
    notifyListeners();
  }

  bool get isBusy =>
      state == DownloadState.fetching || state == DownloadState.downloading || state == DownloadState.converting;

  Future<void> start() async {
    if (url.isEmpty || outputDir == null || isBusy) return;
    _stop = false;
    clearProgress();

    try {
      statusText = 'Fetching info...';
      state = DownloadState.fetching;
      notifyListeners();

      if (url.contains('list=')) {
        // Playlist
        final playlist = await yt.playlists.get(url);
        final videos = await yt.playlists.getVideos(playlist.id).toList();
        totalFilesText = 'Playlist: ${videos.length} videos';
        _log('Found playlist: ${playlist.title} (${videos.length} videos)');
        int i = 0;
        for (final v in videos) {
          if (_stop) throw _Stopped();
          i++;
          await _downloadVideo(v, index: i, total: videos.length);
        }
      } else {
        totalFilesText = 'Single video';
        final video = await yt.videos.get(url);
        await _downloadVideo(video);
      }

      if (_stop) throw _Stopped();
      state = DownloadState.completed;
      statusText = 'All downloads completed!';
      _log('All downloads finished successfully!');
    } on _Stopped {
      state = DownloadState.stopped;
      statusText = 'Stopped';
      _log('Stopped by user');
    } catch (e) {
      state = DownloadState.error;
      statusText = 'Download failed';
      _log('Error: $e');
    } finally {
      progress = progress == 0 ? 0 : 100;
      notifyListeners();
    }
  }

  void clearProgress() {
    progress = 0;
    speedText = '';
    etaText = '';
    currentTitle = '';
    statusText = 'Ready to download';
    state = DownloadState.idle;
    notifyListeners();
  }

  Future<void> _downloadVideo(Video video, {int? index, int? total}) async {
    if (outputDir == null) return;
    currentTitle = video.title;
    if (index != null && total != null) {
      currentTitle = '${video.title} ($index/$total)';
    }
    _log('Found: ${video.title}');

    // Get audio stream (highest bitrate)
    final manifest = await yt.videos.streamsClient.getManifest(video.id);
    final audio = manifest.audioOnly.withHighestBitrate();
    final totalSize = audio.size.totalBytes;
    _log('File size: ${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB');

    // Prepare file
    final sanitizedTitle = _sanitize(video.title);
    final tempPath = p.join(outputDir!.path, '$sanitizedTitle.${audio.container.name}');
    final outFile = File(tempPath);
    if (await outFile.exists()) await outFile.delete();
    final sink = outFile.openWrite();

    // Download
    state = DownloadState.downloading;
    statusText = 'Downloading audio stream...';
    progress = 0;
    _lastBytes = 0;
    _lastTime = DateTime.now();
    notifyListeners();

    final stream = yt.videos.streamsClient.get(audio);
    int received = 0;
    await for (final chunk in stream) {
      if (_stop) {
        await sink.close();
        try { await outFile.delete(); } catch (_) {}
        throw _Stopped();
      }
      sink.add(chunk);
      received += chunk.length;
      final now = DateTime.now();
      final dt = now.difference(_lastTime).inMilliseconds;
      if (dt >= 500) {
        final db = received - _lastBytes;
        final speed = db / (dt / 1000.0); // bytes/s
        final mbps = speed / (1024 * 1024);
        speedText = 'Speed: ${mbps.toStringAsFixed(1)} MB/s';
        final remaining = totalSize - received;
        final etaSec = speed > 0 ? (remaining / speed) : 0;
        final m = (etaSec ~/ 60).toString().padLeft(2, '0');
        final s = (etaSec % 60).toInt().toString().padLeft(2, '0');
        etaText = 'ETA: $m:$s';
        progress = (received / totalSize) * 100;
        _lastTime = now;
        _lastBytes = received;
        notifyListeners();
      }
    }

    await sink.close();

    // Finalizing step with ffmpeg transcode to MP3
    state = DownloadState.converting;
    statusText = 'Converting to MP3...';
    notifyListeners();

    final mp3Path = p.setExtension(tempPath, '.mp3');
    bool converted = false;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // No bundled FFmpeg on mobile in this build; we'll fall back below
        converted = false;
      } else {
        // Try system ffmpeg on desktop
        final result = await Process.run(
          'ffmpeg',
          ['-y', '-i', tempPath, '-b:a', '320k', mp3Path],
        );
        if (result.exitCode == 0) {
          converted = true;
        } else {
          _log('ffmpeg error: ${result.stderr}'.trim());
        }
      }
    } catch (e) {
      _log('Conversion error: $e');
    }
    if (converted) {
      try { await File(tempPath).delete(); } catch (_) {}
    } else {
      // Fallback: simple copy to .mp3 if transcoding not available/failed
      try {
        await File(tempPath).copy(mp3Path);
        await File(tempPath).delete();
        _log('Saved without transcoding (container copy)');
      } catch (_) {
        _log('Conversion fallback failed; kept original');
      }
    }

    state = DownloadState.completed;
    progress = 100;
    speedText = 'Completed';
    etaText = 'Done';
    _log('Completed: ${video.title}');
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  String _sanitize(String s) {
    return s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  String formatTime(DateTime t) => DateFormat.Hms().format(t);
}

class _Stopped implements Exception {}
