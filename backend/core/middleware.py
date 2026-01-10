"""
Application middleware components.
Contains custom middleware for request processing.
"""

from fastapi import Request, Response

from core.monitoring import update_activity


async def track_activity_middleware(request: Request, call_next) -> Response:
    """
    Middleware to track request activity for idle shutdown monitoring.

    Updates the last request timestamp on every incoming request to prevent
    premature shutdown during active use.

    Args:
        request: The incoming request
        call_next: The next middleware/handler in the chain

    Returns:
        The response from the request handler
    """
    update_activity()
    response = await call_next(request)
    return response
