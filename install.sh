#!/usr/bin/env bash
# Trinit One-Liner Installer — macOS / Linux
# Run: curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
#
# NOTE: This script is written in POSIX sh (no bashisms) so it runs correctly
# when piped to `sh` (which may be dash on macOS/Debian/Ubuntu). Do NOT use
# bash-only constructs: no `echo -e`, no `[[ ]]`, no arrays, no process
# substitution `< <(...)`, no here-strings `<<<`, no `${var,,}`, no `local`
# arrays, no C-style for-loops, no `&>`. Use `printf '%b\n'` instead of
# `echo -e`, `[ ]` instead of `[[ ]]`, and space/newline-delimited strings or
# positional parameters instead of arrays.
#
# Interactive menu: when run WITHOUT skip flags and WITHOUT --yes, the installer
# shows a simple numeric menu (type 1/2/3 + Enter):
#   [1] Trinit VS Code Extension
#   [2] Ollama + AI Models
#   [3] Trinit Extension + Ollama + AI Models (full)   <- default (just Enter)
# The menu uses a plain `read` of a number, which works both locally and under
# `curl | sh` (a simple numeric read works fine on a piped stdin / terminal).
# Only if there is no controlling terminal at all (CI, container, no /dev/tty
# and stdin not a TTY) does it fall back to non-interactive full install (3).
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
# mean we are non-interactive: the numeric menu reads from /dev/tty (the user's
# real terminal) when stdin is the pipe, or from stdin when it is a TTY. We only
# force non-interactive mode when there is no controlling terminal at all
# (stdin not a TTY AND /dev/tty not readable), e.g. in CI/containers.
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
        printf '%b\n' "${YELLOW}${prompt} ${suffix} (non-interactive, using default)${NC}" >&2
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
# Prints a numeric menu and reads a number (1/2/3) + Enter. Empty Enter = 3
# (default full). Re-prompts on invalid input. Reads from /dev/tty when stdin is
# not a TTY (e.g. `curl | sh`), otherwise from stdin. Falls back to 3 if read
# fails entirely (no controlling terminal).
show_install_menu() {
    # POSIX: no arrays. Use a case statement to print options by index.
    echo "Select installation profile:" >&2
    echo "  [1] Trinit VS Code Extension" >&2
    echo "  [2] Ollama + AI Models" >&2
    echo "  [3] Trinit Extension + Ollama + AI Models (full)" >&2
    echo "" >&2

    # Decide where to read from: if stdin is a TTY, read from it; otherwise
    # (e.g. `curl | sh` where stdin is the piped script) read from /dev/tty.
    read_src=""
    if [ ! -t 0 ] && [ -r /dev/tty ]; then
        read_src="/dev/tty"
    fi

    while true; do
        printf "Select option [1-3] (default 3): " >&2
        answer=""
        if [ -n "$read_src" ]; then
            answer=$(read -r line < "$read_src" 2>/dev/null && printf '%s' "$line" || printf '')
        else
            answer=$(read -r line 2>/dev/null && printf '%s' "$line" || printf '')
        fi

        # read failure (EOF / no terminal) -> fall back to default
        if [ -z "$answer" ] && [ ! -t 0 ] && [ ! -r /dev/tty ]; then
            echo 3
            return
        fi

        case "$answer" in
            1) echo 1; return ;;
            2) echo 2; return ;;
            3) echo 3; return ;;
            "") echo 3; return ;;  # empty Enter -> default full
            *)
                echo "Invalid option '$answer'. Please enter 1, 2, or 3 (or just press Enter for 3)." >&2
                ;;
        esac
    done
}

printf '%b\n' "${CYAN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║      T R I N I T  Setup       ║"
echo "║   Local LLMs + AI Agent Teams   ║"
echo "╚══════════════════════════════════╝"
printf '%b\n' "${NC}"

# ── Decide which steps to run ──────────────────────────────
# Default: full install (all three steps). Skip flags and the menu override this.
DO_OLLAMA=$((1 - SKIP_OLLAMA))
DO_MODELS=$((1 - SKIP_MODELS))
DO_EXTENSION=1

# If no skip flag was passed and we're not non-interactive, show the menu.
# --yes / TRINIT_YES=1 => skip menu, assume option 3 (full).
if [ "$SKIP_OLLAMA" = "0" ] && [ "$SKIP_MODELS" = "0" ] && [ "$NON_INTERACTIVE" = "0" ]; then
    MENU_CHOICE=$(show_install_menu)
    case "$MENU_CHOICE" in
        1) DO_OLLAMA=0; DO_MODELS=0; DO_EXTENSION=1 ;;
        2) DO_OLLAMA=1; DO_MODELS=1; DO_EXTENSION=0 ;;
        *) DO_OLLAMA=1; DO_MODELS=1; DO_EXTENSION=1 ;;
    esac
    printf '%b\n' "${CYAN}Selected: option ${MENU_CHOICE}${NC}"
    echo ""
elif [ "$NON_INTERACTIVE" = "1" ] && [ "$SKIP_OLLAMA" = "0" ] && [ "$SKIP_MODELS" = "0" ]; then
    printf '%b\n' "${YELLOW}Non-interactive mode: full install (option 3).${NC}"
    echo ""
fi

# ── Step 1: Detect / install / update Ollama ───────────────

if [ "$DO_OLLAMA" = "0" ]; then
    printf '%b\n' "${YELLOW}[1/3] Ollama step skipped${NC}"
else
printf '%b\n' "${YELLOW}[1/3] Checking for Ollama...${NC}"

OLLAMA_VERSION=""
if command -v ollama >/dev/null 2>&1; then
    OLLAMA_VERSION=$(ollama --version 2>&1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

    if [ -n "$OLLAMA_VERSION" ]; then
        printf '%b\n' "${GREEN}       Ollama ${OLLAMA_VERSION} detected${NC}"
    else
        printf '%b\n' "${GREEN}       Ollama detected (version unknown)${NC}"
    fi

    DO_UPDATE=$(read_yes_no "       Update Ollama?" "n")
    if [ "$DO_UPDATE" = "y" ]; then
        printf '%b\n' "${YELLOW}       Updating Ollama...${NC}"
        if [ "$(uname -s)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
            LANG=C LC_ALL=C brew upgrade ollama || curl -fsSL https://ollama.com/install.sh | sh
        else
            curl -fsSL https://ollama.com/install.sh | sh
        fi
        printf '%b\n' "${GREEN}       Ollama updated${NC}"
    else
        printf '%b\n' "${GREEN}       Skipping update, continuing with existing install${NC}"
    fi
else
    DO_INSTALL=$(read_yes_no "       Ollama is required for Trinit's local mode. Install it now?" "y")
    if [ "$DO_INSTALL" = "y" ]; then
        printf '%b\n' "${YELLOW}       Installing Ollama...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh
        printf '%b\n' "${GREEN}       Ollama installed${NC}"
    else
        echo ""
        printf '%b\n' "${RED}Trinit local mode requires Ollama to run local models.${NC}"
        printf '%b\n' "${YELLOW}Install it manually from https://ollama.com/download, then re-run this installer.${NC}"
        exit 1
    fi
fi

# Make sure the Ollama service/app is actually running (it may be installed
# but not started, e.g. right after a fresh install).
is_ollama_running() {
    curl -fsS --max-time 3 http://localhost:11434 >/dev/null 2>&1
}

if ! is_ollama_running; then
    printf '%b\n' "${YELLOW}       Ollama installed but not running — starting it...${NC}"
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files 2>/dev/null | grep -q '^ollama\.service'; then
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
        printf '%b\n' "${GREEN}       Ollama is running${NC}"
    else
        printf '%b\n' "${YELLOW}       Could not confirm Ollama is running — continuing anyway${NC}"
    fi
else
    printf '%b\n' "${GREEN}       Ollama is running${NC}"
fi
fi # end [ "$DO_OLLAMA" = "1" ]

# ── Step 2: Pull models (read list from models.yaml) ───────

if [ "$DO_MODELS" = "0" ]; then
    printf '%b\n' "${YELLOW}[2/3] Model pull step skipped${NC}"
else
printf '%b\n' "${YELLOW}[2/3] Pulling models...${NC}"

# Resolve models.yaml path (works in BOTH local and remote pipe mode).
# When run via `curl | sh`, $0 is typically "sh" (no physical script file),
# so we cannot rely on the script's directory. Instead:
#   - If a local models.yaml sits next to this script (local execution), use it.
#   - Otherwise (remote pipe execution), download it from the raw GitHub URL.
MANIFEST_RAW_URL="https://raw.githubusercontent.com/Danelaton/trinit/main/models.yaml"
resolve_manifest_path() {
    script_dir=""
    script_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
    if [ -n "$script_dir" ] && [ -f "$script_dir/models.yaml" ]; then
        echo "$script_dir/models.yaml"
        return
    fi
    tmp="/tmp/trinit-models.yaml"
    if curl -fsSL "$MANIFEST_RAW_URL" -o "$tmp" 2>/dev/null && [ -f "$tmp" ]; then
        echo "$tmp"
        return
    fi
    echo ""
}
MANIFEST_PATH="$(resolve_manifest_path)"

# POSIX: no arrays. Store model refs as newline-delimited string.
MODELS=""
if [ -n "$MANIFEST_PATH" ] && [ -f "$MANIFEST_PATH" ]; then
    MODELS="$(grep -E '^[[:space:]]*ollama_ref:' "$MANIFEST_PATH" | sed -E 's/^[[:space:]]*ollama_ref:[[:space:]]*//')"
fi

if [ -z "$MODELS" ]; then
    printf '%b\n' "${YELLOW}       Could not read models.yaml — falling back to default model list${NC}"
    MODELS="glm-ocr:latest
gemma4:e2b
gemma4:e4b
ornith:9b"
fi

INSTALLED_MODELS="$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')"

# Iterate over newline-delimited list without word-splitting on spaces.
# Use a while-read loop fed by a pipe (POSIX-safe, no process substitution).
printf '%s\n' "$MODELS" | while IFS= read -r model; do
    [ -z "$model" ] && continue
    if echo "$INSTALLED_MODELS" | grep -qx "$model"; then
        printf '%b\n' "${GREEN}       $model already installed${NC}"
        continue
    fi
    printf '%b\n' "${YELLOW}       Pulling $model...${NC}"
    ollama pull "$model"
    printf '%b\n' "${GREEN}       $model ready${NC}"
done
fi # end [ "$DO_MODELS" = "1" ]

# ── Step 3: Install VS Code extension ──────────────────────

if [ "$DO_EXTENSION" = "0" ]; then
    printf '%b\n' "${YELLOW}[3/3] VS Code extension step skipped${NC}"
else
printf '%b\n' "${YELLOW}[3/3] Installing Trinit VS Code extension...${NC}"
VSIX_URL="https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
VSIX_PATH="/tmp/trinit.vsix"
curl -fsSL "$VSIX_URL" -o "$VSIX_PATH"

# Resolve the `code` CLI. On macOS, VS Code does NOT add `code` to the shell
# PATH automatically — the user must enable it from VS Code (Cmd+Shift+P →
# "Shell Command: Install 'code' command in PATH"). The binary still lives at
# a well-known path inside the .app bundle, so we look for it there as a
# fallback. On Linux we also check common install locations.
# POSIX: no arrays. Use a newline-delimited candidate list and a while loop.
CODE_BIN=""
if command -v code >/dev/null 2>&1; then
    CODE_BIN="code"
else
    CANDIDATES=""
    case "$(uname -s)" in
        Darwin)
            CANDIDATES="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code
$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code
/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code-insiders
$HOME/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code-insiders"
            ;;
        *)
            CANDIDATES="/usr/share/code/bin/code
/snap/bin/code
/usr/bin/code
/usr/local/bin/code
$HOME/.local/share/code/bin/code"
            ;;
    esac
    printf '%s\n' "$CANDIDATES" | while IFS= read -r cand; do
        [ -z "$cand" ] && continue
        if [ -x "$cand" ]; then
            # Found a usable binary outside PATH; use its full path directly.
            printf '%s' "$cand" > /tmp/.trinit_code_bin
            break
        fi
    done
    # Read result from subshell (POSIX: no var leaking out of the while pipe).
    if [ -f /tmp/.trinit_code_bin ]; then
        CODE_BIN="$(cat /tmp/.trinit_code_bin)"
        rm -f /tmp/.trinit_code_bin
    fi
fi

if [ -z "$CODE_BIN" ]; then
    # Not found anywhere. Print a clear, actionable message instead of letting
    # the shell emit a raw "command not found" stack trace.
    printf '%b\n' "${RED}⚠️  Could not find the VS Code \"code\" command.${NC}"
    printf '%b\n' "${YELLOW}To install it manually:${NC}"
    printf '%b\n' "${YELLOW}  1. Open VS Code${NC}"
    printf '%b\n' "${YELLOW}  2. Press Cmd+Shift+P (Mac) or Ctrl+Shift+P (Windows/Linux)${NC}"
    printf '%b\n' "${YELLOW}  3. Search for and run: \"Shell Command: Install code command in PATH\"${NC}"
    printf '%b\n' "${YELLOW}  4. Then install the extension with:${NC}"
    printf '%b\n' "${YELLOW}     code --install-extension $VSIX_URL${NC}"
    printf '%b\n' "${YELLOW}     (or if you already downloaded the vsix: code --install-extension $VSIX_PATH)${NC}"
    rm -f "$VSIX_PATH"
    exit 1
fi

if [ "$CODE_BIN" != "code" ]; then
    printf '%b\n' "${CYAN}       Using VS Code CLI at: $CODE_BIN${NC}"
fi

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
"$CODE_BIN" --install-extension "$VSIX_PATH" || {
    NODE_OPTIONS="$PREV_NODE_OPTIONS"; export NODE_OPTIONS; rm -f "$VSIX_PATH"; exit 1
}
NODE_OPTIONS="$PREV_NODE_OPTIONS"
export NODE_OPTIONS
rm -f "$VSIX_PATH"
fi # end [ "$DO_EXTENSION" = "1" ]

echo ""
printf '%b\n' "${GREEN}${BOLD}"
echo "╔══════════════════════════════════╗"
echo "║   Trinit setup complete!         ║"
echo "║   Open VS Code → Trinit sidebar  ║"
echo "╚══════════════════════════════════╝"
printf '%b\n' "${NC}"
