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
            FS["filesystem"] & FT["fetch"] & GT["git"]
            MM["memory"] & ST["sequential-thinking"]
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

### Request lifecycle — how a mode binds to a model

Every request is routed through the active mode, which resolves to a model via `LOCAL_MODE_BINDINGS` (`src/shared/localModeBindings.ts`). The global toggle controls whether that binding is locked (Full Local) or user-overridable (Custom).

```mermaid
flowchart TD
    U([User types a request in chat]) --> MODE{Active mode?}
    MODE -->|architect / orchestrator / code / debug| BIND9["LOCAL_MODE_BINDINGS<br/>ornith:9b · 256K ctx"]
    MODE -->|ask| BIND2["LOCAL_MODE_BINDINGS<br/>gemma4:e2b"]
    MODE -->|ocr| BINDO["LOCAL_MODE_BINDINGS<br/>glm-ocr:latest"]

    TOGGLE{Global toggle}
    TOGGLE -->|Full Local default| LOCK["modeApiConfigLocks = true<br/>selector disabled"]
    TOGGLE -->|Custom| UNLOCK["architect + orchestrator unlocked<br/>others stay locked"]

    LOCK --> RESOLVE["ProviderSettingsManager<br/>resolves locked mode to trinit-local profile"]
    UNLOCK --> RESOLVE2["ProviderSettingsManager<br/>uses user-selected provider if unlocked"]

    BIND9 --> RESOLVE
    BIND2 --> RESOLVE
    BINDO --> RESOLVE

    RESOLVE --> TOOLS["Tool groups available to mode<br/>read · edit · command · mcp"]
    RESOLVE2 --> TOOLS

    TOOLS --> MCP["5 MCP servers<br/>filesystem · fetch · git · memory · sequential-thinking"]
    TOOLS --> OL[("Ollama<br/>localhost:11434")]

    OL --> STREAM["SSE token stream"]
    MCP --> STREAM
    STREAM --> RESP([Rendered response in webview])

    classDef local fill:#0078d4,color:#fff,stroke:#0d1117
    classDef model fill:#f0a500,color:#000,stroke:#0d1117
    classDef toggle fill:#2ea043,color:#fff,stroke:#0d1117
    class BIND9,BIND2,BINDO model
    class LOCK,UNLOCK,TOGGLE toggle
    class OL,STREAM local
```

### The Orchestrator — delegation and the boomerang resume

The Orchestrator has no tools of its own — its only mechanism is `new_task`, which delegates a subtask to a specialist mode. When the child calls `attempt_completion`, the parent is auto-resumed with the result injected as a `tool_result` (`delegateParentAndOpenChild` → `resumeAfterDelegation` in `ClineProvider.ts`). A single-open invariant means the parent is disposed while the child runs, then restored.

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant O as Orchestrator
    participant NT as new_task tool
    participant CP as ClineProvider
    participant A as Architect
    participant C as Code
    participant D as Debug

    U->>O: Build feature X end-to-end
    O->>O: Decompose into subtasks
    O->>NT: new_task mode=architect
    NT->>CP: delegateParentAndOpenChild
    CP->>CP: Flush parent history, dispose parent
    CP->>A: Switch mode, create child as sole active
    Note over A: Gathers context, writes plan to .md
    A->>CP: attempt_completion result=plan
    CP->>CP: Mark child completed, parent active
    CP->>O: resumeAfterDelegation injects tool_result
    O->>NT: new_task mode=code
    NT->>CP: delegateParentAndOpenChild
    CP->>C: Switch mode, create child
    Note over C: Reads/writes files, runs commands
    C->>CP: attempt_completion result=impl
    CP->>O: resumeAfterDelegation
    O->>NT: new_task mode=debug
    NT->>CP: delegateParentAndOpenChild
    CP->>D: Switch mode, create child
    Note over D: Reflects on causes, asks user to confirm fix
    D->>CP: attempt_completion result=verified
    CP->>O: resumeAfterDelegation
    O->>U: Synthesize all subtask results
```

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

The interactive menu also includes a **Clean Uninstall** option (4) to remove all Trinit data while preserving Ollama and its models.

One command. ~30 minutes on a 100 Mbps connection. No account, no login, no configuration prompts. For non-interactive automation (Ansible, SCCM, MDM), prefix with `TRINIT_YES=1` (bash) or `$env:TRINIT_YES = "1"` (PowerShell).

**Interactive install menu** — when you run the installer directly in a real terminal **without** any skip/yes flags, it shows a simple numeric menu so you can pick exactly what to install (type 1/2/3/4 + Enter):

```
Select installation profile:
  [1] Trinit VS Code Extension
  [2] Ollama + AI Models
  [3] Trinit Extension + Ollama + AI Models (full)
  [4] Clean Uninstall (remove all Trinit data)

Select option [1-4] (default 3):
```

| Option | What it does |
|---|---|
| 1. Trinit VS Code Extension | Step 3 only (extension). Use when Ollama + models are already set up. |
| 2. Ollama + AI Models | Steps 1 + 2 (Ollama + models), no extension. |
| 3. Trinit Extension + Ollama + AI Models (full) | All three steps. **Default** — just press Enter. |
| 4. Clean Uninstall (remove all Trinit data) | Removes the extension, all globalStorage, secrets, and credentials. **Does NOT touch Ollama or its models.** Asks for confirmation before proceeding. |

- **Windows:** the menu uses `Read-Host`, which reads from the real console even under `irm | iex` (stdin redirected), so you can pick an option in remote one-liner installs too. Invalid input re-prompts; empty Enter selects option 3. Only if the environment is truly non-interactive (no `$host.UI.RawUI`, or `Read-Host` throws) does it fall back to option 3.
- **macOS / Linux:** the menu uses a plain `read` of a number. It reads from `/dev/tty` when stdin is the piped script (under `curl | sh`), otherwise from stdin, so it works in both local and remote one-liner installs. If there is no controlling terminal at all (CI, container), it falls back to non-interactive full install (option 3).

**Skip Ollama and/or models** — if you already have Ollama + models set up, or only want the VS Code extension, the skip flags bypass the menu entirely (for scripting/CI):

```powershell
# Windows — custom flags don't work with `irm | iex`, download first then run:
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 -OutFile install.ps1
.\install.ps1 -SkipOllama -SkipModels -Yes   # extension only
.\install.ps1 -SkipOllama -Yes               # keep pulling models
.\install.ps1 -SkipModels -Yes               # keep installing/updating Ollama
```

```bash
# macOS / Linux — pass flags through `sh -s --`:
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --skip-ollama --skip-models --yes
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --skip-ollama --yes
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --skip-models --yes
```

When both skip flags are set, the installer jumps straight to Step 3 (extension only) and prints which steps were skipped. `-Yes` / `--yes` (or `TRINIT_YES=1`) skips the menu and assumes option 3 (full install).

**Clean uninstall** — remove ALL Trinit data (extension, globalStorage, credentials) while preserving Ollama and its models:

```powershell
# Windows — download the script first, then run with -CleanUninstall:
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 -OutFile install.ps1
.\install.ps1 -CleanUninstall

# Or via environment variable (works with the one-liner pipe):
$env:TRINIT_CLEAN_UNINSTALL = "1"; irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
```

```bash
# macOS / Linux — pass --clean-uninstall through `sh -s --`:
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --clean-uninstall

# Or via environment variable (works with the one-liner pipe):
TRINIT_CLEAN_UNINSTALL=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

The clean uninstall does **not** touch Ollama or its models. It removes:
- The VS Code extension
- Extension globalStorage (settings, task history, custom modes)
- Extension globalState and secrets (API keys, provider profiles)
- Credential manager entries (Windows Credential Manager / macOS Keychain / Linux libsecret)

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

MIT — see [LICENSE](LICENSE).

Trinit is a fork of [Roo Code](https://github.com/RooCodeInc/Roo-Code). Portions inherited from the upstream codebase remain under their original Apache 2.0 license; see the "Third-party / Upstream attribution" section of the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <sub>Built on a fork of <a href="https://github.com/RooCodeInc/Roo-Code">Roo Code</a> · Powered by <a href="https://ollama.com">Ollama</a> · Models: ornith, glm-ocr, gemma4</sub><br/>
  <sub>Local-first. Sovereign by design.</sub>
</p>
