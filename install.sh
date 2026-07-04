#!/usr/bin/env bash
# Trinit One-Liner Installer — macOS / Linux
# Run: curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
#
# Non-interactive mode: pass --yes (or set TRINIT_YES=1) to assume defaults
# (install Ollama if missing, do NOT update if already present) so the one-liner
# never hangs waiting for input, e.g.:
#   curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --yes
# Note: when piped through `curl | sh`, stdin is not a TTY, so prompts are
# automatically skipped and defaults are used even without --yes.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

NON_INTERACTIVE=0
for arg in "$@"; do
    case "$arg" in
        --yes|-y) NON_INTERACTIVE=1 ;;
    esac
done
if [ "${TRINIT_YES:-0}" = "1" ]; then
    NON_INTERACTIVE=1
fi
if [ ! -t 0 ]; then
    NON_INTERACTIVE=1
fi

# read_yes_no PROMPT DEFAULT("y"|"n") -> echoes "y" or "n"
read_yes_no() {
    prompt="$1"
    default="$2"
    if [ "$default" = "y" ]; then
        suffix="[Y/n]"
    else
        suffix="[y/N]"
    fi
    if [ "$NON_INTERACTIVE" = "1" ]; then
        echo -e "${YELLOW}${prompt} ${suffix} (non-interactive, using default)${NC}" >&2
        echo "$default"
        return
    fi
    printf "%s %s " "$prompt" "$suffix" >&2
    read -r answer || answer=""
    if [ -z "$answer" ]; then
        echo "$default"
        return
    fi
    case "$answer" in
        y|Y|yes|YES|Yes) echo "y" ;;
        *) echo "n" ;;
    esac
}

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║      T R I N I T  Setup       ║"
echo "║   Local LLMs + AI Agent Teams   ║"
echo "╚══════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Detect / install / update Ollama ───────────────

echo -e "${YELLOW}[1/3] Checking for Ollama...${NC}"

OLLAMA_VERSION=""
if command -v ollama &>/dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>&1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

    if [ -n "$OLLAMA_VERSION" ]; then
        echo -e "${GREEN}       Ollama ${OLLAMA_VERSION} detected${NC}"
    else
        echo -e "${GREEN}       Ollama detected (version unknown)${NC}"
    fi

    DO_UPDATE=$(read_yes_no "       Update Ollama?" "n")
    if [ "$DO_UPDATE" = "y" ]; then
        echo -e "${YELLOW}       Updating Ollama...${NC}"
        if [ "$(uname -s)" = "Darwin" ] && command -v brew &>/dev/null; then
            brew upgrade ollama || curl -fsSL https://ollama.com/install.sh | sh
        else
            curl -fsSL https://ollama.com/install.sh | sh
        fi
        echo -e "${GREEN}       Ollama updated${NC}"
    else
        echo -e "${GREEN}       Skipping update, continuing with existing install${NC}"
    fi
else
    DO_INSTALL=$(read_yes_no "       Ollama is required for Trinit's local mode. Install it now?" "y")
    if [ "$DO_INSTALL" = "y" ]; then
        echo -e "${YELLOW}       Installing Ollama...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh
        echo -e "${GREEN}       Ollama installed${NC}"
    else
        echo ""
        echo -e "${RED}Trinit local mode requires Ollama to run local models.${NC}"
        echo -e "${YELLOW}Install it manually from https://ollama.com/download, then re-run this installer.${NC}"
        exit 1
    fi
fi

# Make sure the Ollama service/app is actually running (it may be installed
# but not started, e.g. right after a fresh install).
is_ollama_running() {
    curl -fsS --max-time 3 http://localhost:11434 >/dev/null 2>&1
}

if ! is_ollama_running; then
    echo -e "${YELLOW}       Ollama installed but not running — starting it...${NC}"
    if command -v systemctl &>/dev/null && systemctl list-unit-files 2>/dev/null | grep -q '^ollama\.service'; then
        systemctl start ollama 2>/dev/null || true
    else
        nohup ollama serve >/dev/null 2>&1 &
    fi
    attempts=0
    while [ $attempts -lt 15 ] && ! is_ollama_running; do
        sleep 1
        attempts=$((attempts + 1))
    done
    if is_ollama_running; then
        echo -e "${GREEN}       Ollama is running${NC}"
    else
        echo -e "${YELLOW}       Could not confirm Ollama is running — continuing anyway${NC}"
    fi
else
    echo -e "${GREEN}       Ollama is running${NC}"
fi

# ── Step 2: Pull models (read list from models.yaml) ───────

echo -e "${YELLOW}[2/3] Pulling models...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MANIFEST_PATH="$SCRIPT_DIR/models.yaml"

MODELS=()
if [ -f "$MANIFEST_PATH" ]; then
    while IFS= read -r ref; do
        [ -n "$ref" ] && MODELS+=("$ref")
    done < <(grep -E '^\s*ollama_ref:' "$MANIFEST_PATH" | sed -E 's/^\s*ollama_ref:\s*//')
fi

if [ "${#MODELS[@]}" -eq 0 ]; then
    echo -e "${YELLOW}       Could not read models.yaml — falling back to default model list${NC}"
    MODELS=("glm-ocr:latest" "gemma4:e2b" "gemma4:e4b" "ornith:9b")
fi

INSTALLED_MODELS="$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')"

for model in "${MODELS[@]}"; do
    if echo "$INSTALLED_MODELS" | grep -qx "$model"; then
        echo -e "${GREEN}       $model already installed${NC}"
        continue
    fi
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
