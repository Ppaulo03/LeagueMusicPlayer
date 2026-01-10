"""
Server utilities for port management and server execution.
Handles dynamic port allocation and server startup.
"""

import json
import socket
import tempfile
import traceback
from pathlib import Path

from loguru import logger

from config import DEFAULT_HOST, LOG_LEVEL, PORT_FILE_NAME, ACCESS_LOG_ENABLED


def get_available_port() -> int:
    """
    Find and return an available port on localhost.

    Uses OS-level socket binding to find a free port automatically.

    Returns:
        An available port number
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("", 0))
        s.listen(1)
        port = s.getsockname()[1]

    logger.debug(f"Found available port: {port}")
    return port


def save_port_to_file(port: int) -> Path:
    """
    Save the server port to a temporary file for inter-process communication.

    This allows external processes (like frontends) to discover the server port.

    Args:
        port: The port number to save

    Returns:
        Path to the created port file
    """
    temp_dir = Path(tempfile.gettempdir())
    port_file = temp_dir / PORT_FILE_NAME

    try:
        with open(port_file, "w") as f:
            json.dump({"port": port}, f)

        logger.info(f"Port information saved to: {port_file}")
        return port_file

    except Exception as e:
        logger.error(f"Failed to save port file: {e}")
        raise


def run_server(app) -> None:
    """
    Start the FastAPI server with uvicorn.

    Automatically:
        - Finds an available port
        - Saves port info to temp file
        - Starts the server with configured settings
        - Handles errors with detailed logging

    Args:
        app: The FastAPI application instance to run
    """
    import uvicorn

    try:
        # Get available port
        port = get_available_port()
        logger.info(f"Selected port: {port}")

        # Save port info for external access
        save_port_to_file(port)

        # Store port in app state
        app.state.port = port

        # Start server
        logger.info(f"Starting server on {DEFAULT_HOST}:{port}")
        uvicorn.run(
            app,
            host=DEFAULT_HOST,
            port=port,
            log_level=LOG_LEVEL,
            access_log=ACCESS_LOG_ENABLED,
        )

    except KeyboardInterrupt:
        logger.info("Server stopped by user")

    except Exception as e:
        # Log error to file for debugging
        error_log = Path.cwd() / "error.log"

        with open(error_log, "w", encoding="utf-8") as f:
            traceback.print_exc(file=f)

        # Log to console
        logger.error(f"Server error occurred. Details saved to: {error_log}")
        logger.exception(e)
        traceback.print_exc()

        # Wait for user acknowledgment in production
        input("\nPress Enter to exit...")
