"""
Recommendation engine - Generates music recommendations for champions.
Combines style inference with music discovery to create personalized playlists.
"""

import random
from collections import Counter
from typing import List

from loguru import logger

from schemas import Champion
from .dj_lol import gerar_playlist


class RecommendationEngine:
    """
    Engine for generating music recommendations.

    Uses champion characteristics to discover appropriate music tracks.
    """

    def get_recommendations(
        self, champion: Champion, max_tracks: int = 100
    ) -> List[str]:
        """
        Get music recommendations for a champion.

        Args:
            champion: Champion to generate recommendations for
            max_tracks: Maximum number of tracks to return

        Returns:
            List of track strings in format "Track Name - Artist Name"
        """
        try:
            playlist = gerar_playlist(champion.name, total_alvo=max_tracks)
            return playlist

        except Exception as e:
            logger.error(f"Error generating recommendations for {champion.name}: {e}")
            return []

    def _get_tracks_by_style(self, style: str) -> List[str]:
        """Get tracks for a specific music style/tag."""
        try:
            tracks = self.lastfm.get_tracks_by_tag(style)
            return tracks

        except Exception as e:
            logger.error(f"Error fetching tracks for style '{style}': {e}")
            return []

    def _get_similar_tracks(self, champion: Champion) -> List[str]:
        """Get similar tracks based on champion's associated music."""
        try:
            champ_config = self.champion_styles.get(champion.name, {})
            mbid = champ_config.get("musica", {}).get("mbid")

            if not mbid:
                return []

            similar_tracks = self.lastfm.get_similar_tracks(mbid)
            return similar_tracks

        except Exception as e:
            logger.error(f"Error fetching similar tracks for {champion.name}: {e}")
            return []

    def _generate_weighted_playlist(
        self, track_counter: Counter, max_tracks: int
    ) -> List[str]:
        """
        Generate a weighted random playlist from track counter.

        Args:
            track_counter: Counter with track names and weights
            max_tracks: Maximum number of tracks

        Returns:
            List of track names
        """
        if not track_counter:
            logger.warning("No tracks available for playlist generation")
            return []

        # Get tracks and weights
        tracks = list(track_counter.keys())
        weights = list(track_counter.values())

        # Limit to available tracks or max_tracks
        n_tracks = min(len(tracks), max_tracks)

        # Generate weighted random selection
        try:
            playlist = random.choices(tracks, weights=weights, k=n_tracks)
            return playlist

        except Exception as e:
            logger.error(f"Error generating weighted playlist: {e}")
            # Fallback to simple random selection
            return random.sample(tracks, min(n_tracks, len(tracks)))
