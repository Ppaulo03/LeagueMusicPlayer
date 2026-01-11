"""
Application configuration and constants.
Centralizes all configuration values for easy maintenance.
"""

# Server configuration
from pathlib import Path
import sys


DEFAULT_HOST = "127.0.0.1"
PORT_FILE_NAME = "backend_port.json"

# Activity monitoring
INACTIVITY_TIMEOUT = 600  # seconds (10 minutes)
INACTIVITY_CHECK_INTERVAL = 5  # seconds

# Background workers
DOWNLOAD_WORKER_COUNT = 3

# Game monitoring'
GAME_MONITOR_POLL_INTERVAL = 60  # seconds between game state checks
GAME_MONITOR_RETRY_INTERVAL = 20  # seconds between retries when no game active

# API metadata
API_TITLE = "League Music Player API"
API_DESCRIPTION = "API for integrating League of Legends with music recommendations"
API_VERSION = "1.0.0"

# Logging
LOG_LEVEL = "info"
ACCESS_LOG_ENABLED = True
TRACK_COUNT = 50


BASE_DIR = ""
if getattr(sys, "frozen", False):
    base_path = Path(sys.executable).parent
    internal_path = base_path / "_internal"
    if internal_path.exists():
        BASE_DIR = internal_path
    else:
        BASE_DIR = base_path
else:
    BASE_DIR = Path(__file__).parent.parent
