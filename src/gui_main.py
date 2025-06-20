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
        self.root.geometry("900x700")
        self.root.configure(bg='#1a1a2e')
        self.root.resizable(True, True)
        
        # Center window
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() // 2) - (900 // 2)
        y = (self.root.winfo_screenheight() // 2) - (700 // 2)
        self.root.geometry(f'900x700+{x}+{y}')
        
    def setup_variables(self):
        self.folder_var = StringVar(value="downloads")
        self.status_var = StringVar(value="Ready to download")
        self.progress_var = StringVar(value="0%")
        self.current_file_var = StringVar(value="")
        self.download_speed_var = StringVar(value="")
        self.eta_var = StringVar(value="")
        self.total_files_var = StringVar(value="")
        self.is_downloading = False
        self.stop_download = False  # Add stop flag
        self.current_progress = 0
        self.start_time = 0
        self.downloaded_bytes = 0
        self.total_bytes = 0
        self.download_thread = None  # Track download thread
        
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
        
        # Header with gradient effect
        header_frame = Frame(main_frame, bg='#1a1a2e')
        header_frame.pack(fill='x', pady=(0, 30))
        
        title_label = Label(header_frame, text="🎵 YouTube Music Downloader Pro", 
                           bg='#1a1a2e', fg='#ffffff', font=('Arial', 26, 'bold'))
        title_label.pack()
        
        subtitle_label = Label(header_frame, text="Download and convert YouTube videos to high-quality MP3", 
                              bg='#1a1a2e', fg='#16537e', font=('Arial', 13))
        subtitle_label.pack(pady=(5, 0))
        
        # Enhanced URL Input Section with modern styling
        url_frame = Frame(main_frame, bg='#1a1a2e')
        url_frame.pack(fill='x', pady=(0, 25))
        
        url_label = Label(url_frame, text="🎬 YouTube URL:", 
                         bg='#1a1a2e', fg='#ffffff', font=('Arial', 12, 'bold'))
        url_label.pack(anchor='w', pady=(0, 8))
        
        # Modern URL input container with rounded corners effect
        url_container = Frame(url_frame, bg='#16537e', height=48)
        url_container.pack(fill='x', pady=(0, 5))
        url_container.pack_propagate(False)
        
        # Inner URL frame
        url_inner_frame = Frame(url_container, bg='#0f0f23')
        url_inner_frame.pack(fill='both', expand=True, padx=2, pady=2)
        
        # URL entry with enhanced styling
        self.url_entry = Entry(url_inner_frame, font=('Arial', 12), bg='#0f0f23', fg='#ffffff', 
                              insertbackground='#ffffff', relief='flat', bd=0,
                              selectbackground='#00ff41', selectforeground='#000000')
        self.url_entry.pack(side='left', fill='both', expand=True, padx=12, pady=12)
        
        # Button container for URL actions
        url_buttons_frame = Frame(url_inner_frame, bg='#0f0f23')
        url_buttons_frame.pack(side='right', padx=(5, 8), pady=8)
        
        # Paste button with modern styling
        paste_btn = Button(url_buttons_frame, text="📋", command=self.paste_url,
                          bg='#00ff41', fg='#000000', font=('Arial', 12, 'bold'),
                          relief='flat', bd=0, padx=8, pady=4, cursor='hand2',
                          activebackground='#00cc33', activeforeground='#000000')
        paste_btn.pack(side='left', padx=(0, 5))
        
        # Clear button with modern styling
        clear_btn = Button(url_buttons_frame, text="🗑️", command=self.clear_url,
                          bg='#ff4757', fg='#ffffff', font=('Arial', 12, 'bold'),
                          relief='flat', bd=0, padx=8, pady=4, cursor='hand2',
                          activebackground='#ff3838', activeforeground='#ffffff')
        clear_btn.pack(side='left')
        
        # URL validation indicator
        self.url_status_frame = Frame(url_frame, bg='#1a1a2e')
        self.url_status_frame.pack(fill='x', pady=(2, 0))
        
        self.url_status_label = Label(self.url_status_frame, text="", 
                                     bg='#1a1a2e', fg='#16537e', font=('Arial', 9, 'italic'))
        self.url_status_label.pack(anchor='w')
        
        # Bind events for real-time URL validation
        self.url_entry.bind('<KeyRelease>', self.validate_url)
        self.url_entry.bind('<FocusIn>', self.on_url_focus_in)
        self.url_entry.bind('<FocusOut>', self.on_url_focus_out)
        
        # Enhanced Folder Selection with better styling
        folder_frame = Frame(main_frame, bg='#1a1a2e')
        folder_frame.pack(fill='x', pady=(0, 25))
        
        folder_label = Label(folder_frame, text="📁 Download Folder:", 
                            bg='#1a1a2e', fg='#ffffff', font=('Arial', 12, 'bold'))
        folder_label.pack(anchor='w', pady=(0, 8))
        
        # Modern folder input container
        folder_container = Frame(folder_frame, bg='#16537e', height=48)
        folder_container.pack(fill='x', pady=(0, 5))
        folder_container.pack_propagate(False)
        
        folder_inner_frame = Frame(folder_container, bg='#0f0f23')
        folder_inner_frame.pack(fill='both', expand=True, padx=2, pady=2)
        
        self.folder_entry = Entry(folder_inner_frame, textvariable=self.folder_var, 
                                 font=('Arial', 12), bg='#0f0f23', fg='#ffffff', 
                                 insertbackground='#ffffff', relief='flat', bd=0,
                                 selectbackground='#00ff41', selectforeground='#000000')
        self.folder_entry.pack(side='left', fill='both', expand=True, padx=12, pady=12)
        
        browse_btn = Button(folder_inner_frame, text="📁 Browse", command=self.browse_folder,
                           bg='#16537e', fg='#ffffff', font=('Arial', 11, 'bold'),
                           relief='flat', bd=0, padx=20, pady=8, cursor='hand2',
                           activebackground='#1e6091', activeforeground='#ffffff')
        browse_btn.pack(side='right', padx=(5, 8), pady=8)
        
        # Enhanced Progress Section
        progress_frame = Frame(main_frame, bg='#1a1a2e')
        progress_frame.pack(fill='x', pady=(0, 25))
        
        # File info section
        file_info_frame = Frame(progress_frame, bg='#1a1a2e')
        file_info_frame.pack(fill='x', pady=(0, 10))
        
        self.current_file_label = Label(file_info_frame, textvariable=self.current_file_var,
                                       bg='#1a1a2e', fg='#00ff41', font=('Arial', 11, 'bold'))
        self.current_file_label.pack(anchor='w')
        
        self.total_files_label = Label(file_info_frame, textvariable=self.total_files_var,
                                      bg='#1a1a2e', fg='#16537e', font=('Arial', 10))
        self.total_files_label.pack(anchor='w')
        
        # Enhanced Progress bar with border
        progress_container = Frame(progress_frame, bg='#16537e', height=34)
        progress_container.pack(fill='x', pady=(5, 10))
        progress_container.pack_propagate(False)
        
        self.progress_canvas = Canvas(progress_container, height=30, bg='#0f0f23', highlightthickness=0)
        self.progress_canvas.pack(fill='both', expand=True, padx=2, pady=2)
        
        # Enhanced Stats frame
        stats_frame = Frame(progress_frame, bg='#1a1a2e')
        stats_frame.pack(fill='x')
        
        stats_left = Frame(stats_frame, bg='#1a1a2e')
        stats_left.pack(side='left')
        
        self.progress_label = Label(stats_left, textvariable=self.progress_var,
                                   bg='#1a1a2e', fg='#ffffff', font=('Arial', 11, 'bold'))
        self.progress_label.pack(side='left')
        
        stats_right = Frame(stats_frame, bg='#1a1a2e')
        stats_right.pack(side='right')
        
        self.speed_label = Label(stats_right, textvariable=self.download_speed_var,
                                bg='#1a1a2e', fg='#00ff41', font=('Arial', 10))
        self.speed_label.pack(side='right', padx=(10, 0))
        
        self.eta_label = Label(stats_right, textvariable=self.eta_var,
                              bg='#1a1a2e', fg='#16537e', font=('Arial', 10))
        self.eta_label.pack(side='right')
        
        # Enhanced Download Button with gradient effect
        button_frame = Frame(main_frame, bg='#1a1a2e')
        button_frame.pack(fill='x', pady=(0, 25))
        
        # Container for download and stop buttons
        button_container = Frame(button_frame, bg='#1a1a2e')
        button_container.pack()
        
        self.download_btn = Button(button_container, text="🚀 Start Download", 
                                  command=self.start_download,
                                  bg='#00ff41', fg='#000000', font=('Arial', 16, 'bold'),
                                  relief='flat', bd=0, padx=40, pady=15, cursor='hand2',
                                  activebackground='#00cc33', activeforeground='#000000')
        self.download_btn.pack(side='left', padx=(0, 10))
        
        # Stop button (initially hidden)
        self.stop_btn = Button(button_container, text="⛔ Stop Download", 
                              command=self.stop_download_process,
                              bg='#ff4757', fg='#ffffff', font=('Arial', 16, 'bold'),
                              relief='flat', bd=0, padx=40, pady=15, cursor='hand2',
                              activebackground='#ff3838', activeforeground='#ffffff')
        self.stop_btn.pack(side='left')
        self.stop_btn.pack_forget()  # Hide initially
        
        # Status with better styling
        status_frame = Frame(main_frame, bg='#1a1a2e')
        status_frame.pack(fill='x', pady=(0, 15))
        
        self.status_label = Label(status_frame, textvariable=self.status_var,
                                 bg='#1a1a2e', fg='#00ff41', font=('Arial', 12, 'bold'))
        self.status_label.pack()
        
        # Enhanced Log Section
        log_frame = Frame(main_frame, bg='#1a1a2e')
        log_frame.pack(fill='both', expand=True)
        
        log_header = Frame(log_frame, bg='#1a1a2e')
        log_header.pack(fill='x', pady=(0, 5))
        
        log_label = Label(log_header, text="📋 Activity Log:", 
                         bg='#1a1a2e', fg='#ffffff', font=('Arial', 12, 'bold'))
        log_label.pack(side='left')
        
        clear_btn = Button(log_header, text="🗑️ Clear", command=self.clear_log,
                          bg='#16537e', fg='#ffffff', font=('Arial', 9),
                          relief='flat', bd=0, padx=15, pady=5, cursor='hand2')
        clear_btn.pack(side='right')
        
        # Log text with scrollbar
        log_container = Frame(log_frame, bg='#0f0f23')
        log_container.pack(fill='both', expand=True)
        
        self.log_text = Text(log_container, bg='#0f0f23', fg='#ffffff', font=('Consolas', 10),
                            relief='flat', bd=0, wrap='word', insertbackground='#ffffff')
        
        scrollbar = ttk.Scrollbar(log_container, orient="vertical", command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        
        self.log_text.pack(side="left", fill='both', expand=True, padx=10, pady=10)
        scrollbar.pack(side="right", fill="y")
        
    def setup_animations(self):
        self.animation_running = False
        self.shine_position = 0
        
    def clear_log(self):
        self.log_text.delete(1.0, END)
        
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
                # Main progress bar
                self.progress_canvas.create_rectangle(0, 0, progress_width, 30, 
                                                     fill='#00ff41', outline='')
                
                # Animated shine effect
                if self.is_downloading and percentage < 100:
                    self.shine_position = (self.shine_position + 5) % canvas_width
                    shine_width = 30
                    shine_start = self.shine_position
                    shine_end = min(shine_start + shine_width, progress_width)
                    
                    if shine_start < progress_width:
                        self.progress_canvas.create_rectangle(shine_start, 0, shine_end, 30,
                                                             fill='#ffffff', stipple='gray25', outline='')
            
            # Progress text
            self.progress_canvas.create_text(canvas_width//2, 15, text=f"{percentage:.1f}%",
                                           fill='#000000' if percentage > 50 else '#ffffff', 
                                           font=('Arial', 11, 'bold'))
    
    def log_message(self, message):
        timestamp = time.strftime("%H:%M:%S")
        formatted_message = f"[{timestamp}] {message}"
        self.log_text.insert(END, formatted_message + "\n")
        self.log_text.see(END)
        self.root.update()
    
    def progress_callback(self, stream, chunk, bytes_remaining):
        # Check stop flag during download
        if self.stop_download:
            raise Exception("Download stopped by user")
            
        total_size = stream.filesize
        bytes_downloaded = total_size - bytes_remaining
        percentage = (bytes_downloaded / total_size) * 100
        
        # Calculate speed
        current_time = time.time()
        if hasattr(self, 'last_update_time'):
            time_diff = current_time - self.last_update_time
            if time_diff > 0:
                speed = (bytes_downloaded - self.last_bytes_downloaded) / time_diff
                speed_mb = speed / (1024 * 1024)
                
                # Calculate ETA
                if speed > 0:
                    eta_seconds = bytes_remaining / speed
                    eta_min = int(eta_seconds // 60)
                    eta_sec = int(eta_seconds % 60)
                    eta_str = f"ETA: {eta_min:02d}:{eta_sec:02d}"
                else:
                    eta_str = "ETA: --:--"
                
                self.download_speed_var.set(f"Speed: {speed_mb:.1f} MB/s")
                self.eta_var.set(eta_str)
        
        self.last_update_time = current_time
        self.last_bytes_downloaded = bytes_downloaded
        
        # Update progress
        self.current_progress = percentage
        self.progress_var.set(f"{percentage:.1f}%")
        self.update_progress_bar(percentage)
        self.root.update()
    
    def download_and_convert(self, video_url, out_folder, video_index=None, total_videos=None):
        try:
            # Check stop flag at the beginning
            self.check_stop_flag()
            
            # Reset progress tracking
            self.last_bytes_downloaded = 0
            self.last_update_time = time.time()
            
            # Fetch video info
            self.status_var.set("🔍 Fetching video information...")
            self.root.update()
            self.check_stop_flag()
            
            yt = YouTube(video_url, on_progress_callback=self.progress_callback)
            
            # Update file info
            file_info = f"📹 {yt.title}"
            if video_index and total_videos:
                file_info += f" ({video_index}/{total_videos})"
            
            self.current_file_var.set(file_info)
            self.log_message(f"🎵 Found: {yt.title}")
            self.check_stop_flag()
            
            # Get audio stream
            self.status_var.set("⬇️ Downloading audio stream...")
            audio_stream = yt.streams.filter(only_audio=True).first()
            
            if not audio_stream:
                raise Exception("No audio stream available")
            
            self.log_message(f"📊 File size: {audio_stream.filesize / (1024*1024):.1f} MB")
            self.check_stop_flag()
            
            # Download
            downloaded_path = audio_stream.download(output_path=out_folder)
            self.check_stop_flag()
            
            # Convert to MP3
            self.status_var.set("🔄 Converting to MP3...")
            self.current_file_var.set(f"🔄 Converting: {yt.title}")
            self.log_message(f"🔄 Converting: {yt.title}")
            
            base, _ = os.path.splitext(downloaded_path)
            mp3_path = base + '.mp3'
            
            # Show conversion progress with realistic animation
            conversion_steps = [0, 25, 50, 75, 90, 100]
            for i, step in enumerate(conversion_steps):
                self.check_stop_flag()  # Check before each step
                self.update_progress_bar(step)
                self.progress_var.set(f"Converting... {step}%")
                self.download_speed_var.set("Converting...")
                self.eta_var.set(f"Step {i+1}/{len(conversion_steps)}")
                self.root.update()
                time.sleep(0.2)
            
            # Actual conversion with proper parameters
            self.check_stop_flag()
            try:
                with AudioFileClip(downloaded_path) as audio_clip:
                    # Use only supported parameters
                    audio_clip.write_audiofile(mp3_path, bitrate="320k")
            except Exception as conv_error:
                if "stopped by user" in str(conv_error):
                    raise conv_error
                # Fallback conversion without bitrate if it fails
                self.log_message(f"⚠️ Trying alternative conversion method...")
                with AudioFileClip(downloaded_path) as audio_clip:
                    audio_clip.write_audiofile(mp3_path)
            
            # Cleanup
            if os.path.exists(downloaded_path):
                os.remove(downloaded_path)
            
            self.check_stop_flag()
            
            # Success
            self.log_message(f"✅ Completed: {yt.title}")
            self.log_message(f"💾 Saved as: {os.path.basename(mp3_path)}")
            self.update_progress_bar(100)
            self.current_file_var.set(f"✅ {yt.title}")
            self.download_speed_var.set("Completed")
            self.eta_var.set("Done")
            time.sleep(1)  # Show completion briefly
            
        except Exception as e:
            if "stopped by user" in str(e):
                # Clean up partial downloads
                try:
                    if 'downloaded_path' in locals() and os.path.exists(downloaded_path):
                        os.remove(downloaded_path)
                    if 'mp3_path' in locals() and os.path.exists(mp3_path):
                        os.remove(mp3_path)
                except:
                    pass
                self.log_message("🛑 Download stopped by user")
                self.status_var.set("🛑 Download stopped")
                raise e
            else:
                self.log_message(f"❌ Error: {str(e)}")
                self.status_var.set("❌ Download failed")
                raise e
    
    def process_playlist(self, playlist_url, out_folder):
        try:
            self.check_stop_flag()
            self.status_var.set("🔍 Analyzing playlist...")
            self.log_message("🔍 Analyzing playlist...")
            
            pl = Playlist(playlist_url)
            video_urls = list(pl.video_urls)  # Convert to list to get count
            total_videos = len(video_urls)
            
            self.log_message(f"📋 Found playlist with {total_videos} videos")
            self.total_files_var.set(f"Playlist: {total_videos} videos")
            self.check_stop_flag()
            
            for index, url in enumerate(video_urls, 1):
                self.check_stop_flag()  # Check before each video
                self.status_var.set(f"📹 Processing video {index}/{total_videos}")
                self.download_and_convert(url, out_folder, index, total_videos)
                
        except Exception as e:
            if "stopped by user" in str(e):
                self.log_message("🛑 Playlist download stopped by user")
                self.status_var.set("🛑 Playlist stopped")
                raise e
            else:
                self.log_message(f"❌ Playlist error: {str(e)}")
                self.status_var.set("❌ Playlist processing failed")
                raise e
    
    def start_download(self):
        if self.is_downloading:
            return
            
        url = self.url_entry.get().strip()
        if not url:
            self.log_message("❌ Please enter a YouTube URL")
            return
        
        if not url.startswith("http"):
            self.log_message("❌ Please enter a valid YouTube URL")
            return
            
        folder = self.folder_var.get() or "downloads"
        os.makedirs(folder, exist_ok=True)
        
        # Reset stop flag and set downloading state
        self.stop_download = False
        self.is_downloading = True
        
        # Update UI - show stop button, hide start button
        self.download_btn.configure(text="⏳ Downloading...", state='disabled', bg='#666666')
        self.stop_btn.pack(side='left')
        
        def task():
            try:
                if "playlist" in url or "list=" in url:
                    self.process_playlist(url, folder)
                else:
                    self.total_files_var.set("Single video")
                    self.download_and_convert(url, folder)
                    
                # Only show success if not stopped
                if not self.stop_download:
                    self.status_var.set("✅ All downloads completed!")
                    self.log_message("🎉 All downloads finished successfully!")
                
            except Exception as e:
                if "stopped by user" not in str(e):
                    self.log_message(f"❌ Unexpected error: {str(e)}")
                    self.status_var.set("❌ Download failed")
            finally:
                # Reset UI state
                self.root.after(0, self.reset_download_state)
        
        # Start download in separate thread
        self.download_thread = threading.Thread(target=task, daemon=True)
        self.download_thread.start()
    
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
                self.update_progress_bar(self.current_progress)
            self.root.after(100, animate_progress)
        
        animate_progress()
        self.log_message("🎵 YouTube Music Downloader Pro - Ready!")
        
        # Handle window close event
        def on_closing():
            if self.is_downloading:
                self.stop_download = True
                self.log_message("🛑 Stopping download before exit...")
                # Give time for cleanup
                self.root.after(1000, self.root.destroy)
            else:
                self.root.destroy()
        
        self.root.protocol("WM_DELETE_WINDOW", on_closing)
        self.root.mainloop()

    def paste_url(self):
        """Paste URL from clipboard"""
        try:
            clipboard_content = self.root.clipboard_get()
            self.url_entry.delete(0, END)
            self.url_entry.insert(0, clipboard_content)
            self.validate_url()
            self.log_message("📋 URL pasted from clipboard")
        except Exception:
            self.log_message("❌ Nothing to paste from clipboard")
    
    def clear_url(self):
        """Clear URL input field"""
        self.url_entry.delete(0, END)
        self.url_status_label.config(text="", fg='#16537e')
        self.log_message("🗑️ URL field cleared")
    
    def validate_url(self, event=None):
        """Real-time URL validation"""
        url = self.url_entry.get().strip()
        
        if not url:
            self.url_status_label.config(text="", fg='#16537e')
            return
        
        if url.startswith(('https://www.youtube.com', 'https://youtube.com', 'https://youtu.be', 'https://m.youtube.com')):
            if 'playlist' in url or 'list=' in url:
                self.url_status_label.config(text="✅ Valid YouTube playlist URL detected", fg='#00ff41')
            else:
                self.url_status_label.config(text="✅ Valid YouTube video URL detected", fg='#00ff41')
        elif 'youtube.com' in url or 'youtu.be' in url:
            self.url_status_label.config(text="⚠️ Please use full YouTube URL (starting with https://)", fg='#ffa502')
        else:
            self.url_status_label.config(text="❌ Invalid URL - Please enter a YouTube URL", fg='#ff4757')
    
    def on_url_focus_in(self, event):
        """URL field focus in event"""
        if not self.url_entry.get().strip():
            self.url_status_label.config(text="💡 Paste a YouTube video or playlist URL here", fg='#16537e')
    
    def on_url_focus_out(self, event):
        """URL field focus out event"""
        if not self.url_entry.get().strip():
            self.url_status_label.config(text="", fg='#16537e')
    
    def stop_download_process(self):
        """Stop the current download process"""
        if self.is_downloading:
            self.stop_download = True
            self.log_message("🛑 Stopping download...")
            self.status_var.set("🛑 Stopping download...")
            
            # Update UI immediately
            self.stop_btn.configure(text="⏳ Stopping...", state='disabled', bg='#666666')
            self.root.update()
    
    def check_stop_flag(self):
        """Check if download should be stopped"""
        if self.stop_download:
            raise Exception("Download stopped by user")
    
    def reset_download_state(self):
        """Reset download state and UI"""
        self.is_downloading = False
        self.stop_download = False
        self.download_thread = None
        
        # Reset UI
        self.download_btn.configure(text="🚀 Start Download", state='normal', bg='#00ff41')
        self.download_btn.pack(side='left', padx=(0, 10))
        
        self.stop_btn.configure(text="⛔ Stop Download", state='normal', bg='#ff4757')
        self.stop_btn.pack_forget()
        
        # Clear progress info
        self.current_file_var.set("")
        self.total_files_var.set("")
        self.download_speed_var.set("")
        self.eta_var.set("")
        self.progress_var.set("0%")
        self.update_progress_bar(0)

if __name__ == "__main__":
    app = ModernDownloader()
    app.run()
