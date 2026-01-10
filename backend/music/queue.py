"""
Playback queue - Manages music playback queue and history.
Handles ready-to-play tracks and play history.
"""

import queue
from pathlib import Path
from typing import List, Optional

from loguru import logger

# Shared queues
_ready_queue = queue.Queue()
_played_stack: List[str] = []


class PlaybackQueue:
    """
    Playback queue manager.

    Manages the queue of ready-to-play tracks and play history.
    """

    def __init__(self):
        """Initialize the playback queue."""
        self.ready_queue = _ready_queue
        self.played_stack = _played_stack

    def add_to_queue(self, file_path: str) -> None:
        """
        Add a track to the playback queue.

        Args:
            file_path: Path to the audio file
        """
        self.ready_queue.put(file_path)
        logger.debug(f"Added to queue: {Path(file_path).name}")

    def get_next(self) -> Optional[Path]:
        """
        Get the next track from the queue.

        If queue is empty, recycles played tracks.

        Returns:
            Path to next track or None if no tracks available
        """
        # If queue is empty, recycle played tracks
        if self.ready_queue.empty():
            if self.played_stack:
                logger.info("Queue empty, recycling played tracks")
                for track in self.played_stack:
                    self.ready_queue.put(track)
                self.played_stack.clear()
            else:
                logger.warning("No tracks available in queue or history")
                return None

        # Get next track
        try:
            path_str = self.ready_queue.get()
            path = Path(path_str)

            if not path.exists():
                logger.error(f"Track file not found: {path}")
                return self.get_next()

            # Add to history
            self.played_stack.append(path_str)
            logger.debug(f"Next track: {path.name}")

            return path

        except Exception as e:
            logger.error(f"Error getting next track: {e}")
            return None

    def get_previous(self) -> Optional[Path]:
        """
        Get the previous track from history.

        Returns:
            Path to previous track or None if no history
        """
        if not self.played_stack:
            logger.warning("No tracks in play history")
            return None

        try:
            # Different cases for history navigation
            if len(self.played_stack) <= 1:
                # Only one track played
                if self.ready_queue.qsize() == 0:
                    # No queue, replay current
                    path = Path(self.played_stack[-1])
                    logger.debug(f"Replaying current track: {path.name}")
                else:
                    # Swap with last in queue
                    last_song = self.ready_queue.queue[-1]
                    self.ready_queue.queue[-1] = self.played_stack[-1]
                    self.played_stack[-1] = last_song
                    path = Path(last_song)
                    logger.debug(f"Swapped to previous: {path.name}")
            else:
                # Multiple tracks played, go back one
                current = self.played_stack.pop()
                path = Path(self.played_stack[-1])
                self.ready_queue.queue.insert(0, current)
                logger.debug(f"Previous track: {path.name}")

            if not path.exists():
                logger.error(f"Track file not found: {path}")
                return None

            return path

        except Exception as e:
            logger.error(f"Error getting previous track: {e}")
            return None

    def clear_queue(self) -> None:
        """Clear the playback queue."""
        while not self.ready_queue.empty():
            try:
                self.ready_queue.get_nowait()
            except queue.Empty:
                break
        logger.info("Playback queue cleared")

    def clear_history(self) -> None:
        """Clear the play history."""
        self.played_stack.clear()
        logger.info("Play history cleared")

    def clear_all(self) -> None:
        """Clear both queue and history."""
        self.clear_queue()
        self.clear_history()
        logger.info("Queue and history cleared")

    def get_queue_size(self) -> int:
        """Get the number of tracks in queue."""
        return self.ready_queue.qsize()

    def get_history_size(self) -> int:
        """Get the number of tracks in history."""
        return len(self.played_stack)

    def has_next(self) -> bool:
        """Check if there are tracks available to play next."""
        return self.ready_queue.qsize() > 0 or len(self.played_stack) > 0

    def has_previous(self) -> bool:
        """Check if there are previous tracks in history."""
        return len(self.played_stack) > 0


# Export for backward compatibility
ready_queue = _ready_queue
played_stack = _played_stack


def clean_all():
    """Clean all queues (backward compatibility)."""
    queue_instance = PlaybackQueue()
    queue_instance.clear_all()
