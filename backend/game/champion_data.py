"""
Champion data service - High-level champion data management.
Provides easy access to champion information and assets from Data Dragon API.
"""

from io import BytesIO
from typing import List, Optional

from loguru import logger

from integrations.ddragon_client import DataDragonClient
from schemas import Champion


class ChampionDataService:
    """
    Service for managing League of Legends champion data.

    Provides high-level methods for champion information access from Data Dragon.
    """

    def __init__(self):
        """Initialize the champion service."""
        self.ddragon = DataDragonClient()

    def get_champion(
        self, identifier: str, skin_number: int = 0, by_name: bool = False
    ) -> Optional[Champion]:
        """
        Get champion data by ID or name.

        Args:
            identifier: Champion ID or name
            skin_number: Skin index for splash art
            by_name: Whether to search by name instead of ID

        Returns:
            Champion object or None if not found
        """
        try:
            champion = self.ddragon.get_champion_data(
                identifier, skin_number=skin_number, by_name=by_name
            )

            if champion:
                logger.debug(f"Retrieved champion: {champion.name}")
            else:
                logger.warning(f"Champion not found: {identifier}")

            return champion

        except Exception as e:
            logger.error(f"Error retrieving champion {identifier}: {e}")
            return None

    def get_champion_by_name(
        self, name: str, skin_number: int = 0
    ) -> Optional[Champion]:
        """
        Get champion by name.

        Args:
            name: Champion name
            skin_number: Skin index

        Returns:
            Champion object or None
        """
        return self.get_champion(name, skin_number=skin_number, by_name=True)

    def get_champion_by_id(
        self, champion_id: str, skin_number: int = 0
    ) -> Optional[Champion]:
        """
        Get champion by ID.

        Args:
            champion_id: Champion ID
            skin_number: Skin index

        Returns:
            Champion object or None
        """
        return self.get_champion(champion_id, skin_number=skin_number, by_name=False)

    def get_splash_art(
        self, champion_id: str, skin_number: int = 0
    ) -> Optional[BytesIO]:
        """
        Get champion splash art.

        Args:
            champion_id: Champion ID
            skin_number: Skin index

        Returns:
            BytesIO with image data or None
        """
        try:
            splash = self.ddragon.get_champion_splash(champion_id, skin_number)
            if splash:
                logger.debug(
                    f"Retrieved splash art for {champion_id} skin {skin_number}"
                )
            return splash

        except Exception as e:
            logger.error(f"Error retrieving splash art: {e}")
            return None

    def get_color_palette(
        self, image_stream: BytesIO, num_colors: int = 5
    ) -> List[str]:
        """
        Generate color palette from image.

        Args:
            image_stream: Image data
            num_colors: Number of colors to extract

        Returns:
            List of hex color strings
        """
        try:
            palette = self.ddragon.generate_color_palette(image_stream, num_colors)
            logger.debug(f"Generated palette with {len(palette)} colors")
            return palette

        except Exception as e:
            logger.error(f"Error generating palette: {e}")
            return []

    def get_all_champions(self) -> Optional[dict]:
        """
        Get all champions data.

        Returns:
            Dictionary with all champions or None
        """
        try:
            champions = self.ddragon.get_all_champions()
            if champions:
                count = len(champions.get("data", {}))
                logger.debug(f"Retrieved {count} champions")
            return champions

        except Exception as e:
            logger.error(f"Error retrieving all champions: {e}")
            return None
