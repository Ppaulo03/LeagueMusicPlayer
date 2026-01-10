"""
Application lifecycle management.
Handles startup and shutdown of background services.
"""

import asyncio
import threading
from contextlib import asynccontextmanager
from typing import Callable

from fastapi import FastAPI
from loguru import logger

from config import (
    DOWNLOAD_WORKER_COUNT,
    GAME_MONITOR_POLL_INTERVAL,
    GAME_MONITOR_RETRY_INTERVAL,
)
from core.monitoring import shutdown_monitor
from music.download import MusicDownloader
from game import GameMonitorService


def start_background_thread(target: Callable, name: str = None) -> threading.Thread:
    """
    Start a daemon thread for background tasks.

    Args:
        target: The function to run in the thread
        name: Optional descriptive name for the thread

    Returns:
        The started thread object
    """
    thread = threading.Thread(target=target, daemon=True, name=name)
    thread.start()
    logger.debug(f"Started background thread: {name or 'unnamed'}")
    return thread


def startup_services() -> None:
    """
    Start all background services required by the application.

    Services started:
        - Game state monitoring
        - Inactivity shutdown monitor
        - Music download workers
    """
    logger.info("Starting background services...")

    # Start game monitoring
    monitor = GameMonitorService(
        poll_interval=GAME_MONITOR_POLL_INTERVAL,
        retry_interval=GAME_MONITOR_RETRY_INTERVAL,
    )
    start_background_thread(target=monitor.start, name="GameMonitor")

    # Start inactivity monitor
    start_background_thread(
        target=lambda: asyncio.run(shutdown_monitor()), name="InactivityMonitor"
    )

    # Start download workers
    for i in range(DOWNLOAD_WORKER_COUNT):
        start_background_thread(
            target=MusicDownloader().download_worker, name=f"DownloadWorker-{i+1}"
        )

    logger.info(
        f"All background services started successfully ({DOWNLOAD_WORKER_COUNT} download workers)"
    )


def shutdown_services() -> None:
    """
    Gracefully shutdown all background services and cleanup resources.

    Cleanup tasks:
        - Remove temporary cache directory
        - Stop all download worker threads
    """
    logger.info("Shutting down background services...")

    # Get downloader instance and cleanup
    downloader = MusicDownloader()

    # Signal download workers to stop
    for _ in range(DOWNLOAD_WORKER_COUNT):
        downloader.download_queue.put(None)

    # Clean up cache directory
    downloader.cleanup()

    logger.info("Shutdown complete")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Manage FastAPI application lifecycle.

    Startup phase:
        - Initialize and start all background services

    Shutdown phase:
        - Cleanup resources and stop background services

    Args:
        app: The FastAPI application instance
    """
    # Startup
    startup_services()

    yield

    # Shutdown
    shutdown_services()
