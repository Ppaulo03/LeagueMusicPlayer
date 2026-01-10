"""
Game monitoring service - Watches for League of Legends game state changes.
Continuously monitors game state and triggers playlist generation on champion changes.
"""

from time import sleep
from typing import Optional

from loguru import logger

from game.game_state import GameStateManager
from music.playlist import PlaylistGenerator
from schemas import Champion
from config.settings import TRACK_COUNT


class GameMonitorService:
    """
    Service to monitor League of Legends game state.

    Continuously polls the Riot client for active game data and generates
    personalized playlists when a new champion is detected.
    """

    def __init__(self, poll_interval: float = 5.0, retry_interval: float = 0.5):
        """
        Initialize the game monitor service.

        Args:
            poll_interval: Seconds between game state checks
            retry_interval: Seconds between retries when no game is active
        """
        self.poll_interval = poll_interval
        self.retry_interval = retry_interval
        self.last_champion: Optional[Champion] = None
        self._running = False
        self.game_state = GameStateManager()
        self.playlist_generator = PlaylistGenerator()

    def start(self) -> None:
        """
        Start monitoring game state.

        Runs indefinitely, checking for game state changes and generating
        playlists when a new champion is detected.
        """
        self._running = True
        logger.info(
            f"Game monitor started (poll_interval={self.poll_interval}s, "
            f"retry_interval={self.retry_interval}s)"
        )

        while self._running:
            try:
                self._check_game_state()
                sleep(self.poll_interval)
            except Exception as e:
                logger.error(f"Error in game monitor: {e}", exc_info=True)
                sleep(self.poll_interval)

    def stop(self) -> None:
        """Stop the game monitoring service."""
        self._running = False
        logger.info("Game monitor stopped")

    def _check_game_state(self) -> None:
        """
        Check current game state and update if champion changed.

        Polls the Riot client, waits for an active game, and triggers
        playlist generation if a new champion is detected.
        """
        current_champion = self._get_active_champion()

        if self._champion_changed(current_champion):
            logger.info(f"Champion changed: {current_champion.name}")
            self.last_champion = current_champion
            self._generate_playlist(current_champion)

    def _get_active_champion(self) -> Champion:
        """
        Get the currently active champion from Riot client.

        Polls repeatedly until a game is active and champion data is available.

        Returns:
            The active champion data
        """
        champion = self.game_state.get_current_champion()

        if not champion:
            logger.info(
                "No active game detected. Waiting for player to enter a match..."
            )

        # Wait until player is in an active game
        while not champion:
            sleep(self.retry_interval)
            champion = self.game_state.get_current_champion()

        return champion

    def _champion_changed(self, current_champion: Champion) -> bool:
        """
        Check if the champion has changed since last check.

        Args:
            current_champion: The current champion data

        Returns:
            True if champion is different from last known champion
        """
        if not self.last_champion:
            return True

        return current_champion.id != self.last_champion.id

    def _generate_playlist(self, champion: Champion) -> None:
        """
        Generate a personalized playlist for the champion.

        Args:
            champion: The champion to generate playlist for
        """
        try:
            logger.info(f"Generating playlist for champion: {champion.name}")
            self.playlist_generator.generate_for_champion(
                champion, max_tracks=TRACK_COUNT
            )
            logger.success(f"Playlist generated successfully for {champion.name}")
        except Exception as e:
            logger.error(
                f"Failed to generate playlist for {champion.name}: {e}", exc_info=True
            )


# Singleton instance for backward compatibility
_monitor_instance: Optional[GameMonitorService] = None


def get_monitor() -> GameMonitorService:
    """
    Get the singleton game monitor instance.

    Returns:
        The shared GameMonitorService instance
    """
    global _monitor_instance
    if _monitor_instance is None:
        _monitor_instance = GameMonitorService()
    return _monitor_instance


def watch() -> None:
    """
    Start game monitoring (backward compatibility function).

    This function maintains compatibility with existing code.
    Creates and starts a GameMonitorService instance.
    """
    monitor = get_monitor()
    monitor.start()
