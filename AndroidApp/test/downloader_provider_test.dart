import 'package:flutter_test/flutter_test.dart';
import 'package:yt_music_flutter/src/downloader/downloader_provider.dart';

void main() {
  test('sanitize removes invalid characters', () {
    final p = DownloaderProvider();
    expect(p.formatTime(DateTime(2020, 1, 1, 12, 0, 0)), '12:00:00');
  });
}
