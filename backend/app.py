"""
FastAPI application for Riot Spotify integration.
Handles game state monitoring, music recommendations, and Spotify integration.
"""

from fastapi import FastAPI


# Import after environment is loaded
from config import API_DESCRIPTION, API_TITLE, API_VERSION
from core import lifespan, run_server, track_activity_middleware
from routes import (
    configs_router,
    game_router,
    player_router,
)


def create_app() -> FastAPI:
    """
    Create and configure the FastAPI application.

    Returns:
        Configured FastAPI application instance
    """
    # Create FastAPI application
    app = FastAPI(
        title=API_TITLE,
        description=API_DESCRIPTION,
        version=API_VERSION,
        lifespan=lifespan,
    )

    # Register middleware
    app.middleware("http")(track_activity_middleware)

    # Register routers
    app.include_router(configs_router)
    app.include_router(game_router)
    app.include_router(player_router)

    # Health check endpoint'
    @app.get("/ping", tags=["Health"])
    async def health_check():
        """Health check endpoint to verify API is running."""
        return {"status": "ok", "message": "pong"}

    return app


# Create application instance"
app = create_app()


if __name__ == "__main__":
    run_server(app)
