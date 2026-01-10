"""
Game status routes - API endpoints for current game state information.
"""

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse, Response, StreamingResponse
from loguru import logger

from routes.services.game_status_service import GameStatusService

# Initialize router
router = APIRouter(prefix="/game-status", tags=["Game Status"])

# Initialize service
game_status_service = GameStatusService()


@router.get("", summary="Get current game status")
async def get_game_status() -> JSONResponse:
    """
    Retrieve the current League of Legends game status.

    Returns:
        JSONResponse: Current game state information including:
            - Active champion
            - Game mode
            - Game time
            - Player info

    Example:
        ```json
        {
            "champion": "Ahri",
            "championId": 103,
            "gameMode": "CLASSIC",
            "gameTime": 1234
        }
        ```

    Raises:
        HTTPException: 404 if no active game, 500 if status check fails
    """
    try:
        status = game_status_service.get_status()

        if not status:
            raise HTTPException(status_code=404, detail="No active game found")
        return JSONResponse(content=status)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving game status: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve game status")


@router.get("/splash", summary="Get champion splash art")
async def get_champion_splash() -> StreamingResponse:
    """
    Retrieve the splash art for the currently active champion.

    Returns:
        StreamingResponse: JPEG image of champion splash art
        Response: Empty 404 response if no splash art available

    Raises:
        HTTPException: 500 if splash art retrieval fails
    """
    try:
        splash_stream = game_status_service.get_splash_art()

        if not splash_stream:
            logger.debug("No splash art available for current champion")
            return Response(status_code=404)

        return StreamingResponse(
            splash_stream,
            media_type="image/jpeg",
            headers={
                "Cache-Control": "public, max-age=3600",
                "Content-Disposition": "inline",
            },
        )

    except Exception as e:
        logger.error(f"Error retrieving splash art: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve splash art")
