from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import events, rankings

app = FastAPI()

# ✅ CORS setup to allow frontend to talk to backend
origins = [
    "https://fanbass-mvp.vercel.app",
    "https://app.fanbass.io",  # Add any future domains here too
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(events.router, prefix="/events", tags=["events"])
app.include_router(rankings.router, prefix="/rankings", tags=["rankings"])

@app.get("/")
def root():
    return {"message": "Welcome to FanBass API"}
