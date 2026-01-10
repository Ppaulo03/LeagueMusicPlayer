"""
Music player routes - API endpoints for music playback control.
"""

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from loguru import logger

from routes.services.music_player_service import MusicPlayerService

# Initialize router
router = APIRouter(prefix="/player", tags=["Music Player"])

# Initialize service
music_player_service = MusicPlayerService()


@router.get("/next", summary="Get next song in playlist")
async def get_next_song() -> FileResponse:
    """
    Retrieve the next song in the playlist.

    Returns:
        FileResponse: Audio file (MP3) for the next song

    Behavior:
        - Returns next song from queue
        - If queue is empty, cycles back to played songs
        - Adds current song to play history

    Raises:
        HTTPException: 404 if no songs available or file not found
        HTTPException: 500 if playback fails
    """
    try:
        file_path = music_player_service.get_next()

        if not file_path or not file_path.exists():
            logger.warning("Next song file not found or unavailable")
            raise HTTPException(status_code=404, detail="No songs available")

        logger.debug(f"Serving next song: {file_path.name}")
        return FileResponse(
            path=str(file_path),
            media_type="audio/mpeg",
            filename=file_path.name,
            headers={"Accept-Ranges": "bytes", "Cache-Control": "no-cache"},
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting next song: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve next song")


@router.get("/previous", summary="Get previous song in playlist")
async def get_previous_song() -> FileResponse:
    """
    Retrieve the previous song from play history.

    Returns:
        FileResponse: Audio file (MP3) for the previous song

    Behavior:
        - Returns previous song from history
        - Moves current song back to queue
        - Maintains playback position in history

    Raises:
        HTTPException: 404 if no previous songs or file not found
        HTTPException: 500 if playback fails
    """
    try:
        file_path = music_player_service.get_previous()

        if not file_path or not file_path.exists():
            logger.warning("Previous song file not found or unavailable")
            raise HTTPException(status_code=404, detail="No previous songs available")

        logger.debug(f"Serving previous song: {file_path.name}")
        return FileResponse(
            path=str(file_path),
            media_type="audio/mpeg",
            filename=file_path.name,
            headers={"Accept-Ranges": "bytes", "Cache-Control": "no-cache"},
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting previous song: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve previous song")


@router.get("/status", summary="Get player status")
async def get_player_status() -> dict:
    """
    Get current music player status.

    Returns:
        dict: Player status information including:
            - Queue size
            - History size
            - Current song info

    Example:
        ```json
        {
            "queue_size": 5,
            "history_size": 3,
            "has_next": true,
            "has_previous": true
        }
        ```
    """
    try:
        status = music_player_service.get_status()
        return status
    except Exception as e:
        logger.error(f"Error getting player status: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve player status")
