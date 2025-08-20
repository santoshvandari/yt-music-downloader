import 'package:flutter_test/flutter_test.dart';
import 'package:yt_music_downloader/src/downloader/downloader_provider.dart';

void main() {
  group('DownloaderProvider Tests', () {
    test('formatTime formats correctly', () {
      final p = DownloaderProvider();
      expect(p.formatTime(DateTime(2020, 1, 1, 12, 0, 0)), '12:00:00');
    });

    test('URL classification works for playlists', () {
      final p = DownloaderProvider();
      
      // Test playlist URLs
      final playlistUrl1 = 'https://www.youtube.com/playlist?list=PLrAXtmRdnEQy6nuLMt9xUCce3-QBvGr6h';
      final playlistUrl2 = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=PLrAXtmRdnEQy6nuLMt9xUCce3-QBvGr6h';
      
      // These should be detected as playlists
      final kind1 = p._classifyUrl(playlistUrl1);
      final kind2 = p._classifyUrl(playlistUrl2);
      
      expect(kind1.isPlaylist, true);
      expect(kind2.isPlaylist, true);
    });

    test('URL classification works for single videos', () {
      final p = DownloaderProvider();
      
      // Test single video URLs
      final videoUrl1 = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final videoUrl2 = 'https://youtu.be/dQw4w9WgXcQ';
      
      // These should be detected as single videos
      final kind1 = p._classifyUrl(videoUrl1);
      final kind2 = p._classifyUrl(videoUrl2);
      
      expect(kind1.isPlaylist, false);
      expect(kind2.isPlaylist, false);
      expect(kind1.videoId, 'dQw4w9WgXcQ');
      expect(kind2.videoId, 'dQw4w9WgXcQ');
    });

    test('sanitize removes invalid filename characters', () {
      final p = DownloaderProvider();
      
      final input = 'Test: Video | With "Invalid" Characters <>';
      final expected = 'Test_ Video _ With _Invalid_ Characters __';
      
      expect(p._sanitize(input), expected);
    });
  });
}
