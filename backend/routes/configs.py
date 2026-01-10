"""
Config routes - API endpoints for configuration management.
"""

import json
import os
from pathlib import Path
from typing import Dict, Any, Optional

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from loguru import logger
from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
from groq import AuthenticationError, RateLimitError

# Initialize router
router = APIRouter(prefix="/configs", tags=["Configs"])

# Path to config file
CONFIG_PATH = Path(__file__).parent.parent / "config" / "config.json"


class ConfigModel(BaseModel):
    model: Optional[str] = None
    api_key: Optional[str] = None


def load_config() -> Dict[str, Any]:
    """Load configuration from file."""
    try:
        with open(CONFIG_PATH, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Config file not found")
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Invalid config file")


def save_config(config: Dict[str, Any]):
    """Save configuration to file."""
    try:
        with open(CONFIG_PATH, "w") as f:
            json.dump(config, f, indent=4)
    except Exception as e:
        logger.error(f"Error saving config: {e}")
        raise HTTPException(status_code=500, detail="Failed to save config")


def test_config(config: Dict[str, Any]):
    """Test if the configuration works by making a small request."""
    try:
        # Set API key temporarily
        original_key = os.environ.get("GROQ_API_KEY")
        if config.get("api_key"):
            os.environ["GROQ_API_KEY"] = config["api_key"]

        model = config.get("model", "llama-3.3-70b-versatile")
        llm = ChatGroq(model=model, temperature=0.7)
        prompt = ChatPromptTemplate.from_template(
            "Say 'OK' if you can understand this."
        )
        chain = prompt | llm
        response = chain.invoke({})

        # Restore original key
        if original_key is not None:
            os.environ["GROQ_API_KEY"] = original_key
        elif "GROQ_API_KEY" in os.environ:
            del os.environ["GROQ_API_KEY"]

        if not response.content.strip():
            raise Exception("Empty response")

    except AuthenticationError:
        raise HTTPException(
            status_code=400, detail="Chave API inválida. Verifique sua chave do Groq."
        )
    except RateLimitError:
        raise HTTPException(
            status_code=400,
            detail="Limite de taxa excedido. Tente novamente mais tarde.",
        )
    except Exception as e:
        error_msg = str(e).lower()
        if "model" in error_msg and (
            "not found" in error_msg or "invalid" in error_msg
        ):
            raise HTTPException(
                status_code=400, detail="Modelo inválido. Verifique o nome do modelo."
            )
        elif "deprecated" in error_msg or "discontinued" in error_msg:
            raise HTTPException(
                status_code=400, detail="Modelo descontinuado. Escolha um modelo ativo."
            )
        else:
            logger.error(f"Config test failed: {e}")
            raise HTTPException(
                status_code=400,
                detail=f"Falha na validação da configuração. Erro: {str(e)}. Verifique sua chave API e configurações do modelo.",
            )


@router.get("", summary="Get current configuration")
async def get_configs() -> JSONResponse:
    """
    Retrieve current configuration settings.

    Returns:
        JSONResponse: Current model and API key (API key masked for security)
    """
    try:
        config = load_config()
        # Mask API key for security
        response = {
            "model": config.get("model", ""),
            "api_key": (
                "*" * len(config.get("api_key", "")) if config.get("api_key") else ""
            ),
        }
        return JSONResponse(content=response)
    except Exception as e:
        logger.error(f"Error retrieving config: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve config")


@router.put("", summary="Update configuration")
async def update_configs(config_update: ConfigModel) -> JSONResponse:
    """
    Update configuration settings.

    Args:
        config_update: New configuration values

    Returns:
        JSONResponse: Success message
    """
    try:
        current_config = load_config()
        # Update only provided fields
        if config_update.model is not None:
            current_config["model"] = config_update.model
        if config_update.api_key is not None:
            current_config["api_key"] = config_update.api_key

        # Test the new configuration
        test_config(current_config)

        save_config(current_config)
        return JSONResponse(content={"message": "Configuration updated successfully"})
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating config: {e}")
        raise HTTPException(status_code=500, detail="Failed to update config")
