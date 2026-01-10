import os
import shutil
import urllib.request
import zipfile
from pathlib import Path
from loguru import logger

# --- CONFIGURAÇÃO ---
BACKEND_DIR = Path("backend")

# URLs diretas (sempre pegando as versões estáveis mais recentes)
URL_YTDLP = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
# Usando a build 'essentials' do gyan.dev (padrão do Windows)
URL_FFMPEG = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"


def download_file(url, dest_path):
    logger.info(f"Baixando: {url}...")
    try:
        opener = urllib.request.build_opener()
        opener.addheaders = [("User-agent", "Mozilla/5.0")]
        urllib.request.install_opener(opener)
        urllib.request.urlretrieve(url, dest_path)
        logger.info("Download concluído.")
    except Exception as e:
        logger.info(f"Erro ao baixar {url}: {e}")
        exit(1)


def setup_ffmpeg():
    zip_path = BACKEND_DIR / "ffmpeg.zip"
    extract_folder = BACKEND_DIR / "ffmpeg_temp"
    final_folder = BACKEND_DIR / "ffmpeg"

    # Se já existe a pasta final, avisa e pula (ou delete se quiser forçar update)
    if final_folder.exists():
        logger.info("FFmpeg já existe na pasta backend. Pulando...")
        return

    # 1. Download
    download_file(URL_FFMPEG, zip_path)

    # 2. Extração
    logger.info("Extraindo FFmpeg...")
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(extract_folder)

    # 3. Organização (O zip extrai uma pasta com nome da versão, ex: ffmpeg-7.0-essentials...)
    # Vamos pegar o conteúdo dessa pasta e renomear para apenas "ffmpeg" pra facilitar seu app.spec
    extracted_root = list(extract_folder.glob("ffmpeg-*-essentials_build"))[0]

    shutil.move(str(extracted_root), str(final_folder))

    # 4. Limpeza
    logger.info("Limpando arquivos temporários...")
    os.remove(zip_path)
    shutil.rmtree(extract_folder)
    logger.info("FFmpeg configurado com sucesso!")


def setup_ytdlp():
    exe_path = BACKEND_DIR / "yt-dlp.exe"

    if exe_path.exists():
        logger.info("yt-dlp.exe já existe. Pulando...")
        return

    download_file(URL_YTDLP, exe_path)
    logger.info("yt-dlp.exe configurado com sucesso!")


def main():
    logger.info("🛠️  Iniciando setup de dependências externas...\n")

    if not BACKEND_DIR.exists():
        logger.info(
            f"Pasta '{BACKEND_DIR}' não encontrada. Rode o script da raiz do projeto."
        )
        return

    setup_ytdlp()
    logger.info("-" * 30)
    setup_ffmpeg()

    logger.info("\nSetup finalizado! Agora você pode rodar o build.")


if __name__ == "__main__":
    main()
