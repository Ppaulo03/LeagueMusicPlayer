"""
Music package - Music recommendation, download, and playback system.

This package provides:
- Style inference from game state (champion/region styles)
- Music recommendations based on styles
- Playlist generation
- Music downloads from YouTube
- Playback queue management
"""

from .download import MusicDownloader
from .playlist import PlaylistGenerator
from .queue import PlaybackQueue
from .recommendations import RecommendationEngine

__all__ = [
    # Main classes
    "RecommendationEngine",
    "PlaylistGenerator",
    "MusicDownloader",
    "PlaybackQueue",
]
