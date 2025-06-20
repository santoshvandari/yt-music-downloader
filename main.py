from pytubefix import YouTube, Playlist
from moviepy import AudioFileClip
import os

def download_and_convert(video_url, out_folder):
    yt = YouTube(video_url)
    print(f"Downloading: {yt.title}")
    audio_stream = yt.streams.filter(only_audio=True).first()
    downloaded_path = audio_stream.download(output_path=out_folder)
    base, _ = os.path.splitext(downloaded_path)
    mp3_path = base + '.mp3'
    with AudioFileClip(downloaded_path) as audio_clip:
        audio_clip.write_audiofile(mp3_path, bitrate="320k")
    os.remove(downloaded_path)
    print("Done.")

def process_playlist(playlist_url, out_folder):
    pl = Playlist(playlist_url)
    print(f"Found {len(pl.video_urls)} videos in playlist")
    for url in pl.video_urls:
        download_and_convert(url, out_folder)

if __name__ == "__main__":
    # import argparse
    # parser = argparse.ArgumentParser(description="Download YouTube video(s) as high‑quality MP3.")
    # parser.add_argument("url", help="YouTube video or playlist URL")
    # parser.add_argument("--out", default="downloads", help="Output folder (default: downloads)")
    # args = parser.parse_args()

    url = input("Enter YouTube video or playlist URL: ")
    out_folder = input("Enter output folder (default: downloads): ") or "downloads"
    os.makedirs(out_folder, exist_ok=True)

    # Determine if it's a playlist
    if "playlist" in url or "list=" in url:
        process_playlist(url, out_folder)
    else:
        download_and_convert(url, out_folder)
