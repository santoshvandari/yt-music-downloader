import os
from pytubefix import YouTube, Playlist
from moviepy import AudioFileClip

def download_and_convert(video_url, out_folder):
    try:
        yt = YouTube(video_url)
        print(f"🎵 Downloading: {yt.title}")
        audio_stream = yt.streams.filter(only_audio=True).first()
        downloaded_path = audio_stream.download(output_path=out_folder)
        base, _ = os.path.splitext(downloaded_path)
        mp3_path = base + '.mp3'
        with AudioFileClip(downloaded_path) as audio_clip:
            audio_clip.write_audiofile(mp3_path, bitrate="320k")
        os.remove(downloaded_path)
        print(f"Done: {yt.title}\n")
    except Exception as e:
        print(f"Error downloading {video_url}: {e}")

def process_playlist(playlist_url, out_folder):
    try:
        pl = Playlist(playlist_url)
        print(f"📋 Found {len(pl.video_urls)} videos in playlist.")
        for url in pl.video_urls:
            download_and_convert(url, out_folder)
    except Exception as e:
        print(f"Error processing playlist: {e}")

if __name__ == "__main__":
    url = input("Enter YouTube video or playlist URL: ").strip()
    out_folder = input("Enter output folder (default: downloads): ").strip() or "downloads"
    os.makedirs(out_folder, exist_ok=True)

    if not url.startswith("http"):
        print("Please enter a valid YouTube URL.")
        exit()

    if "playlist" in url or "list=" in url:
        process_playlist(url, out_folder)
    else:
        download_and_convert(url, out_folder)
