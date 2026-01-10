"""
Application configuration and constants.
Centralizes all configuration values for easy maintenance.
"""

# Server configuration
DEFAULT_HOST = "127.0.0.1"
PORT_FILE_NAME = "backend_port.json"

# Activity monitoring
INACTIVITY_TIMEOUT = 600  # seconds (10 minutes)
INACTIVITY_CHECK_INTERVAL = 5  # seconds

# Background workers
DOWNLOAD_WORKER_COUNT = 3

# Game monitoring
GAME_MONITOR_POLL_INTERVAL = 2.0  # seconds between game state checks
GAME_MONITOR_RETRY_INTERVAL = 0.5  # seconds between retries when no game active

# API metadata
API_TITLE = "League Music Player API"
API_DESCRIPTION = "API for integrating League of Legends with music recommendations"
API_VERSION = "1.0.0"

# Logging
LOG_LEVEL = "info"
ACCESS_LOG_ENABLED = True
TRACK_COUNT = 50
