"""
Music player service - Business logic for music playback management.
"""

from pathlib import Path
from typing import Dict, Optional

from loguru import logger

from music.queue import PlaybackQueue


class MusicPlayerService:
    """Service for managing music playback queue and history."""

    def __init__(self):
        """Initialize the music player service."""
        self.queue = PlaybackQueue()

    def get_next(self) -> Optional[Path]:
        """
        Get the next song from the queue.

        Returns:
            Path to the next song file, or None if no songs available

        Behavior:
            - If queue is empty, cycles back through played songs
            - Moves current song to played stack
        """
        return self.queue.get_next()

    def get_previous(self) -> Optional[Path]:
        """
        Get the previous song from play history.

        Returns:
            Path to the previous song file, or None if no history

        Behavior:
            - Returns previous song from played stack
            - Moves current song back to queue
        """
        return self.queue.get_previous()

    def get_status(self) -> Dict[str, any]:
        """
        Get current player status information.

        Returns:
            Dictionary with player status:
                - queue_size: Number of songs in queue
                - history_size: Number of songs in play history
                - has_next: Whether there's a next song available
                - has_previous: Whether there's a previous song available
        """
        status = {
            "queue_size": self.queue.get_queue_size(),
            "history_size": self.queue.get_history_size(),
            "has_next": self.queue.has_next(),
            "has_previous": self.queue.has_previous(),
        }

        logger.debug(
            f"Player status: queue={status['queue_size']}, "
            f"history={status['history_size']}"
        )
        return status

    def clear_queue(self) -> None:
        """Clear the playback queue."""
        self.queue.clear_queue()

    def clear_history(self) -> None:
        """Clear the play history."""
        self.queue.clear_history()

    def reset(self) -> None:
        """Reset both queue and history."""
        self.queue.clear_all()
        logger.info("Player reset complete")
