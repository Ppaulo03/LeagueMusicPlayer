from typing import Optional, List
from io import BytesIO


class GameData:
    champion: Optional[str] = ""
    champion_skin: Optional[str] = ""
    skin_splash: Optional[BytesIO] = None
    skin_colors: List[str] = []
    game_mode: Optional[str] = ""
    game_time: Optional[str] = ""
    is_playing: bool = False
