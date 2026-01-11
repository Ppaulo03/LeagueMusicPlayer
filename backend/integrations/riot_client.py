"""
Riot Game Client for local League of Legends game state.
Connects to the local Riot client API to get real-time game information.
"""

from io import BytesIO
from typing import Any, Dict, Optional

import requests
import urllib3
from loguru import logger

from integrations.ddragon_client import DataDragonClient
from schemas import Champion, GameData

# Disable SSL warnings for local connections
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Constants
RIOT_LOCAL_API_URL = "https://127.0.0.1:2999/liveclientdata/allgamedata"
REQUEST_TIMEOUT = 5


class RiotGameClient:
    """
    Client for Riot's local game API.

    Monitors active League of Legends games and provides real-time game state.
    """

    def __init__(self):
        """Initialize the Riot Game Client."""
        self.api_url = RIOT_LOCAL_API_URL
        self.ddragon_client = DataDragonClient()
        self.game_data = GameData()
        self._current_champion: Optional[Champion] = None

    def get_current_champion(self) -> Optional[Champion]:
        """
        Get the currently active champion in game.

        Returns:
            Champion object if in an active game, None otherwise
        """
        try:
            response = requests.get(self.api_url, verify=False, timeout=REQUEST_TIMEOUT)
            response.raise_for_status()
            data = response.json()
            # Get active player info
            user = data["activePlayer"]
            user_id = user["riotIdGameName"]
            user_tagline = user["riotIdTagLine"]
            user_full_id = f"{user_id}#{user_tagline}"

            # Find player in all players
            all_players = data["allPlayers"]
            for player in all_players:
                if player["riotId"] != user_full_id:
                    continue

                # Update game data
                self.game_data.is_playing = True
                self.game_data.game_mode = data["gameData"]["gameMode"]
                self.game_data.game_time = data["gameData"]["gameTime"]

                # Check if champion changed
                champion_name = player["championName"]
                champion_skin = str(player["skinID"])

                if (
                    self.game_data.champion != champion_name
                    or self.game_data.champion_skin != champion_skin
                ):
                    logger.info(
                        f"Champion changed: {champion_name} (skin: {champion_skin})"
                    )

                    # Update game data
                    self.game_data.champion = champion_name
                    self.game_data.champion_skin = champion_skin

                    # Fetch champion data from Data Dragon
                    self._current_champion = self.ddragon_client.get_champion_data(
                        champion_name,
                        skin_number=int(champion_skin),
                        by_name=True,
                    )

                    if self._current_champion:
                        self.game_data.skin_splash = self._current_champion.splash
                        self.game_data.skin_colors = self._current_champion.palette

                return self._current_champion

            # Player not found in game
            self.game_data.is_playing = False
            return None

        except requests.exceptions.ConnectionError:
            self.game_data.is_playing = False
            return None

        except requests.exceptions.HTTPError as http_err:
            if http_err.response.status_code != 404:
                logger.error(f"Erro HTTP: {http_err}", exc_info=True)
            self.game_data.is_playing = False
            return None

        except requests.exceptions.Timeout:
            logger.warning("Timeout connecting to Riot client")
            self.game_data.is_playing = False
            return None

        except Exception as e:
            logger.error(f"Error getting current champion: {e}", exc_info=True)
            self.game_data.is_playing = False
            return None

        finally:
            if not self.game_data.is_playing:
                self.reset()

    def get_game_status(self) -> Dict[str, Any]:
        """
        Get current game status information.

        Returns:
            Dictionary with game state including:
                - isPlaying: Whether player is in an active game
                - championName: Current champion name
                - championSkin: Current skin ID
                - championPalette: Color palette from splash art
                - gameMode: Current game mode
                - gameTime: Current game time in seconds
        """

        return {
            "isPlaying": self.game_data.is_playing,
            "championName": self.game_data.champion,
            "championSkin": self.game_data.champion_skin,
            "championPalette": self.game_data.skin_colors,
            "gameMode": self.game_data.game_mode,
            "gameTime": self.game_data.game_time,
        }

    def get_splash_art(self) -> Optional[BytesIO]:
        """
        Get the splash art for the current champion skin.

        Returns:
            BytesIO containing splash art image, or None if not available
        """
        if self.game_data.skin_splash:
            self.game_data.skin_splash.seek(0)
            return self.game_data.skin_splash

        return None

    def is_in_game(self) -> bool:
        """
        Check if player is currently in an active game.

        Returns:
            True if in game, False otherwise
        """
        return self.game_data.is_playing

    def reset(self) -> None:
        """Reset game state data."""
        self.game_data = GameData()
        self._current_champion = None
        logger.debug("Game state reset")
