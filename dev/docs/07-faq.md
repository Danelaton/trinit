# Trinit — Technical and Product FAQ

> Version: v0.1.0 · Date: 2026-07-04

---

## General questions

### What exactly is Trinit?

Trinit is a Visual Studio Code extension that adds a team of specialized AI agents that run entirely on your machine. It is not an autocomplete plugin — it is a full conversational assistant that can read your code, write files, execute commands, and coordinate complex tasks, all without sending anything to the internet.

### Is it free?

Yes, completely free. There are no paid plans, no usage limits, no tokens to buy. The only cost is the hardware it runs on (which you already have).

### Do I need to create an account?

No. Trinit has no account system. There is no login, no OAuth, no email to verify. You install and use it.

### What is the difference from GitHub Copilot?

| | Trinit | GitHub Copilot |
|---|---|---|
| Login | No | Yes (GitHub account) |
| Cloud data | Never | Yes |
| Works offline | Yes | No |
| Cost | $0 | $10–$39/month |
| Specialized agents | 6 modes | No |
| Local OCR | Yes | No |

Copilot is primarily in-editor code autocomplete. Trinit is a conversational agent system that can plan, implement, debug, and coordinate complex tasks.

### What is the difference from Cursor?

Cursor is a complete editor (a fork of VS Code) with built-in AI that requires an account and sends code to its servers. Trinit is an extension for your existing VS Code that runs everything locally. If you already use VS Code, Trinit requires no editor change.

### What is the difference from Roo Code?

Trinit is a fork of Roo Code with three main differences:
1. **No login:** Roo Code has an authentication system with its cloud gateway. Trinit removes it completely.
2. **Ollama by default:** Roo Code requires configuring a provider. Trinit comes preconfigured with Ollama and 4 local models.
3. **Teams and OCR:** Trinit adds the Teams system and the specialized OCR mode with `glm-ocr`.

---

## Technical questions

### Do I need a GPU?

Not strictly, but it is recommended. Without a GPU, models run on CPU and generation speed is 2–8 tokens/second (slow but functional). With an 8 GB VRAM GPU, speed rises to 20–60 tokens/second.

**Minimum recommendation for productive use:** GPU with 8 GB VRAM (NVIDIA RTX 3060, AMD RX 6700, or equivalent).

### Does it work fully offline?

Yes, once installed. The initial installation requires internet to download the models (~24.5 GB total). After that, Trinit works with no internet connection at all.

### Does my data leave my PC?

No. Never. All processing happens on `http://localhost:11434` (Ollama). There is no active telemetry, no calls to external APIs during normal use. You can verify this with any network monitor.

**Technically:** Trinit's source code is open-source and auditable. The only network communication that occurs is between the VS Code extension and the Ollama daemon on localhost.

### How much disk space do I need?

The 4 preconfigured models take up ~24.5 GB:
- `glm-ocr:latest`: 2.2 GB
- `ornith:9b`: 5.6 GB
- `gemma4:e2b`: 7.2 GB
- `gemma4:e4b`: 9.6 GB

If space is limited, you can install only the models you need. The functional minimum is `glm-ocr:latest` + `ornith:9b` (~7.8 GB).

### How much RAM do I need?

**Minimum:** 16 GB RAM (to run one model at a time with the operating system and VS Code)  
**Recommended:** 32 GB RAM (for greater comfort and larger models)

Ollama automatically manages the distribution between available RAM and VRAM.

### Can I use my own models?

Yes. Any model available in Ollama can be used with Trinit. Install the model with `ollama pull <model>` and it will appear in the API configuration selector. You can assign it to any mode in Custom mode.

```bash
# Examples of additional models
ollama pull llama3.2:3b
ollama pull qwen2.5-coder:7b
ollama pull deepseek-coder-v2:16b
```

### Can I use external providers like OpenAI or Anthropic?

Yes. Trinit preserves Roo Code's provider system intact. You can configure OpenAI, Anthropic, OpenRouter, AWS Bedrock, Google Vertex, and any other compatible provider. In Custom mode, you can assign those providers to specific modes.

Full Local mode (default) uses Ollama exclusively. Switching to Custom is a conscious user choice.

### What is Ollama and why do I need it?

Ollama is the most popular local language model runtime in the open-source ecosystem. It manages the download, storage, and execution of LLM models on your machine, exposing an OpenAI-compatible API at `http://localhost:11434`.

Trinit uses Ollama as its local inference engine. The Trinit installer detects and optionally installs Ollama automatically.

### Does it work on Windows, macOS, and Linux?

Yes, on all three platforms. The installer has specific versions for each:
- **Windows:** `install.ps1` (PowerShell)
- **macOS/Linux:** `install.sh` (bash)

### What version of VS Code do I need?

Trinit requires VS Code. The minimum compatible version is not explicitly specified in v0.1.0, but using a recent version (1.85+) is recommended.

---

## Questions about models and modes

### Why are there 6 different modes?

Each mode is optimized for a type of task:
- **Architect:** Planning and design (cannot modify code, only `.md`)
- **Orchestrator:** Coordination of complex multi-step tasks
- **Code:** Implementation (full access to files and terminal)
- **Debug:** Systematic diagnosis (always asks for confirmation before modifying)
- **Ask:** Queries and explanations (read-only, never modifies anything)
- **OCR:** Text extraction from images (uses a specialized multimodal model)

### Why does Ask mode use a different model?

Ask mode uses `gemma4:e2b` instead of `ornith:9b` because questions and explanations do not require ornith's agentic reasoning capability. Gemma 4 E2B is lighter and sufficiently capable for conversational responses, which reduces resource consumption.

### Can I change which model each mode uses?

In Full Local mode (default), models are bound and cannot be changed from the UI (the selector appears locked). This ensures you always use the model optimized for each task.

In Custom mode, you can unlock any mode and assign it any available model or provider.

### What is Full Local vs. Custom mode?

There is a **global toggle** in the modes view (`ModesView.tsx`) that applies a complete preset:

- **Full Local (default):** Calls `applyFullLocalPreset()` — locks all modes and resolves each model from the `LOCAL_MODE_BINDINGS` table. API configuration selectors appear disabled in the UI.
- **Custom:** Calls `applyCustomPreset()` — unlocks `architect` and `orchestrator` by default, leaving the rest on local. The user can unlock additional modes individually and assign them any model or provider (OpenAI, Anthropic, etc.).

### What are Teams?

A Team is a curated set of modes along with their model bindings. Installing a Team activates all its modes and configures the models automatically. The "Trinit Core Team" includes the 6 predefined modes with their local models.

In the future, there will be specialized Teams (Frontend Team, Data Science Team, etc.) available in the marketplace.

### What are MCPs?

MCP (Model Context Protocol) servers extend the agent's capabilities with additional tools. Trinit includes 5 predefined MCPs:
- `filesystem`: filesystem access
- `fetch`: HTTP requests
- `git`: Git operations
- `memory`: persistent memory across sessions
- `sequential-thinking`: structured reasoning

These are configured automatically on first activation.

---

## Privacy and security questions

### Does Trinit send telemetry?

No. Roo Code's telemetry (PostHog) is disabled in Trinit. No usage data is sent to any external server.

### Is the code I write in chat saved on any server?

No. Conversation history is saved locally in VS Code's `globalStorage` (on your machine). It never leaves your system.

### Can I use Trinit with code under NDA?

Yes. Since no data leaves your machine, there is no risk of NDA violation. The code you share with Trinit is only seen by the local model running on your hardware.

### Is Trinit suitable for HIPAA/GDPR environments?

Technically yes — Trinit transmits no data to third parties. However, regulatory compliance depends on many factors beyond the tool itself. Consult your compliance team for a full assessment.

---

## Installation questions

### What if I already have Ollama installed?

The installer detects it, shows the version, and asks if you want to update it (default: No). If you don't update, it continues with the existing version.

### What if I already have some models installed?

The installer checks which models are installed and only downloads the missing ones. Existing models are not touched.

### Can I install Trinit without internet?

The initial installation requires internet to download the models and the extension. For air-gapped environments, you would need to:
1. Download the models on a machine with internet and transfer them
2. Download `trinit.vsix` from GitHub Releases and install it manually with `code --install-extension trinit.vsix`

This functionality is on the roadmap for future versions.

### How do I update Trinit?

Currently, updating is manual:
1. Download the new version of `trinit.vsix` from GitHub Releases
2. Run `code --install-extension trinit.vsix`

In future versions, an automatic update mechanism will be added.
