from fastapi import APIRouter, Depends
from typing import List, Dict
from app.schemas import ArtistRanking

router = APIRouter()

# Simulate getting the user ID (replace with real auth later)
def get_current_user_id():
    return "user-123"

# In-memory storage: user_id → list of ArtistRanking
user_rankings: Dict[str, List[ArtistRanking]] = {}

@router.post("/", response_model=dict)
def submit_rankings(
    rankings: List[ArtistRanking],
    user_id: str = Depends(get_current_user_id)
):
    user_rankings[user_id] = rankings
    return {"message": f"Saved {len(rankings)} artist rankings for user {user_id}"}

@router.get("/", response_model=List[ArtistRanking])
def get_user_rankings(user_id: str = Depends(get_current_user_id)):
    return user_rankings.get(user_id, [])
