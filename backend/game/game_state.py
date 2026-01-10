"""
Game state manager - Tracks current League of Legends game state.
Monitors active games and provides real-time status information.
"""

from io import BytesIO
from typing import Any, Dict, Optional

from loguru import logger

from integrations.riot_client import RiotGameClient
from schemas import Champion


class GameStateManager:
    """
    Manager for League of Legends game state.

    Provides high-level access to current game information and champion data.
    """

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(GameStateManager, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        """Initialize the game state manager."""
        if self._initialized:
            return

        self.riot_client = RiotGameClient()
        self._initialized = True

    def get_current_champion(self) -> Optional[Champion]:
        """
        Get the currently active champion in game.

        Returns:
            Champion object if in game, None otherwise
        """
        try:
            champion = self.riot_client.get_current_champion()

            if champion:
                logger.debug(f"Current champion: {champion.name}")
            else:
                logger.debug("No active game or champion")

            return champion

        except Exception as e:
            logger.error(f"Error getting current champion: {e}")
            return None

    def get_game_status(self) -> Dict[str, Any]:
        """
        Get current game status.

        Returns:
            Dictionary with game state information:
                - isPlaying: Whether in an active game
                - championName: Current champion name
                - championSkin: Current skin ID
                - championPalette: Color palette
                - gameMode: Current game mode
                - gameTime: Game time in seconds
        """
        try:
            status = self.riot_client.get_game_status()
            logger.debug(f"Game status: {status.get('isPlaying', False)}")
            return status

        except Exception as e:
            logger.error(f"Error getting game status: {e}")
            return {
                "isPlaying": False,
                "championName": None,
                "championSkin": None,
                "championPalette": None,
                "gameMode": None,
                "gameTime": None,
            }

    def get_splash_art(self) -> Optional[BytesIO]:
        """
        Get splash art for current champion.

        Returns:
            BytesIO with image data or None
        """
        try:
            splash = self.riot_client.get_splash_art()

            if splash:
                logger.debug("Retrieved current splash art")
            else:
                logger.debug("No splash art available")

            return splash

        except Exception as e:
            logger.error(f"Error getting splash art: {e}")
            return None

    def is_in_game(self) -> bool:
        """
        Check if player is in an active game.

        Returns:
            True if in game, False otherwise
        """
        try:
            in_game = self.riot_client.is_in_game()
            return in_game

        except Exception as e:
            logger.error(f"Error checking game status: {e}")
            return False

    def reset(self) -> None:
        """Reset game state."""
        try:
            self.riot_client.reset()
            logger.info("Game state reset")

        except Exception as e:
            logger.error(f"Error resetting game state: {e}")

    def wait_for_game(self) -> Optional[Champion]:
        """
        Block until a game starts and return the champion.

        Returns:
            Champion object when game starts, or None if interrupted
        """
        import time

        logger.info("Waiting for game to start...")

        while True:
            try:
                champion = self.get_current_champion()
                if champion:
                    logger.info(f"Game started with champion: {champion.name}")
                    return champion

                time.sleep(1)  # Poll every second

            except KeyboardInterrupt:
                logger.info("Wait interrupted")
                return None
            except Exception as e:
                logger.error(f"Error waiting for game: {e}")
                time.sleep(5)  # Wait longer on error
