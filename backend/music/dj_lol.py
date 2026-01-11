import time
import json
import os
from typing import List
from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel, Field
from loguru import logger
from config.settings import BASE_DIR
import random

# --- Modelos de Dados ---


class TemaMusical(BaseModel):
    estilo: str = Field(
        description="Nome do estilo ou gênero musical. Ex: 'Heavy Metal', 'Lo-fi Samurai', 'Epic Orchestral'"
    )
    descricao: str = Field(
        description="Breve descrição de como esse estilo se encaixa no campeão"
    )


class ListaTemas(BaseModel):
    temas: List[TemaMusical]


class Musica(BaseModel):
    search_query: str = Field(
        description="Query exata para Youtube. Ex: 'Numb Linkin Park Audio'"
    )


class ListaMusicas(BaseModel):
    musicas: List[Musica]


# --- Configuração ---


def get_llm():
    config_path = BASE_DIR / "config.json"
    with open(config_path, "r") as f:
        config = json.load(f)
    if config.get("api_key"):
        os.environ["GROQ_API_KEY"] = config["api_key"]
    model = config.get("model", "llama-3.3-70b-versatile")
    return ChatGroq(model=model, temperature=0.7)


def carregar_prompt(nome_chave: str, arquivo="prompts.json"):
    """Lê o prompt do JSON e converte para ChatPromptTemplate"""
    arquivo = os.path.join(BASE_DIR, arquivo)
    if not os.path.exists(arquivo):
        raise FileNotFoundError(f"Arquivo {arquivo} não encontrado.")

    with open(arquivo, "r", encoding="utf-8") as f:
        data = json.load(f)

    if nome_chave not in data:
        raise KeyError(f"Chave '{nome_chave}' não encontrada no JSON.")

    # Converte lista de dicts para lista de tuplas [(role, content), ...]
    mensagens = [(msg["role"], msg["content"]) for msg in data[nome_chave]]
    return ChatPromptTemplate.from_messages(mensagens)


# --- Funções do Agente ---


def gerar_temas(campeao: str) -> List[TemaMusical]:
    """Estágio 1: Define a estratégia da playlist"""
    logger.info(f"🧠 Analisando a personalidade de {campeao}...")

    llm = get_llm()
    prompt = carregar_prompt("analise_campeao")
    chain = prompt | llm.with_structured_output(ListaTemas)
    resultado = chain.invoke({"campeao": campeao})
    return resultado.temas


def gerar_musicas_por_tema(campeao: str, tema: TemaMusical, qtd: int) -> List[str]:
    """Estágio 2: Preenche a playlist baseada no tema"""
    logger.info(f"Gerando {qtd} faixas do estilo: {tema.estilo} - {tema.descricao}...")

    llm = get_llm()
    prompt = carregar_prompt("gerador_playlist")
    chain = prompt | llm.with_structured_output(ListaMusicas)

    try:
        resultado = chain.invoke(
            {
                "campeao": campeao,
                "estilo": tema.estilo,
                "descricao": tema.descricao,
                "qtd": qtd,
            }
        )
        return [m.search_query for m in resultado.musicas]
    except Exception as e:
        logger.info(f"Erro ao gerar para {tema.estilo}: {e}")
        return []


# --- Fluxo Principal ---


def gerar_playlist(campeao: str, total_alvo: int = 100):
    try:
        playlist_final = []

        # 1. Pega 5 temas (Ex: Yasuo -> Hip Hop, Flauta Japonesa, Epic Rock, etc)
        temas = gerar_temas(campeao)
        for t in temas:
            logger.info(f"Tema gerado: {t.estilo} - {t.descricao}")
        musicas_por_tema = total_alvo // len(temas)

        # 2. Loop para preencher
        for tema in temas:
            queries = gerar_musicas_por_tema(campeao, tema, musicas_por_tema)
            playlist_final.extend(queries)
            # Pequena pausa para não bater no rate limit se estiver usando conta free agressivamente
            time.sleep(1)
    except Exception as e:
        logger.error(f"Erro ao gerar playlist para {campeao}: {e}")
        playlist_final = []

    random.shuffle(playlist_final)
    for query in playlist_final:
        logger.info(f"{query}")
    return playlist_final
