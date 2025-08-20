import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
        // Request storage permissions first
        await _requestStoragePermissions();
        
        // Try to use app-specific external storage directory (doesn't require permissions)
        final ext = await getExternalStorageDirectory();
        if (ext != null) {
          // Create a Music folder in the app's external directory
          base = Directory(p.join(ext.path, 'Music'));
        } else {
          // Fallback to app documents directory
          base = await getApplicationDocumentsDirectory();
        }
      } else {
        base = await getDownloadsDirectory();
      }
    } catch (e) {
      _log('Error setting up directory: $e');
    }

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
    outputDir = Directory(base.path);
    try { 
      if (!await outputDir!.exists()) { 
        await outputDir!.create(recursive: true); 
      } 
    } catch (e) {
      _log('Error creating directory: $e');
    }
    notifyListeners();
  }

  Future<void> _requestStoragePermissions() async {
    if (!Platform.isAndroid) return;
    
    try {
      // For Android 13+ (API 33+), request READ_MEDIA_AUDIO
      if (await Permission.audio.isDenied) {
        await Permission.audio.request();
      }
      
      // For older Android versions, request storage permissions
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    } catch (e) {
      _log('Permission request error: $e');
    }
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

  Future<bool> checkPermissions() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // Check if we have the necessary permissions
      final audioPermission = await Permission.audio.status;
      final storagePermission = await Permission.storage.status;
      
      _log('Audio permission: $audioPermission');
      _log('Storage permission: $storagePermission');
      
      return audioPermission.isGranted || storagePermission.isGranted;
    } catch (e) {
      _log('Permission check error: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;
    
    try {
      await _requestStoragePermissions();
      return await checkPermissions();
    } catch (e) {
      _log('Permission request failed: $e');
      return false;
    }
  }

  Future<void> start() async {
    if (url.isEmpty || outputDir == null || isBusy) return;
    _stop = false;
    clearProgress();

    try {
      // Check permissions first on Android
      if (Platform.isAndroid) {
        statusText = 'Checking permissions...';
        state = DownloadState.fetching;
        notifyListeners();
        
        final hasPermissions = await checkPermissions();
        if (!hasPermissions) {
          _log('Requesting storage permissions...');
          final granted = await requestPermissions();
          if (!granted) {
            throw Exception('Storage permissions are required to download files. Please grant permissions in app settings.');
          }
        }
      }

      statusText = 'Fetching info...';
      state = DownloadState.fetching;
      notifyListeners();

      final kind = classifyUrl(url);
      if (kind.isPlaylist) {
        try {
          // Resolve playlist by ID or URL
          final pl = kind.playlistId != null
              ? await yt.playlists.get(PlaylistId(kind.playlistId!))
              : await yt.playlists.get(url);

          _log('Found playlist: ${pl.title}');
          
          // Stream videos and collect to list to show total count
          final videos = <Video>[];
          await for (final video in yt.playlists.getVideos(pl.id)) {
            if (_stop) throw _Stopped();
            videos.add(video);
            // Update count as we discover videos
            totalFilesText = 'Playlist: ${videos.length} videos (discovering...)';
            notifyListeners();
          }
          
          totalFilesText = 'Playlist: ${videos.length} videos';
          _log('Playlist contains ${videos.length} videos');
          notifyListeners();
          
          int i = 0;
          for (final v in videos) {
            if (_stop) throw _Stopped();
            i++;
            try {
              await _downloadVideo(v, index: i, total: videos.length);
            } catch (e) {
              _log('Failed to download "${v.title}": $e');
              // Continue with next video instead of stopping entire playlist
              continue;
            }
          }
        } catch (e) {
          _log('Playlist error: $e');
          throw e;
        }
      } else {
        totalFilesText = 'Single video';
        final video = kind.videoId != null
            ? await yt.videos.get(VideoId(kind.videoId!))
            : await yt.videos.get(url);
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

  // Simple URL classifier to better detect playlists and extract IDs
  @visibleForTesting
  UrlKind classifyUrl(String input) {
    try {
      final u = Uri.parse(input);
      final host = u.host.toLowerCase();
      final listParam = u.queryParameters['list'];
      if (listParam != null && listParam.isNotEmpty) {
        // Any URL with list= should be treated as playlist
        return UrlKind(isPlaylist: true, playlistId: listParam);
      }
      // Dedicated playlist path
      if (host.contains('youtube.com') && u.path.contains('playlist')) {
        return UrlKind(isPlaylist: true);
      }
      // Video-only forms
      String? vid;
      if (host.contains('youtu.be')) {
        // youtu.be/<id>
        final seg = u.pathSegments.isNotEmpty ? u.pathSegments.first : null;
        if (seg != null && seg.isNotEmpty) vid = seg;
      } else if (host.contains('youtube.com') && u.path.contains('/watch')) {
        vid = u.queryParameters['v'];
      }
      return UrlKind(isPlaylist: false, videoId: vid);
    } catch (_) {
      // Fallback: basic heuristic
      if (input.contains('list=')) return UrlKind(isPlaylist: true);
      return UrlKind(isPlaylist: false);
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
    if (outputDir == null) {
      throw Exception('Output directory not set');
    }
    
    currentTitle = video.title;
    if (index != null && total != null) {
      currentTitle = '${video.title} ($index/$total)';
    }
    _log('Starting download: ${video.title}');

    try {
      // Get audio stream (highest bitrate)
      final manifest = await yt.videos.streamsClient.getManifest(video.id);
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) {
        throw Exception('No audio streams available for this video');
      }
      
      final audio = audioStreams.withHighestBitrate();
      final totalSize = audio.size.totalBytes;
      _log('File size: ${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB');

      // Prepare file with better error handling
      final sanitizedTitle = sanitize(video.title);
      final tempPath = p.join(outputDir!.path, '$sanitizedTitle.${audio.container.name}');
      
      // Ensure directory exists
      final dir = Directory(p.dirname(tempPath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final outFile = File(tempPath);
      if (await outFile.exists()) {
        await outFile.delete();
      }
      
      // Test write permissions
      try {
        final testFile = File(p.join(outputDir!.path, '.test_write'));
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        throw Exception('No write permission to output directory: $e');
      }
      
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

      // Verify file was written successfully
      if (!await outFile.exists()) {
        throw Exception('Failed to save file - file does not exist after download');
      }
      
      final actualSize = await outFile.length();
      if (actualSize == 0) {
        throw Exception('Downloaded file is empty');
      }
      
      _log('Download completed, file size: ${(actualSize / (1024 * 1024)).toStringAsFixed(1)} MB');

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
        try { 
          await File(tempPath).delete(); 
          _log('Converted to MP3 successfully');
        } catch (_) {}
      } else {
        // Fallback: simple copy to .mp3 if transcoding not available/failed
        try {
          await File(tempPath).copy(mp3Path);
          await File(tempPath).delete();
          _log('Saved as MP3 (container copy)');
        } catch (e) {
          _log('Conversion fallback failed, keeping original: $e');
          // Keep the original file if copy fails
        }
      }

      state = DownloadState.completed;
      progress = 100;
      speedText = 'Completed';
      etaText = 'Done';
      _log('Completed: ${video.title}');
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      
    } catch (e) {
      _log('Download failed for "${video.title}": $e');
      rethrow;
    }
  }

  @visibleForTesting
  String sanitize(String s) {
    return s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  String formatTime(DateTime t) => DateFormat.Hms().format(t);
}

class _Stopped implements Exception {}

@visibleForTesting
class UrlKind {
  final bool isPlaylist;
  final String? playlistId;
  final String? videoId;
  UrlKind({required this.isPlaylist, this.playlistId, this.videoId});
}
