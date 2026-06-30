#!/usr/bin/env bash
# Trinit One-Liner Installer — macOS / Linux
# Run: curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║      T R I N I T  Setup       ║"
echo "║   Local LLMs + AI Agent Teams   ║"
echo "╚══════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Install Ollama ────────────────────────────────

echo -e "${YELLOW}[1/3] Installing Ollama...${NC}"
if command -v ollama &>/dev/null; then
    echo -e "${GREEN}       Ollama already installed${NC}"
else
    curl -fsSL https://ollama.com/install.sh | sh
    echo -e "${GREEN}       Ollama installed${NC}"
fi

# ── Step 2: Pull models ────────────────────────────────────

echo -e "${YELLOW}[2/3] Pulling models...${NC}"
MODELS=("glm-ocr:latest" "gemma4:e2b" "gemma4:e4b" "ornith:9b")
for model in "${MODELS[@]}"; do
    echo -e "${YELLOW}       Pulling $model...${NC}"
    ollama pull "$model"
    echo -e "${GREEN}       $model ready${NC}"
done

# ── Step 3: Install VS Code extension ──────────────────────

echo -e "${YELLOW}[3/3] Installing Trinit VS Code extension...${NC}"
VSIX_URL="https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
VSIX_PATH="/tmp/trinit.vsix"
curl -fsSL "$VSIX_URL" -o "$VSIX_PATH"
code --install-extension "$VSIX_PATH"
rm -f "$VSIX_PATH"

echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║   Trinit setup complete!         ║"
echo "║   Open VS Code → Trinit sidebar  ║"
echo "╚══════════════════════════════════╝"
echo -e "${NC}"
