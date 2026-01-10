"""
Route services package - Business logic for route handlers.

Note: Champion and Region style services have been moved to game/ package.
Only thin API wrapper services remain here.
"""

from .game_status_service import GameStatusService
from .music_player_service import MusicPlayerService

__all__ = [
    "GameStatusService",
    "MusicPlayerService",
]
