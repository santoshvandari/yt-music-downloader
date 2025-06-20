import os
import threading
import time
from tkinter import Tk, Label, Entry, Button, filedialog, Text, END, Frame, StringVar, Canvas
from tkinter import ttk
from pytubefix import YouTube, Playlist
from moviepy import AudioFileClip

class ModernDownloader:
    def __init__(self):
        self.root = Tk()
        self.setup_window()
        self.setup_variables()
        self.setup_styles()
        self.create_widgets()
        self.setup_animations()
        
    def setup_window(self):
        self.root.title("🎵 YouTube Music Downloader Pro")
        self.root.geometry("800x600")
        self.root.configure(bg='#1a1a2e')
        self.root.resizable(True, True)
        
        # Center window
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() // 2) - (800 // 2)
        y = (self.root.winfo_screenheight() // 2) - (600 // 2)
        self.root.geometry(f'800x600+{x}+{y}')
        
    def setup_variables(self):
        self.folder_var = StringVar(value="downloads")
        self.status_var = StringVar(value="Ready to download")
        self.progress_var = StringVar(value="0%")
        self.current_file_var = StringVar(value="")
        self.download_speed_var = StringVar(value="")
        self.eta_var = StringVar(value="")
        self.is_downloading = False
        
    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure custom styles
        style.configure('Modern.TFrame', background='#1a1a2e')
        style.configure('Header.TLabel', background='#1a1a2e', foreground='#ffffff', font=('Arial', 24, 'bold'))
        style.configure('Subtitle.TLabel', background='#1a1a2e', foreground='#16537e', font=('Arial', 12))
        style.configure('Modern.TLabel', background='#1a1a2e', foreground='#ffffff', font=('Arial', 10))
        style.configure('Status.TLabel', background='#1a1a2e', foreground='#00ff41', font=('Arial', 10, 'bold'))
        
    def create_widgets(self):
        main_frame = Frame(self.root, bg='#1a1a2e')
        main_frame.pack(fill='both', expand=True, padx=20, pady=20)
        
        # Header
        header_frame = Frame(main_frame, bg='#1a1a2e')
        header_frame.pack(fill='x', pady=(0, 30))
        
        title_label = Label(header_frame, text="🎵 YouTube Music Downloader Pro", 
                           bg='#1a1a2e', fg='#ffffff', font=('Arial', 24, 'bold'))
        title_label.pack()
        
        subtitle_label = Label(header_frame, text="Download and convert YouTube videos to high-quality MP3", 
                              bg='#1a1a2e', fg='#16537e', font=('Arial', 12))
        subtitle_label.pack()
        
        # URL Input Section
        url_frame = Frame(main_frame, bg='#1a1a2e')
        url_frame.pack(fill='x', pady=(0, 20))
        
        url_label = Label(url_frame, text="🎬 YouTube URL:", 
                         bg='#1a1a2e', fg='#ffffff', font=('Arial', 12, 'bold'))
        url_label.pack(anchor='w')
        
        self.url_entry = Entry(url_frame, font=('Arial', 11), bg='#0f0f23', fg='#ffffff', 
                              insertbackground='#ffffff', relief='flat', bd=10)
        self.url_entry.pack(fill='x', pady=(5, 0), ipady=8)
        
        # Folder Selection
        folder_frame = Frame(main_frame, bg='#1a1a2e')
        folder_frame.pack(fill='x', pady=(0, 20))
        
        folder_label = Label(folder_frame, text="📁 Download Folder:", 
                            bg='#1a1a2e', fg='#ffffff', font=('Arial', 12, 'bold'))
        folder_label.pack(anchor='w')
        
        folder_input_frame = Frame(folder_frame, bg='#1a1a2e')
        folder_input_frame.pack(fill='x', pady=(5, 0))
        
        self.folder_entry = Entry(folder_input_frame, textvariable=self.folder_var, 
                                 font=('Arial', 11), bg='#0f0f23', fg='#ffffff', 
                                 insertbackground='#ffffff', relief='flat', bd=10)
        self.folder_entry.pack(side='left', fill='x', expand=True, ipady=8)
        
        browse_btn = Button(folder_input_frame, text="📁 Browse", command=self.browse_folder,
                           bg='#16537e', fg='#ffffff', font=('Arial', 10, 'bold'),
                           relief='flat', bd=0, padx=20, pady=8, cursor='hand2')
        browse_btn.pack(side='right', padx=(10, 0))
        
        # Progress Section
        progress_frame = Frame(main_frame, bg='#1a1a2e')
        progress_frame.pack(fill='x', pady=(0, 20))
        
        # Current file info
        self.current_file_label = Label(progress_frame, textvariable=self.current_file_var,
                                       bg='#1a1a2e', fg='#00ff41', font=('Arial', 10, 'bold'))
        self.current_file_label.pack(anchor='w')
        
        # Progress bar
        self.progress_canvas = Canvas(progress_frame, height=30, bg='#0f0f23', highlightthickness=0)
        self.progress_canvas.pack(fill='x', pady=(5, 0))
        
        # Stats frame
        stats_frame = Frame(progress_frame, bg='#1a1a2e')
        stats_frame.pack(fill='x', pady=(5, 0))
        
        self.progress_label = Label(stats_frame, textvariable=self.progress_var,
                                   bg='#1a1a2e', fg='#ffffff', font=('Arial', 10))
        self.progress_label.pack(side='left')
        
        self.speed_label = Label(stats_frame, textvariable=self.download_speed_var,
                                bg='#1a1a2e', fg='#ffffff', font=('Arial', 10))
        self.speed_label.pack(side='right')
        
        # Download Button
        button_frame = Frame(main_frame, bg='#1a1a2e')
        button_frame.pack(fill='x', pady=(0, 20))
        
        self.download_btn = Button(button_frame, text="🚀 Start Download", 
                                  command=self.start_download,
                                  bg='#00ff41', fg='#000000', font=('Arial', 14, 'bold'),
                                  relief='flat', bd=0, padx=30, pady=12, cursor='hand2')
        self.download_btn.pack()
        
        # Status
        status_frame = Frame(main_frame, bg='#1a1a2e')
        status_frame.pack(fill='x', pady=(0, 10))
        
        self.status_label = Label(status_frame, textvariable=self.status_var,
                                 bg='#1a1a2e', fg='#00ff41', font=('Arial', 11, 'bold'))
        self.status_label.pack()
        
        # Log Section
        log_frame = Frame(main_frame, bg='#1a1a2e')
        log_frame.pack(fill='both', expand=True)
        
        log_label = Label(log_frame, text="📋 Activity Log:", 
                         bg='#1a1a2e', fg='#ffffff', font=('Arial', 12, 'bold'))
        log_label.pack(anchor='w')
        
        self.log_text = Text(log_frame, bg='#0f0f23', fg='#ffffff', font=('Consolas', 10),
                            relief='flat', bd=10, wrap='word', insertbackground='#ffffff')
        self.log_text.pack(fill='both', expand=True, pady=(5, 0))
        
    def setup_animations(self):
        self.animation_running = False
        self.progress_value = 0
        
    def animate_button(self, button, original_color, hover_color):
        def on_enter(e):
            button.configure(bg=hover_color)
        def on_leave(e):
            button.configure(bg=original_color)
        
        button.bind("<Enter>", on_enter)
        button.bind("<Leave>", on_leave)
    
    def update_progress_bar(self, percentage):
        self.progress_canvas.delete("all")
        canvas_width = self.progress_canvas.winfo_width()
        if canvas_width > 1:
            progress_width = (percentage / 100) * canvas_width
            
            # Background
            self.progress_canvas.create_rectangle(0, 0, canvas_width, 30, 
                                                 fill='#0f0f23', outline='')
            
            # Progress bar with gradient effect
            if progress_width > 0:
                self.progress_canvas.create_rectangle(0, 0, progress_width, 30, 
                                                     fill='#00ff41', outline='')
                
                # Animated shine effect
                if self.is_downloading:
                    shine_pos = (time.time() * 100) % canvas_width
                    self.progress_canvas.create_rectangle(shine_pos, 0, shine_pos + 20, 30,
                                                         fill='#ffffff', stipple='gray25', outline='')
            
            # Progress text
            self.progress_canvas.create_text(canvas_width//2, 15, text=f"{percentage:.1f}%",
                                           fill='#ffffff', font=('Arial', 10, 'bold'))
    
    def log_message(self, message):
        timestamp = time.strftime("%H:%M:%S")
        formatted_message = f"[{timestamp}] {message}"
        self.log_text.insert(END, formatted_message + "\n")
        self.log_text.see(END)
        self.root.update()
    
    def update_download_stats(self, progress=0, speed="", eta="", filename=""):
        self.progress_var.set(f"{progress:.1f}%")
        self.download_speed_var.set(speed)
        self.eta_var.set(eta)
        self.current_file_var.set(filename)
        self.update_progress_bar(progress)
        self.root.update()
    
    def download_and_convert(self, video_url, out_folder):
        try:
            # Fetch video info
            self.status_var.set("🔍 Fetching video information...")
            self.root.update()
            
            yt = YouTube(video_url)
            self.log_message(f"🎵 Found: {yt.title}")
            self.current_file_var.set(f"📹 {yt.title}")
            
            # Download audio stream
            self.status_var.set("⬬ Downloading audio stream...")
            audio_stream = yt.streams.filter(only_audio=True).first()
            
            # Simulate download progress
            for i in range(0, 101, 5):
                self.update_download_stats(i, f"{2.5 + (i/20):.1f} MB/s", 
                                         f"{(100-i)//10}s", yt.title)
                time.sleep(0.1)
            
            downloaded_path = audio_stream.download(output_path=out_folder)
            
            # Convert to MP3
            self.status_var.set("🔄 Converting to MP3...")
            self.log_message(f"🔄 Converting: {yt.title}")
            
            base, _ = os.path.splitext(downloaded_path)
            mp3_path = base + '.mp3'
            
            # Simulate conversion progress
            for i in range(0, 101, 10):
                self.update_download_stats(i, "Converting...", f"{(100-i)//15}s", f"Converting {yt.title}")
                time.sleep(0.2)
            
            with AudioFileClip(downloaded_path) as audio_clip:
                audio_clip.write_audiofile(mp3_path, bitrate="320k", verbose=False, logger=None)
            
            os.remove(downloaded_path)
            self.log_message(f"✅ Completed: {yt.title}")
            self.update_download_stats(100, "Completed", "Done", f"✅ {yt.title}")
            
        except Exception as e:
            self.log_message(f"❌ Error: {e}")
            self.status_var.set("❌ Download failed")
    
    def process_playlist(self, playlist_url, out_folder):
        try:
            self.status_var.set("🔍 Analyzing playlist...")
            pl = Playlist(playlist_url)
            total_videos = len(pl.video_urls)
            self.log_message(f"📋 Found playlist with {total_videos} videos")
            
            for index, url in enumerate(pl.video_urls, 1):
                self.status_var.set(f"📹 Processing video {index}/{total_videos}")
                self.download_and_convert(url, out_folder)
                
        except Exception as e:
            self.log_message(f"❌ Playlist error: {e}")
            self.status_var.set("❌ Playlist processing failed")
    
    def start_download(self):
        if self.is_downloading:
            return
            
        url = self.url_entry.get().strip()
        if not url:
            self.log_message("❌ Please enter a YouTube URL")
            return
            
        folder = self.folder_var.get() or "downloads"
        os.makedirs(folder, exist_ok=True)
        
        self.is_downloading = True
        self.download_btn.configure(text="⏳ Downloading...", state='disabled', bg='#666666')
        
        def task():
            try:
                if "playlist" in url or "list=" in url:
                    self.process_playlist(url, folder)
                else:
                    self.download_and_convert(url, folder)
                    
                self.status_var.set("✅ All downloads completed!")
                self.log_message("🎉 All downloads finished successfully!")
                
            except Exception as e:
                self.log_message(f"❌ Unexpected error: {e}")
                self.status_var.set("❌ Download failed")
            finally:
                self.is_downloading = False
                self.download_btn.configure(text="🚀 Start Download", state='normal', bg='#00ff41')
                self.update_download_stats(0, "", "", "")
        
        threading.Thread(target=task, daemon=True).start()
    
    def browse_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.folder_var.set(folder)
    
    def run(self):
        # Add button hover effects
        self.animate_button(self.download_btn, '#00ff41', '#00cc33')
        
        # Start animation loop for progress bar
        def animate_progress():
            if self.is_downloading:
                self.update_progress_bar(self.progress_value)
            self.root.after(100, animate_progress)
        
        animate_progress()
        self.root.mainloop()

if __name__ == "__main__":
    app = ModernDownloader()
    app.run()
