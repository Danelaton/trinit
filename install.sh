#!/usr/bin/env bash
# Trinit One-Liner Installer — macOS / Linux
# Run: curl -fsSL https://raw.githubusercontent.com/USER/Trinit/main/install.sh | sh

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

echo -e "${YELLOW}[1/4] Installing Ollama...${NC}"
if command -v ollama &>/dev/null; then
    echo -e "${GREEN}       Ollama already installed${NC}"
else
    curl -fsSL https://ollama.com/install.sh | sh
    echo -e "${GREEN}       Ollama installed${NC}"
fi

# ── Step 2: Clone Trinit repo ────────────────────────────

echo -e "${YELLOW}[2/4] Cloning Trinit...${NC}"
TRINITY_DIR="$HOME/Trinit"
if [ -d "$TRINITY_DIR" ]; then
    echo -e "${YELLOW}       Trinit directory exists, pulling latest...${NC}"
    cd "$TRINITY_DIR"
    git pull
else
    git clone https://github.com/USER/Trinit.git "$TRINITY_DIR"
    cd "$TRINITY_DIR"
fi
echo -e "${GREEN}       Trinit ready at $TRINITY_DIR${NC}"

# ── Step 3: Install dependencies & build ──────────────────

echo -e "${YELLOW}[3/4] Installing dependencies...${NC}"
cd "$TRINITY_DIR"
npm install
npm run build
echo -e "${GREEN}       Dependencies installed and built${NC}"

# ── Step 4: Pull models & install extension ───────────────

echo -e "${YELLOW}[4/4] Running Trinit setup (models + extension)...${NC}"
node trinit-cli/dist/index.js setup

echo ""
echo -e "${GREEN}Trinit setup complete!${NC}"
echo -e "${CYAN}Open VS Code and look for the Trinit sidebar.${NC}"
