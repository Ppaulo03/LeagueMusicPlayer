import shutil
import subprocess
from pathlib import Path
from loguru import logger
from setup import main as setup_main

BASE_DIR = Path(".")
BACKEND_DIR = Path("backend")
FLUTTER_DIR = Path("frontend")

PYTHON_DIST_DIR = BACKEND_DIR / "dist" / "LeagueMusicPlayerBackend"
FLUTTER_BUILD_DIR = FLUTTER_DIR / "build" / "windows" / "x64" / "runner" / "Release"
DEST_BACKEND_FOLDER = FLUTTER_BUILD_DIR / "backend"
FINAL_OUTPUT_DIR = BASE_DIR / "release_final"

CPP_DLLS = ["vcruntime140.dll", "vcruntime140_1.dll", "msvcp140.dll"]


def run_command(command, cwd):
    logger.info(f"Executando: {command} em {cwd}")
    try:
        subprocess.run(command, cwd=cwd, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        logger.info(f"Erro ao executar {command}")
        exit(1)


def bundle_cpp_dlls():
    """Copia as DLLs do sistema (System32) para a pasta do app"""
    logger.info("Injetando DLLs do Visual C++...")
    system32 = Path("C:/Windows/System32")

    for dll_name in CPP_DLLS:
        src = system32 / dll_name
        dest = FLUTTER_BUILD_DIR / dll_name

        if src.exists():
            shutil.copy(src, dest)
            logger.info(f"Copiado: {dll_name}")
        else:
            logger.info(
                f"AVISO: {dll_name} não encontrada em System32. O app pode falhar em PCs limpos."
            )


def main():
    logger.info("Iniciando processo de Build Fullstack...")

    # 1. Limpar builds anteriores (opcional, mas recomendado)
    if PYTHON_DIST_DIR.exists():
        shutil.rmtree(PYTHON_DIST_DIR)

    if FINAL_OUTPUT_DIR.exists():
        shutil.rmtree(FINAL_OUTPUT_DIR)

    # Setup dependências externas (FFmpeg, yt-dlp)
    setup_main()

    # 2. Buildar o Backend Python
    logger.info("Compilando Backend (PyInstaller)...")
    run_command("pyinstaller app.spec --noconfirm --clean", cwd=BACKEND_DIR)

    # 3. Buildar o Frontend Flutter
    logger.info("Compilando Frontend (Flutter)...")
    run_command("flutter build windows --release", cwd=FLUTTER_DIR)

    # 4. Integração: Mover o Backend para dentro do Flutter
    logger.info("Integrando Backend ao Frontend...")
    if DEST_BACKEND_FOLDER.exists():
        shutil.rmtree(DEST_BACKEND_FOLDER)
    shutil.copytree(PYTHON_DIST_DIR, DEST_BACKEND_FOLDER)

    bundle_cpp_dlls()

    # --- PASSO FINAL: MOVER PARA A RAIZ ---
    logger.info(f"Movendo resultado final para a raiz: {FINAL_OUTPUT_DIR}...")
    if FINAL_OUTPUT_DIR.exists():
        shutil.rmtree(FINAL_OUTPUT_DIR)
    shutil.copytree(FLUTTER_BUILD_DIR, FINAL_OUTPUT_DIR)

    logger.info("Build concluído com sucesso!")
    logger.info(f"Caminho: {FINAL_OUTPUT_DIR.absolute()}")


if __name__ == "__main__":
    main()
