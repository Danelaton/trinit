# Trinit

> Local AI dev team powered by Ollama — agents for coding, planning, debugging, and docs.

**Trinit** is a VS Code extension that gives you an AI agent team running entirely on your machine. No API keys, no cloud — just you, your code, and local LLMs via [Ollama](https://ollama.com).

---

## Why Trinit?

- **100% Local** — models run on your hardware, your code never leaves your machine
- **Agent Team** — specialized agents for Code, Architect, Ask, and Debug modes
- **Zero Configuration** — one-liner installer sets up Ollama, downloads models, and installs the extension
- **Open Source** — MIT licensed

---

## Models

Trinit is pre-configured with four optimized local models:

| Model | Parameters | Size | Context | Best For |
|---|---|---|---|---|
| **GLM-OCR** | 0.9B | 2.2 GB | 128K | Document OCR, tables, figures — #1 on OmniDocBench |
| **Gemma 4 E2B** | 2B eff. | 7.2 GB | 128K | Edge chat & coding by Google DeepMind |
| **Gemma 4 E4B** | 4B eff. | 9.6 GB | 128K | Higher quality chat & reasoning |
| **Ornith 9B** | 9B | 5.6 GB | 256K | Agentic coding with reinforcement learning (MIT) |

### GLM-OCR

GLM-OCR is a multimodal OCR model specialized in complex document understanding. Built on the GLM-V encoder-decoder architecture, it integrates a CogViT visual encoder, a lightweight cross-modal connector, and a 0.5B language decoder.

- **94.62** on OmniDocBench V1.5 — ranked #1 overall
- SOTA on formula recognition, table recognition, and information extraction
- Three modes: Text Recognition, Table Recognition, Figure Recognition
- Only 0.9B parameters — ideal for edge deployment

```bash
ollama run glm-ocr Text Recognition: ./document.png
ollama run glm-ocr Table Recognition: ./table.png
ollama run glm-ocr Figure Recognition: ./figure.png
```

### Gemma 4 (E2B / E4B)

Fourth-generation open models by **Google DeepMind**. Multimodal — accepts text and images, produces text output. E2B and E4B are edge-optimized variants with "effective parameters" for efficient local inference.

**Benchmarks:**

| Benchmark | E4B | E2B |
|---|---|---|
| MMLU Pro | 69.4% | 60.0% |
| AIME 2026 (no tools) | 42.5% | 37.5% |
| LiveCodeBench v6 | 52.0% | 44.0% |
| GPQA Diamond | 58.6% | 43.4% |
| MMMU Pro (Vision) | 52.6% | 44.2% |
| MATH-Vision | 59.5% | 52.4% |

### Ornith 9B

A self-improving family of open-source models for **agentic coding**. Uses reinforcement learning to jointly optimize solution scaffolds and rollouts, discovering better search trajectories for higher-quality code generation.

- SOTA among comparable open-source models on Terminal-Bench 2.1, SWE-Bench, NL2Repo
- 256K context window
- MIT licensed, globally accessible

---

## Quick Start

### One-liner install

**Windows:**
```powershell
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

This installs Ollama, pulls all models, and sets up the VS Code extension in one command.

### Manual install

1. Install [Ollama](https://ollama.com)
2. Pull models:
   ```bash
   ollama pull glm-ocr:latest
   ollama pull gemma4:e2b
   ollama pull gemma4:e4b
   ollama pull ornith:9b
   ```
3. Install the extension from VS Code Marketplace or `.vsix`

---

## Hardware Requirements

| Model | Minimum RAM |
|---|---|
| GLM-OCR | 3 GB |
| Ornith 9B | 8 GB |
| Gemma 4 E2B | 10 GB |
| Gemma 4 E4B | 12 GB |

> Models use Q4_K_M quantization by default. Inference runs on CPU — no GPU required. A dedicated GPU will improve token generation speed.

### Tested on

| Hardware | RAM | Viable Models |
|---|---|---|
| AMD Ryzen 5 3500U | 6 GB | GLM-OCR only |
| Any modern laptop | 16 GB | All models |

---

## Features

- **Agent Modes** — Code, Architect, Ask, Debug, plus Custom modes
- **Diff Preview** — review changes before applying them
- **MCP Server Support** — connect to external tools and APIs
- **Multi-Provider** — Ollama + 35+ cloud providers (OpenAI, Anthropic, Gemini, etc.)
- **17 Languages** — UI localized in English, Spanish, German, French, Japanese, Chinese, and more
- **Task History** — resume and review past sessions
- **Checkpoints** — roll back changes at any point

---

## Commands

| Command | Description |
|---|---|
| `trinit status` | Check Ollama + model status |
| `trinit install` | Install Ollama |
| `trinit pull` | Pull all models from manifest |
| `trinit pull <model>` | Pull a specific model |
| `trinit list` | List installed models |
| `trinit setup` | Full setup: Ollama + models + extension |

---

## Development

```bash
# Prerequisites
pnpm install

# Build
pnpm build

# Dev mode (F5 in VS Code)
# Open trinit-vscode/ in VS Code → F5 → Extension Development Host

# Package
pnpm vsix    # → bin/trinit-0.1.0.vsix
```

---

## License

MIT
