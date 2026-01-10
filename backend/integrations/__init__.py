"""
External API integrations package.
Contains clients for external services (Riot, Last.fm, MusicBrainz, etc.)
"""

from .ddragon_client import DataDragonClient
from .riot_client import RiotGameClient

__all__ = [
    "DataDragonClient",
    "RiotGameClient",
]
