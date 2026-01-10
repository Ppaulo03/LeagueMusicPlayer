from pydantic import BaseModel
from typing import List, Any


class Champion(BaseModel):
    id: str
    key: str
    name: str
    title: str
    blurb: str
    tags: List[str]
    splash: Any
    palette: List[str]
    region: str = ""  # Optional field for champion region
