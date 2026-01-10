"""
Activity monitoring and idle shutdown management.
Tracks request activity and shuts down the application when idle.
"""

import asyncio
import os
import time

from loguru import logger

from config import INACTIVITY_CHECK_INTERVAL, INACTIVITY_TIMEOUT

# Global state for activity tracking
_last_request_time = time.time()


def update_activity() -> None:
    """Update the last request timestamp to indicate recent activity."""
    global _last_request_time
    _last_request_time = time.time()


def get_idle_time() -> float:
    """
    Get the current idle time in seconds.

    Returns:
        Number of seconds since the last request
    """
    return time.time() - _last_request_time


async def shutdown_monitor() -> None:
    """
    Monitor application activity and shutdown if idle for too long.

    Continuously checks for inactivity and terminates the application
    if no requests have been received within the configured timeout period.
    """
    logger.info(
        f"Starting inactivity monitor (timeout: {INACTIVITY_TIMEOUT}s, "
        f"check interval: {INACTIVITY_CHECK_INTERVAL}s)"
    )

    while True:
        await asyncio.sleep(INACTIVITY_CHECK_INTERVAL)
        idle_time = get_idle_time()

        if idle_time > INACTIVITY_TIMEOUT:
            logger.warning(
                f"No activity detected for {idle_time:.1f}s "
                f"(threshold: {INACTIVITY_TIMEOUT}s). Shutting down..."
            )
            os._exit(0)
