"""
Music downloader - Downloads music from YouTube and normalizes audio.
Handles background download queue processing.
"""

import queue
import re
import subprocess
import tempfile
from pathlib import Path
import json
from loguru import logger

from music.queue import PlaybackQueue

# Constants
BASE_DIR = Path(__file__).parent.parent
FFMPEG_PATH = BASE_DIR / "ffmpeg-8.0-essentials_build" / "bin" / "ffmpeg.exe"
CACHE_PREFIX = "playlist_"

# Shared queue for downloads
_download_queue = queue.Queue()

try:
    logger.info("Checking for yt-dlp updates...")
    update_command = ["yt-dlp.exe", "-U"]
    subprocess.run(update_command, check=True, capture_output=True)
    logger.info("yt-dlp is up to date.")
except Exception as e:
    logger.warning(f"Could not update yt-dlp: {e}. Proceeding anyway...")


class MusicDownloader:
    """
    Music downloader service.

    Downloads music from YouTube and processes it for playback.
    """

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MusicDownloader, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        """Initialize the music downloader."""

        if self._initialized:
            return

        self._initialized = True
        self.download_queue = _download_queue
        self.playback_queue = PlaybackQueue()
        self.cache_dir = Path(tempfile.mkdtemp(prefix=CACHE_PREFIX))
        self.ffmpeg_path = str(FFMPEG_PATH)

        logger.info(f"Music cache directory: {self.cache_dir}")

    def queue_download(self, query: str) -> None:
        """
        Queue a track for download.

        Args:
            query: Search query for the track
        """
        self.download_queue.put(query)
        logger.debug(f"Queued for download: {query}")

    def download_worker(self) -> None:
        """
        Background worker for processing download queue.

        This should run in a separate thread. It continuously processes
        the download queue until a None sentinel is received.
        """
        logger.info("Download worker started")

        while True:
            try:
                query = self.download_queue.get()

                # None is sentinel for shutdown
                if query is None:
                    logger.info("Download worker stopping")
                    break

                # Download the track
                self._download_track(query)

                # Mark task as done
                self.download_queue.task_done()

            except Exception as e:
                logger.error(f"Error in download worker: {e}", exc_info=True)

    def _download_track(self, query: str) -> None:
        """
        Download a single track.

        Args:
            query: Search query for the track
        """
        try:
            # Ensure cache directory exists
            self.cache_dir.mkdir(parents=True, exist_ok=True)
            output_template = str(self.cache_dir / "%(title)s.%(ext)s")

            # Configure yt-dlp
            command_args = [
                f"{Path(__file__).parent.parent}/yt-dlp.exe",
                "-f",
                "bestaudio/best",
                "--no-playlist",
                "--ffmpeg-location",
                self.ffmpeg_path,
                "-q",
                "--no-warnings",
                "-o",
                output_template,
                "--extract-audio",
                "--audio-format",
                "mp3",
                "--audio-quality",
                "192K",
                # Headers
                "--user-agent",
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
                "--add-header",
                "Accept-Language: en-US,en;q=0.9",
                # A query
                "--print-json",
                f"ytsearch1:{query}",
            ]

            # Download track
            logger.info(f"Downloading: {query}...")
            result = subprocess.run(
                command_args,
                check=True,
                capture_output=True,
                text=True,
                encoding="cp1252",
            )
            lines = [l for l in result.stdout.splitlines() if l.strip()]
            info = json.loads(lines[-1])

            output_path = Path(info.get("_filename")).with_suffix(".mp3")
            logger.info(
                f"File downloaded to: {output_path}. Now normalizing and queueing."
            )
            self._normalize_audio(output_path)
            self.playback_queue.add_to_queue(str(output_path))
            logger.info(f"Downloaded and queued: {query}")

        except Exception as e:
            logger.error(f"Error downloading track '{query}': {e}")

    def _normalize_audio(self, path: Path) -> None:
        """
        Normalize audio levels using FFmpeg.

        Args:
            path: Path to the audio file
        """
        try:
            normalized_path = path.with_stem(f"{path.stem}_norm")

            # Run FFmpeg normalization
            subprocess.run(
                [
                    self.ffmpeg_path,
                    "-i",
                    str(path),
                    "-af",
                    "loudnorm=I=-16:TP=-1.5:LRA=11",
                    "-y",
                    str(normalized_path),
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True,
            )

            # Replace original with normalized version
            normalized_path.replace(path)
            logger.debug(f"Normalized audio: {path.name}")

        except Exception as e:
            logger.error(f"Error normalizing audio {path}: {e}")

    @staticmethod
    def sanitize_filename(name: str) -> str:
        """
        Sanitize a filename by removing invalid characters.

        Args:
            name: Original filename

        Returns:
            Sanitized filename
        """
        name = re.sub(r'[<>:"/\\|?*]', "", name)
        name = name.replace("–", "-")
        name = name.strip()
        return name

    def cleanup(self) -> None:
        """Clean up cache directory."""
        try:
            if self.cache_dir.exists():
                for file in self.cache_dir.iterdir():
                    try:
                        file.unlink()
                    except Exception as e:
                        logger.warning(f"Error deleting {file}: {e}")

                self.cache_dir.rmdir()
                logger.info("Cache directory cleaned")

        except Exception as e:
            logger.error(f"Error cleaning cache: {e}")
