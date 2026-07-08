<p align="center">
  <img src="assets/trinit-logo.svg" width="160" height="160" alt="Trinit logo" />
</p>

<h1 align="center">Trinit</h1>

<p align="center">
  <strong>The AI coding team that never leaves your machine.</strong><br/>
  A team of specialized agents — Architect, Orchestrator, Code, Debug, Ask, OCR — running 100% local on Ollama. Zero cloud. Zero accounts. Zero telemetry. Zero per-token cost.
</p>

<p align="center">
  <a href="https://github.com/Danelaton/trinit/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/Danelaton/trinit?style=flat-square&color=0078d4" /></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078d4?style=flat-square" />
  <img alt="License" src="https://img.shields.io/badge/license-See%20LICENSE-0078d4?style=flat-square" />
  <img alt="VS Code" src="https://img.shields.io/badge/VS%20Code-extension-0078d4?style=flat-square" />
  <img alt="Models" src="https://img.shields.io/badge/models-4%20local-0078d4?style=flat-square" />
</p>

<p align="center">
  <a href="#installation">Install</a> ·
  <a href="#why-trinit">Why Trinit</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="#models">Models</a> ·
  <a href="#faq">FAQ</a>
</p>

---

## The premise

Every mainstream AI coding assistant — Copilot, Cursor, Codeium — is built on the same trade: **you ship your source code to a vendor's cloud, and they rent the intelligence back to you by the seat or the token.** For a Fortune 500 CTO, that trade is the wrong shape. It moves intellectual property across a trust boundary you do not control, it introduces a recurring cost line that scales with headcount, and it creates a hard dependency on a vendor whose pricing can change on a quarter's notice.

**Trinit inverts the trade.** The intelligence runs on hardware you already own, inside the network perimeter you already audit. The code never crosses a boundary. The cost curve is flat — it ends at installation. There is no account to provision, no token meter to watch, no vendor to renew with. It is AI development assistance structured as **sovereignty by design**, not as a SaaS subscription.

This is not a privacy feature bolted onto a cloud product. It is a different category: a **local-first agent team** where local is the default, the only default, and the architecture makes any other configuration a conscious, reversible choice.

---

## Why Trinit

- **Sovereignty over your code.** Every token of every prompt, every line of every file, every inference request stays on `localhost`. There is no cloud endpoint to exfiltrate from, no vendor pipeline to subpoena, no training-data clause to litigate. Compliance, IP protection, and NDA integrity are architectural guarantees — not policy promises.
- **Zero marginal cost.** No per-seat subscription. No per-token metering. No usage caps. The only cost is the electricity to run hardware you have already depreciated. At 500 engineers, that is the difference between a seven-figure annual line item and a rounding error.
- **Air-gapped ready.** Once installed, Trinit makes zero outbound network calls. It runs identically on a developer laptop, a classified network, a regulated on-prem cluster, or a flight-mode commute. No "offline mode" degradation — offline *is* the mode.
- **No vendor dependency.** The models are open-source, the runtime is open-source, the extension is open-source. A pricing change, an acquisition, or a deprecation from any AI vendor cannot break your toolchain. You own the stack.
- **Speed without compromise.** Specialized 9B and sub-1B models, purpose-selected per task, deliver agentic coding, debugging, and OCR at 20–60 tokens/second on a single consumer GPU — fast enough for real development flow, with a 256K context window for large codebases.

---

## How it compares

| | **Trinit** | GitHub Copilot | Cursor | Codeium |
|---|---|---|---|---|
| **Code leaves the machine** | Never | Yes | Yes | Yes |
| **Account / login required** | No | Yes | Yes | Yes |
| **Runs fully offline** | Yes | No | No | No |
| **Air-gapped deployable** | Yes | No | No | No |
| **Specialized agent modes** | 6 (Architect, Orchestrator, Code, Debug, Ask, OCR) | No | No | No |
| **Local OCR model** | Yes (`glm-ocr`, #1 OmniDocBench) | No | No | No |
| **Cost model** | $0, flat | $10–$39 / seat / mo | $20 / seat / mo | Freemium |
| **Vendor lock-in** | None (open models + open runtime) | High | High | High |
| **Telemetry** | None (disabled at build) | Yes | Yes | Yes |

---

## How it works

Trinit is a VS Code extension built on a fork of Roo Code, re-engineered around a single principle: **the default is local, and local is locked.** Six specialized agents are each bound to a purpose-selected open-source model running on a local Ollama runtime. A global **Full Local / Custom** toggle controls whether models are locked to local (the default) or selectively unlocked to allow an external provider for a specific mode.

```mermaid
graph TB
    subgraph Machine["Your machine — nothing leaves this box"]
        subgraph VSCode["VS Code"]
            EXT["Trinit Extension<br/>(6 agent modes)"]
        end
        subgraph Ollama["Ollama runtime · localhost:11434"]
            M1["ornith:9b<br/>coding agent · 256K ctx"]
            M2["glm-ocr<br/>vision / OCR · #1 OmniDocBench"]
            M3["gemma4:e2b<br/>lightweight chat"]
        end
        subgraph MCP["5 MCP servers · pre-seeded"]
            FS["filesystem"] & FT["fetch"] & GT["git"]<br/>MM["memory"] & ST["sequential-thinking"]
        end
        EXT -->|"inference"| Ollama
        EXT -->|"tools"| MCP
    end
    style Machine fill:#0d1117,color:#fff,stroke:#0078d4
    style EXT fill:#0078d4,color:#fff
    style Ollama fill:#f0a500,color:#000
```

**The six agents:**

| Mode | Role | Local model | What it does |
|---|---|---|---|
| 🏗️ **Architect** | Planning | `ornith:9b` | Gathers context, asks clarifying questions, produces structured task plans. Edits `.md` only — cannot touch code. |
| 🪃 **Orchestrator** | Coordination | `ornith:9b` | Decomposes multi-step work and delegates subtasks to the right specialist mode. |
| 💻 **Code** | Implementation | `ornith:9b` | Full read/write/terminal/MCP access. The primary development mode. |
| 🪲 **Debug** | Diagnosis | `ornith:9b` | Systematic root-cause analysis. **Always asks for confirmation before applying a fix.** |
| ❓ **Ask** | Consultation | `gemma4:e2b` | Read-only Q&A and explanations. Never modifies anything. |
| 🔎 **OCR** | Vision | `glm-ocr` | Extracts structured text from images, scanned PDFs, screenshots. Multimodal. |

**Full Local vs. Custom:** In Full Local (the default), every mode is locked to its local model — the UI selector is disabled, so the binding cannot be changed by accident. In Custom, `architect` and `orchestrator` unlock by default and any mode can be individually unlocked to point at an external provider (OpenAI, Anthropic, OpenRouter, Bedrock, Vertex). Unlocking is reversible — re-locking restores the local model instantly. The provider infrastructure from Roo Code is preserved intact, so Trinit is compatible with every provider Roo Code supports; it simply requires none of them.

---

## Installation

Three methods. All verified. Pick one.

### Method 1 — PowerShell (Windows)

```powershell
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
```

### Method 2 — bash (macOS / Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

### Method 3 — Manual

Download the extension and install it into VS Code:

```bash
# 1. Download the latest release
curl -fsSL -o trinit.vsix https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix

# 2. Install into VS Code
code --install-extension trinit.vsix
```

Or download directly from the [Releases page](https://github.com/Danelaton/trinit/releases/latest).

**What the installer does (Methods 1 & 2):**

1. **Ollama** — detects it, installs it if missing, starts the daemon if not running.
2. **Models** — pulls the 4 preconfigured models (~24.5 GB total), skipping any already installed.
3. **Extension** — downloads `trinit.vsix` from the latest release and runs `code --install-extension`.

One command. ~30 minutes on a 100 Mbps connection. No account, no login, no configuration prompts. For non-interactive automation (Ansible, SCCM, MDM), prefix with `TRINIT_YES=1` (bash) or `$env:TRINIT_YES = "1"` (PowerShell).

**Requirements:** VS Code on PATH · ~25 GB free disk · 16 GB RAM minimum (32 GB recommended) · a GPU with 8 GB VRAM is recommended but not required (CPU-only runs at 2–8 tok/s).

---

## Models

Four open-source models, each selected for a specific job — not one generalist stretched across everything.

| Model | Parameters | Disk | Context | Input | Role |
|---|---|---|---|---|---|
| **ornith:9b** | 9B | 5.6 GB | 256,000 | Text | Agentic coding — Architect, Orchestrator, Code, Debug |
| **glm-ocr** | 0.9B | 2.2 GB | 128,000 | Text + Image | OCR / vision — #1 on OmniDocBench |
| **gemma4:e2b** | ~2B | 7.2 GB | 128,000 | Text + Image | Lightweight chat — Ask mode |
| **gemma4:e4b** | ~4B | 9.6 GB | 128,000 | Text + Image | Higher-quality chat (optional fallback) |

**Total disk: ~24.5 GB.** Any Ollama-available model can be added manually (`ollama pull <model>`) and assigned to any mode in Custom. See [`dev/docs/03-models.md`](dev/docs/03-models.md) for hardware requirements per model.

---

## Teams & MCPs

- **Teams marketplace** — install curated sets of modes with their model bindings. Ships with the **Trinit Core Team** (all 6 modes on Full Local bindings). The marketplace is 100% local — no remote registry, the catalog is packaged inside the extension.
- **5 MCP servers pre-seeded** on first activation — `filesystem`, `fetch`, `git`, `memory`, `sequential-thinking`. Zero configuration. Seeded exactly once; removing one does not bring it back.

---

## Roadmap

- **v0.1.x — Stabilization (current):** 6 modes, one-liner installers, 4 models, Core Team, 5 MCPs.
- **v0.2.x — Public marketplace:** community Teams, specialized teams (Frontend, Data Science, DevOps), expanded model catalog.
- **v0.3.x — Team experience:** shared `.trinit/` config in repos, versioned teams, authenticated shared Ollama servers.
- **v1.0.x — Enterprise:** private fine-tuned models, internal identity integration, local usage dashboard, full air-gapped install path.

---

## FAQ

<details>
<summary><b>Do my prompts or code ever leave my machine?</b></summary>

No. All inference runs on `http://localhost:11434` (Ollama). There is no telemetry, no external API call during normal use, and no authentication against any remote server. The source is open and auditable — verify it with any network monitor.
</details>

<details>
<summary><b>Is it really free?</b></summary>

Yes. No paid plans, no usage limits, no tokens to purchase. The only cost is the hardware it runs on.
</details>

<details>
<summary><b>Do I need a GPU?</b></summary>

Not strictly. Without a GPU, models run on CPU at 2–8 tokens/second (functional but slow). With an 8 GB VRAM GPU, expect 20–60 tokens/second. An NVIDIA RTX 3060 / AMD RX 6700 or equivalent is the recommended minimum for productive use.
</details>

<details>
<summary><b>Can I still use OpenAI / Anthropic if I want to?</b></summary>

Yes. Switch to **Custom** mode and unlock any individual mode to point at an external provider. Full provider infrastructure (OpenAI, Anthropic, OpenRouter, Bedrock, Vertex, and more) is preserved. Full Local remains the default — using a cloud provider is always a deliberate, per-mode, reversible choice.
</details>

<details>
<summary><b>Is it suitable for HIPAA / GDPR / regulated environments?</b></summary>

Technically, Trinit transmits no data to third parties — a claim verifiable by network monitoring. Whether that satisfies a specific compliance regime depends on your broader environment; involve your compliance team for a full assessment. The architectural property — no outbound data path — is the foundation.
</details>

<details>
<summary><b>How do I update?</b></summary>

Download the new `trinit.vsix` from [Releases](https://github.com/Danelaton/trinit/releases/latest) and run `code --install-extension trinit.vsix`. Automatic updates are on the roadmap.
</details>

For the full technical FAQ, see [`dev/docs/07-faq.md`](dev/docs/07-faq.md).

---

## Documentation

Complete technical documentation lives in [`dev/docs/`](dev/docs/):

- [`00-overview.md`](dev/docs/00-overview.md) — Vision & value proposition
- [`01-architecture.md`](dev/docs/01-architecture.md) — System architecture & data flow
- [`02-features.md`](dev/docs/02-features.md) — Modes, Full Local/Custom, Teams, MCPs
- [`03-models.md`](dev/docs/03-models.md) — Model selection & hardware requirements
- [`04-installation.md`](dev/docs/04-installation.md) — Installer internals & troubleshooting
- [`05-use-cases.md`](dev/docs/05-use-cases.md) — Seven narrated use cases
- [`06-deployment.md`](dev/docs/06-deployment.md) — Deployment scenarios & roadmap
- [`07-faq.md`](dev/docs/07-faq.md) — Full FAQ

---

## License

See [LICENSE](LICENSE).

---

<p align="center">
  <sub>Built on a fork of <a href="https://github.com/RooCodeInc/Roo-Code">Roo Code</a> · Powered by <a href="https://ollama.com">Ollama</a> · Models: ornith, glm-ocr, gemma4</sub><br/>
  <sub>Local-first. Sovereign by design.</sub>
</p>
