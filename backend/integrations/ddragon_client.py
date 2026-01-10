"""
Data Dragon API client for League of Legends champion data.
Handles champion information, splash arts, and color palettes.
"""

import json
from io import BytesIO
from pathlib import Path
from typing import List, Optional

import colorgram
import requests
from loguru import logger
from PIL import Image

from schemas import Champion

# Constants
DDRAGON_BASE_URL = "https://ddragon.leagueoflegends.com"
DEFAULT_LOCALE = "pt_BR"
DEFAULT_SKIN_NUMBER = 0


class DataDragonClient:
    """
    Client for Riot's Data Dragon API.

    Provides access to champion data, splash arts, and related assets.
    """

    def __init__(self, locale: str = DEFAULT_LOCALE):
        """
        Initialize the Data Dragon client.

        Args:
            locale: Language/region code (default: pt_BR)
        """
        self.base_url = DDRAGON_BASE_URL
        self.locale = locale
        self._version_cache: Optional[str] = None

    def get_latest_version(self) -> str:
        """
        Get the latest Data Dragon version.

        Returns:
            Version string (e.g., "13.24.1")

        Raises:
            requests.RequestException: If API request fails
        """
        if self._version_cache:
            return self._version_cache

        try:
            url = f"{self.base_url}/api/versions.json"
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            versions = response.json()

            if not versions:
                raise ValueError("No versions available")

            self._version_cache = versions[0]
            logger.debug(f"Latest Data Dragon version: {self._version_cache}")
            return self._version_cache

        except Exception as e:
            logger.error(f"Error fetching Data Dragon version: {e}")
            raise

    def get_champion_data(
        self,
        champion_key: str,
        version: Optional[str] = None,
        skin_number: int = DEFAULT_SKIN_NUMBER,
        by_name: bool = False,
    ) -> Optional[Champion]:
        """
        Get champion data by ID or name.

        Args:
            champion_key: Champion ID or name
            version: Data Dragon version (uses latest if None)
            skin_number: Skin index for splash art (default: 0)
            by_name: Whether to search by name instead of ID

        Returns:
            Champion object with all data, or None if not found
        """
        try:
            if version is None:
                version = self.get_latest_version()

            # Fetch all champions
            url = f"{self.base_url}/cdn/{version}/data/{self.locale}/champion.json"
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            champions = response.json()

            # Search for champion
            search_key = "name" if by_name else "key"
            for champ_id, champ_data in champions["data"].items():
                if champ_data[search_key] == champion_key:

                    detail_url = f"{self.base_url}/cdn/{version}/data/{self.locale}/champion/{champ_id}.json"
                    detail_resp = requests.get(detail_url, timeout=10)
                    detail_resp.raise_for_status()
                    detailed_data = detail_resp.json()

                    skins_list = detailed_data["data"][champ_id]["skins"]
                    valid_skin_nums = [skin["num"] for skin in skins_list]
                    actual_skin_num = max(
                        [num for num in valid_skin_nums if num <= skin_number],
                        default=0,
                    )

                    champ_data["splash"] = self.get_champion_splash(
                        champ_data["id"], actual_skin_num
                    )
                    champ_data["palette"] = self.generate_color_palette(
                        champ_data["splash"]
                    )

                    logger.debug(f"Found champion: {champ_data['name']}")
                    return Champion(**champ_data)

            logger.warning(f"Champion not found: {champion_key}")
            return None

        except Exception as e:
            logger.error(f"Error fetching champion data for {champion_key}: {e}")
            return None

    def get_champion_splash(
        self, champion_id: str, skin_number: int = DEFAULT_SKIN_NUMBER
    ) -> Optional[BytesIO]:
        """
        Get champion splash art image.

        Args:
            champion_id: Champion ID
            skin_number: Skin index (default: 0 for base skin)

        Returns:
            BytesIO object containing image data, or None if failed
        """
        try:
            url = (
                f"{self.base_url}/cdn/img/champion/splash/"
                f"{champion_id}_{skin_number}.jpg"
            )
            response = requests.get(url, timeout=10)
            response.raise_for_status()

            logger.debug(f"Retrieved splash art for {champion_id} skin {skin_number}")
            return BytesIO(response.content)

        except Exception as e:
            logger.error(
                f"Error fetching splash art for {champion_id} skin {skin_number}: {e}"
            )
            return None

    def get_dominant_colors(
        self, image: Image.Image, num_colors: int = 5
    ) -> List[dict]:
        """
        Extract dominant colors from an image.

        Args:
            image: PIL Image object
            num_colors: Number of colors to extract

        Returns:
            List of color dictionaries with RGB, hex, and proportion
        """
        try:
            colors = colorgram.extract(image, num_colors)
            result = []

            for color in colors:
                rgb = color.rgb
                result.append(
                    {
                        "rgb": (rgb.r, rgb.g, rgb.b),
                        "hex": f"#{rgb.r:02x}{rgb.g:02x}{rgb.b:02x}",
                        "proportion": color.proportion,
                    }
                )

            return result

        except Exception as e:
            logger.error(f"Error extracting colors: {e}")
            return []

    def generate_color_palette(
        self, image_stream: BytesIO, num_colors: int = 5
    ) -> List[str]:
        """
        Generate color palette from image stream.

        Args:
            image_stream: BytesIO containing image data
            num_colors: Number of colors in palette

        Returns:
            List of hex color strings
        """
        try:
            image_stream.seek(0)  # Reset stream position
            image = Image.open(image_stream)
            colors = self.get_dominant_colors(image, num_colors)
            palette = [color["hex"] for color in colors]

            logger.debug(f"Generated palette with {len(palette)} colors")
            return palette

        except Exception as e:
            logger.error(f"Error generating palette: {e}")
            return []

    def get_all_champions(self, version: Optional[str] = None) -> Optional[dict]:
        """
        Get all champions data.

        Args:
            version: Data Dragon version (uses latest if None)

        Returns:
            Dictionary with all champions data
        """
        try:
            if version is None:
                version = self.get_latest_version()

            url = f"{self.base_url}/cdn/{version}/data/{self.locale}/champion.json"
            response = requests.get(url, timeout=10)
            response.raise_for_status()

            data = response.json()
            logger.debug(f"Retrieved {len(data.get('data', {}))} champions")
            return data

        except Exception as e:
            logger.error(f"Error fetching all champions: {e}")
            return None
