"""
Playlist generator - High-level playlist generation and management.
Coordinates recommendation and download for complete playlist creation.
"""

from loguru import logger

from music.download import MusicDownloader
from music.queue import PlaybackQueue
from music.recommendations import RecommendationEngine
from schemas import Champion


class PlaylistGenerator:
    """
    High-level playlist generator.

    Coordinates music recommendation and download to create complete playlists.
    """

    def __init__(self):
        """Initialize the playlist generator."""
        self.recommendation_engine = RecommendationEngine()
        self.downloader = MusicDownloader()
        self.queue = PlaybackQueue()

    def generate_for_champion(self, champion: Champion, max_tracks: int = 100) -> None:
        """
        Generate and queue a playlist for a champion.

        Args:
            champion: Champion to generate playlist for
            max_tracks: Maximum number of tracks
        """
        try:
            logger.info(f"Generating playlist for {champion.name}")

            # Get recommendations
            tracks = self.recommendation_engine.get_recommendations(
                champion, max_tracks=max_tracks
            )

            if not tracks:
                logger.warning(f"No tracks found for {champion.name}")
                return

            # Clear existing playlist
            self.queue.clear_all()
            logger.debug("Cleared existing playlist")

            # Queue tracks for download
            for track in tracks:
                self.downloader.queue_download(track)

            logger.info(
                f"Queued {len(tracks)} tracks for download " f"for {champion.name}"
            )

        except Exception as e:
            logger.error(f"Error generating playlist for {champion.name}: {e}")
