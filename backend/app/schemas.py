from pydantic import BaseModel
from uuid import UUID
from typing import List

class ArtistRanking(BaseModel):
    artist_id: UUID
    rank: int

class Event(BaseModel):
    id: UUID
    name: str
    artist_ids: List[UUID]

class ReorderedEvent(BaseModel):
    id: UUID
    name: str
    reordered_lineup: List[UUID]
