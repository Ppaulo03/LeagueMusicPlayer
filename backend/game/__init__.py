"""
Game package - League of Legends game state and champion management.

This package provides:
- Champion data access (champion_data.py)
- Game state tracking (game_state.py)
- Game monitoring service (monitor.py)
"""

from .game_state import GameStateManager
from .monitor import GameMonitorService

__all__ = [
    "ChampionDataService",
    "GameStateManager",
    "GameMonitorService",
]
