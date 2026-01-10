"""
Game status service - Business logic for game state information.
"""

from typing import Any, Dict, Optional

from loguru import logger

from game.game_state import GameStateManager
from integrations.ddragon_client import DataDragonClient


class GameStatusService:
    """Service for retrieving League of Legends game status."""

    def __init__(self):
        """Initialize the game status service."""
        self.game_state = GameStateManager()
        self.ddragon_client = DataDragonClient()

    def get_status(self) -> Optional[Dict[str, Any]]:
        """
        Get current game status from Riot client.

        Returns:
            Dictionary with game status information, or None if no active game

        Example:
            {
                "champion": "Ahri",
                "championId": 103,
                "gameMode": "CLASSIC",
                "region": "NA"
            }
        """
        try:
            status = self.game_state.get_game_status()

            if status:
                logger.debug(
                    f"Retrieved game status for champion: {getattr(status, 'name', 'Unknown')}"
                )
                # Convert to dict if it's a model object
                if hasattr(status, "__dict__"):
                    return status.__dict__
                return status
            else:
                logger.debug("No active game found")
                return None

        except Exception as e:
            logger.error(f"Error retrieving game status: {e}")
            raise

    def get_splash_art(self) -> Optional[bytes]:
        """
        Get splash art for the currently active champion.

        Returns:
            Image bytes stream, or None if no splash art available
        """
        try:
            # Get current champion
            champion = self.game_state.get_current_champion()

            if not champion:
                logger.debug("No active champion for splash art")
                return None

            # Get splash art for the champion
            splash = self.game_state.get_splash_art()

            if splash:
                logger.debug(f"Retrieved splash art for {champion.name}")
            else:
                logger.debug(f"No splash art available for {champion.name}")

            return splash

        except Exception as e:
            logger.error(f"Error retrieving splash art: {e}")
            raise
