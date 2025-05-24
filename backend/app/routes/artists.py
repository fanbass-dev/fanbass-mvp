from fastapi import APIRouter
from uuid import UUID

router = APIRouter()

# Mocked artist data
ARTISTS = {
    UUID("11111111-1111-1111-1111-111111111111"): "Skrillex",
    UUID("22222222-2222-2222-2222-222222222222"): "REZZ",
    UUID("33333333-3333-3333-3333-333333333333"): "Of The Trees",
}

@router.get("/")
def get_artists():
    return [{"id": str(id), "name": name} for id, name in ARTISTS.items()]
