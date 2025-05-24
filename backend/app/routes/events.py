from fastapi import APIRouter, Depends
from app.schemas import Event, ReorderedEvent
from app.routes.rankings import user_rankings, get_current_user_id
from typing import List
from uuid import uuid4, UUID

router = APIRouter()

# Simulated in-memory events
events: List[Event] = [
    Event(
        id=uuid4(),
        name="Bass Carnival",
        artist_ids=[
            UUID("11111111-1111-1111-1111-111111111111"),
            UUID("33333333-3333-3333-3333-333333333333"),
            UUID("22222222-2222-2222-2222-222222222222")
        ]
    )
]

@router.get("/", response_model=List[ReorderedEvent])
def get_events(user_id: str = Depends(get_current_user_id)):
    rankings = user_rankings.get(user_id, [])
    ranking_dict = {r.artist_id: r.rank for r in rankings}

    reordered = []
    for event in events:
        reordered_lineup = sorted(
            event.artist_ids,
            key=lambda aid: ranking_dict.get(aid, 9999)  # unranked artists go last
        )
        reordered.append(
            ReorderedEvent(
                id=event.id,
                name=event.name,
                reordered_lineup=reordered_lineup
            )
        )
    return reordered
