"""Routes package - API endpoint definitions."""

from .configs import router as configs_router
from .game import router as game_router
from .player import router as player_router

__all__ = [
    "configs_router",
    "game_router",
    "player_router",
]
