#!/usr/bin/env bash
# Trinit One-Liner Installer — macOS / Linux
# Run: curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
#
# Interactive menu: when run WITHOUT skip flags and WITHOUT --yes, the installer
# shows an arrow-key menu (Up/Down to move, Enter to select):
#   1. Trinit VS Code Extension
#   2. Ollama + AI Models
#   3. Trinit Extension + Ollama + AI Models (full)   <- default
# The menu reads keystrokes directly from /dev/tty (not stdin), because under
# `curl | sh` stdin is the piped script and cannot be used for interactive
# input. If /dev/tty is unavailable (CI, container, non-interactive terminal),
# the installer falls back to a typed numeric menu (1/2/3 + Enter); if that
# also cannot read input, it falls back to non-interactive full install
# (option 3).
#
# Non-interactive mode: pass --yes (or set TRINIT_YES=1) to skip the menu
# entirely and assume option 3 (full install), e.g.:
#   curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --yes
#
# Skip flags (useful when Ollama + models are already set up, or you only want
# the VS Code extension). Works with the pipe form via `sh -s --`:
#   curl -fsSL .../install.sh | sh -s -- --skip-ollama --skip-models --yes
#   curl -fsSL .../install.sh | sh -s -- --skip-ollama   # still pulls models
#   curl -fsSL .../install.sh | sh -s -- --skip-models   # still installs/updates Ollama
#   curl -fsSL .../install.sh | sh -s -- --skip-ollama --skip-models  # extension only

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

NON_INTERACTIVE=0
SKIP_OLLAMA=0
SKIP_MODELS=0
for arg in "$@"; do
    case "$arg" in
        --yes|-y) NON_INTERACTIVE=1 ;;
        --skip-ollama) SKIP_OLLAMA=1 ;;
        --skip-models) SKIP_MODELS=1 ;;
    esac
done
if [ "${TRINIT_YES:-0}" = "1" ]; then
    NON_INTERACTIVE=1
fi
# Under `curl | sh`, stdin is the piped script (not a TTY). That alone does NOT
# mean we are non-interactive: the menu reads keystrokes from /dev/tty, which is
# the user's real terminal. We only force non-interactive mode when there is no
# controlling terminal at all (no /dev/tty), e.g. in CI/containers.
if [ ! -t 0 ] && [ ! -r /dev/tty ]; then
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

# show_install_menu -> echoes the chosen option number (1, 2, or 3).
# Tries the arrow-key UI via /dev/tty first; falls back to a typed numeric menu
# if /dev/tty is unavailable or read fails; finally falls back to 3 (full).
show_install_menu() {
    local options=(
        "Trinit VS Code Extension"
        "Ollama + AI Models"
        "Trinit Extension + Ollama + AI Models (full)"
    )
    local selected=2  # 0-based; default = option 3 (full)
    local n=${#options[@]}
    local i redraw=1

    # Try to open /dev/tty for interactive keystroke reading. Under `curl | sh`
    # stdin is the piped script, so we MUST read from /dev/tty. If /dev/tty is
    # not available (CI, container, no controlling terminal), fall back to the
    # typed numeric menu.
    if [ ! -r /dev/tty ] || [ ! -w /dev/tty ]; then
        echo 3
        return
    fi

    # Open /dev/tty on fd 3 so we don't disturb stdin (which may be the script).
    exec 3</dev/tty 4>/dev/tty 2>/dev/tty || {
        echo 3
        return
    }

    # Hide the cursor and disable line echo for a cleaner menu.
    printf '\033[?25l' >&4
    # Ensure cursor is restored on exit (normal + show cursor).
    trap 'printf "\033[?25h\033[0m" >&4' RETURN

    while true; do
        if [ "$redraw" = "1" ]; then
            # Move cursor up n+3 lines and clear each, so we repaint in place.
            # (n options + header lines). Using \033[2K clears the whole line.
            for ((i=0; i<n+3; i++)); do printf '\033[1A\033[2K' >&4; done
            printf "Select installation profile (Up/Down to move, Enter to select):\n" >&4
            printf "\n" >&4
            for ((i=0; i<n; i++)); do
                if [ "$i" = "$selected" ]; then
                    printf "  \033[32m> %s\033[0m\n" "${options[$i]}" >&4
                else
                    printf "    %s\n" "${options[$i]}" >&4
                fi
            done
            printf "\n" >&4
            redraw=0
        fi

        # Read one byte from /dev/tty. -r raw, -s silent, -n1 one char, no IFS.
        local key=""
        key=$(dd bs=1 count=1 2>/dev/null <&3 | tr -d '\0')
        if [ -z "$key" ]; then
            # read failed (EOF on /dev/tty) -> fall back to default
            printf '\033[?25h\033[0m' >&4
            exec 3<&- 4>&-
            echo 3
            return
        fi

        # ESC sequence for arrow keys: ESC [ A/B/C/D
        if [ "$key" = "$(printf '\033')" ]; then
            # Read the rest of the escape sequence ([ then letter). Use dd with
            # a tiny timeout via read where possible; fall back to dd.
            local seq=""
            seq=$(dd bs=1 count=2 2>/dev/null <&3 | tr -d '\0')
            case "$seq" in
                "[A") selected=$(( (selected - 1 + n) % n )); redraw=1 ;;
                "[B") selected=$(( (selected + 1) % n )); redraw=1 ;;
                # Ignore [C (right) and [D (left) and other sequences.
            esac
            continue
        fi

        # Enter: CR (\r, 0x0D) or LF (\n, 0x0A)
        case "$key" in
            "$(printf '\r')"|"$(printf '\n')")
                printf '\033[?25h\033[0m' >&4
                exec 3<&- 4>&-
                echo $((selected + 1))
                return
                ;;
        esac
    done
}

# typed_menu -> echoes the chosen option number (1, 2, or 3) via a plain
# number + Enter prompt read from /dev/tty. Used as a fallback when arrow-key
# reading is not possible. Falls back to 3 on read failure.
typed_menu() {
    local options=(
        "Trinit VS Code Extension"
        "Ollama + AI Models"
        "Trinit Extension + Ollama + AI Models (full)"
    )
    local n=${#options[@]}
    local i
    echo "Select installation profile (type 1-$n and press Enter, default 3):" >&2
    for ((i=0; i<n; i++)); do
        echo "  $((i+1)). ${options[$i]}" >&2
    done
    printf "Choice [1-3]: " >&2
    local answer=""
    if [ -r /dev/tty ]; then
        answer=$(read -r line < /dev/tty && printf '%s' "$line" || printf '')
    fi
    case "$answer" in
        1) echo 1 ;;
        2) echo 2 ;;
        3) echo 3 ;;
        "") echo 3 ;;  # empty -> default full
        *) echo 3 ;;   # invalid -> default full
    esac
}

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║      T R I N I T  Setup       ║"
echo "║   Local LLMs + AI Agent Teams   ║"
echo "╚══════════════════════════════════╝"
echo -e "${NC}"

# ── Decide which steps to run ──────────────────────────────
# Default: full install (all three steps). Skip flags and the menu override this.
DO_OLLAMA=$((1 - SKIP_OLLAMA))
DO_MODELS=$((1 - SKIP_MODELS))
DO_EXTENSION=1

# If no skip flag was passed and we're not non-interactive, show the menu.
# --yes / TRINIT_YES=1 => skip menu, assume option 3 (full).
if [ "$SKIP_OLLAMA" = "0" ] && [ "$SKIP_MODELS" = "0" ] && [ "$NON_INTERACTIVE" = "0" ]; then
    MENU_CHOICE=$(show_install_menu)
    # If the arrow-key menu returned empty or failed, try the typed fallback.
    if [ -z "$MENU_CHOICE" ]; then
        MENU_CHOICE=$(typed_menu)
    fi
    case "$MENU_CHOICE" in
        1) DO_OLLAMA=0; DO_MODELS=0; DO_EXTENSION=1 ;;
        2) DO_OLLAMA=1; DO_MODELS=1; DO_EXTENSION=0 ;;
        *) DO_OLLAMA=1; DO_MODELS=1; DO_EXTENSION=1 ;;
    esac
    echo -e "${CYAN}Selected: option ${MENU_CHOICE}${NC}"
    echo ""
elif [ "$NON_INTERACTIVE" = "1" ] && [ "$SKIP_OLLAMA" = "0" ] && [ "$SKIP_MODELS" = "0" ]; then
    echo -e "${YELLOW}Non-interactive mode: full install (option 3).${NC}"
    echo ""
fi

# ── Step 1: Detect / install / update Ollama ───────────────

if [ "$DO_OLLAMA" = "0" ]; then
    echo -e "${YELLOW}[1/3] Ollama step skipped${NC}"
else
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
fi # end [ "$DO_OLLAMA" = "1" ]

# ── Step 2: Pull models (read list from models.yaml) ───────

if [ "$DO_MODELS" = "0" ]; then
    echo -e "${YELLOW}[2/3] Model pull step skipped${NC}"
else
echo -e "${YELLOW}[2/3] Pulling models...${NC}"

# Resolve models.yaml path (works in BOTH local and remote pipe mode).
# When run via `curl | sh`, BASH_SOURCE is empty (no physical script file),
# so we cannot rely on the script's directory. Instead:
#   - If a local models.yaml sits next to this script (local execution), use it.
#   - Otherwise (remote pipe execution), download it from the raw GitHub URL.
MANIFEST_RAW_URL="https://raw.githubusercontent.com/Danelaton/trinit/main/models.yaml"
resolve_manifest_path() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
    if [ -n "$script_dir" ] && [ -f "$script_dir/models.yaml" ]; then
        echo "$script_dir/models.yaml"
        return
    fi
    local tmp="/tmp/trinit-models.yaml"
    if curl -fsSL "$MANIFEST_RAW_URL" -o "$tmp" 2>/dev/null && [ -f "$tmp" ]; then
        echo "$tmp"
        return
    fi
    echo ""
}
MANIFEST_PATH="$(resolve_manifest_path)"

MODELS=()
if [ -n "$MANIFEST_PATH" ] && [ -f "$MANIFEST_PATH" ]; then
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
fi # end [ "$DO_MODELS" = "1" ]

# ── Step 3: Install VS Code extension ──────────────────────

if [ "$DO_EXTENSION" = "0" ]; then
    echo -e "${YELLOW}[3/3] VS Code extension step skipped${NC}"
else
echo -e "${YELLOW}[3/3] Installing Trinit VS Code extension...${NC}"
VSIX_URL="https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
VSIX_PATH="/tmp/trinit.vsix"
curl -fsSL "$VSIX_URL" -o "$VSIX_PATH"
# `code` is a shim that runs VS Code's bundled Node executing its own cli.js.
# That internal Node code uses the legacy url.parse() API and emits
# `[DEP0169] DeprecationWarning: url.parse()`. This is NOT from Trinit code
# (trinit-cli/trinit-core use `new URL(...)` and have no url.parse calls).
# We scope NODE_OPTIONS=--no-deprecation to THIS command only so the noisy
# third-party warning is silenced without hiding deprecation warnings from
# our own code elsewhere.
PREV_NODE_OPTIONS="${NODE_OPTIONS:-}"
if [ -n "$PREV_NODE_OPTIONS" ]; then
    NODE_OPTIONS="$PREV_NODE_OPTIONS --no-deprecation"
else
    NODE_OPTIONS="--no-deprecation"
fi
export NODE_OPTIONS
code --install-extension "$VSIX_PATH" || {
    NODE_OPTIONS="$PREV_NODE_OPTIONS"; export NODE_OPTIONS; rm -f "$VSIX_PATH"; exit 1
}
NODE_OPTIONS="$PREV_NODE_OPTIONS"
export NODE_OPTIONS
rm -f "$VSIX_PATH"
fi # end [ "$DO_EXTENSION" = "1" ]

echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║   Trinit setup complete!         ║"
echo "║   Open VS Code → Trinit sidebar  ║"
echo "╚══════════════════════════════════╝"
echo -e "${NC}"
