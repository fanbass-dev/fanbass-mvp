from fastapi import FastAPI
from app.routes import events, rankings

app = FastAPI()

# Include routers
app.include_router(events.router, prefix="/events", tags=["events"])
app.include_router(rankings.router, prefix="/rankings", tags=["rankings"])

@app.get("/")
def root():
    return {"message": "Welcome to FanBass API"}
