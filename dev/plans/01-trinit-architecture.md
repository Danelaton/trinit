# Trinit — Implementation Plan

> **Goal:** Build a one-command Ollama wrapper CLI + VS Code extension "Trinit" that lets users install Ollama, download predefined local models, and use an AI agent team in their editor — all with a single terminal command.

**Architecture:** Three-layer system — Trinit CLI (installer/wrapper), trinit-core (shared Ollama client library), Trinit VS Code extension (agent team UI). The CLI is the entry point; the extension detects existing setup and can also trigger installation.

**Tech Stack:** Node.js/TypeScript (extension + core), Bash/PowerShell (install scripts), Ollama REST API

---

## 1. User Flow

```
User runs one-liner:
  ↓
Detect OS → Install Ollama
  ↓
Pull models (from dev/docs definitions)
  ↓
Install Trinit VS Code extension
  ↓
User opens VS Code → Trinit detects Ollama + models
  ↓
Ready: chat with local models, use agent team
```

### One-liner commands

| OS | Command |
|---|---|
| Windows | `irm https://trinit.dev/install.ps1 \| iex` |
| macOS / Linux | `curl -fsSL https://trinit.dev/install.sh \| sh` |

> Phase 1: host install scripts on GitHub Releases. Phase 2: custom domain.

---

## 2. Project Structure

```
Trinit/
├── dev/
│   └── docs/                    ← Model documentation (existing)
│       ├── README.md
│       ├── 00-hardware.md
│       ├── 01-ornith.md
│       ├── 02-gemma4.md
│       ├── 03-glm-ocr.md
│       └── 04-viability-analysis.md
│
├── trinit-cli/                 ← CLI wrapper
│   ├── install.ps1              ← Windows one-liner installer
│   ├── install.sh               ← macOS/Linux one-liner installer
│   ├── package.json
│   ├── src/
│   │   ├── index.ts             ← CLI entry point
│   │   ├── install-ollama.ts    ← Ollama installer per OS
│   │   ├── pull-models.ts       ← Model downloader
│   │   └── models-manifest.ts   ← Model definitions from docs
│   └── README.md
│
├── trinit-core/                ← Shared library
│   ├── package.json
│   ├── src/
│   │   ├── index.ts             ← Public API
│   │   ├── ollama-client.ts     ← Ollama REST client
│   │   ├── model-manager.ts     ← List, pull, check models
│   │   ├── chat.ts              ← Chat completion wrapper
│   │   └── types.ts             ← Shared types
│   └── README.md
│
├── trinit-vscode/               ← VS Code extension
│   ├── package.json             ← Extension manifest
│   ├── src/
│   │   ├── extension.ts         ← Activation entry
│   │   ├── sidebar/
│   │   │   └── webview.ts       ← Chat + agent team UI
│   │   ├── agents/
│   │   │   ├── registry.ts      ← Agent team definitions
│   │   │   ├── orchestrator.ts  ← Sub-agent dispatch
│   │   │   └── teams/
│   │   │       └── generic.ts   ← Default sub-agent team
│   │   ├── providers/
│   │   │   └── ollama.ts        ← Ollama LLM provider
│   │   └── setup/
│   │       └── wizard.ts        ← First-run setup wizard
│   ├── media/
│   │   └── icon.png
│   └── README.md
│
├── models.yaml                  ← Central model manifest
├── package.json                 ← Monorepo root (npm workspaces)
└── README.md
```

---

## 3. Component Design

### 3.1 `models.yaml` — Central Model Manifest

```yaml
# Source of truth for models to pull.
# Generated from dev/docs/ but kept in sync manually for now.
models:
  - name: glm-ocr
    tag: latest
    size: "2.2 GB"
    context: 128000
    input: [text, image]
    description: "Multimodal OCR — documents, tables, figures"
    priority: 1

  - name: gemma4
    tag: e2b
    size: "7.2 GB"
    context: 128000
    input: [text, image]
    description: "Edge 2B effective — chat & code"
    priority: 2

  - name: gemma4
    tag: e4b
    size: "9.6 GB"
    context: 128000
    input: [text, image]
    description: "Edge 4B effective — chat & code"
    priority: 3

  - name: ornith
    tag: 9b
    size: "5.6 GB"
    context: 256000
    input: [text]
    description: "Agentic coding with RL — MIT"
    priority: 4
```

### 3.2 Trinit CLI (`trinit-cli`)

The CLI is the **entry point for new users**. It handles:

1. **OS detection:** Windows vs macOS vs Linux
2. **Ollama installation:** Delegates to official install scripts
3. **Model pulling:** Reads `models.yaml`, runs `ollama pull`
4. **VS Code extension installation:** Runs `code --install-extension`

```
trinit setup          → Full install: Ollama + models + extension
trinit install        → Install Ollama only
trinit pull           → Pull all models from manifest
trinit pull <name>    → Pull specific model
trinit list           → List installed models
trinit status         → Check Ollama + models status
```

### 3.3 trinit-core (Shared Library)

Published as `trinit-core` npm package. Used by both CLI and extension.

```typescript
// Core API
import { TrinitCore } from 'trinit-core';

const trinit = new TrinitCore({ baseUrl: 'http://localhost:11434' });

await trinit.listModels();           // GET /api/tags
await trinit.pullModel('ornith:9b'); // POST /api/pull (streaming)
await trinit.chat('ornith:9b', messages); // POST /api/chat
await trinit.checkHealth();          // GET / (health check)
```

### 3.4 Trinit VS Code Extension

Key features (mirroring Zoo-Code):

| Feature | Description |
|---|---|
| **Chat sidebar** | Webview with conversation UI |
| **Agent team** | Sub-agent dropdown: Code, Architect, Ask, Debug |
| **Model selector** | Dropdown of installed Ollama models |
| **Setup wizard** | First-run: detect Ollama, guide install if missing |
| **Context awareness** | Active file, selection, project structure |
| **Diff preview** | Show changes before applying |

#### Agent Team (generic, from Zoo-Code)

```typescript
const GENERIC_TEAM = {
  'code': {
    name: 'Code',
    description: 'Write, edit, and refactor code',
    systemPrompt: 'You are a software engineer...',
    allowedTools: ['read_file', 'write_file', 'terminal', 'search_files'],
  },
  'architect': {
    name: 'Architect',
    description: 'Plan systems, design architecture',
    systemPrompt: 'You are a software architect...',
    allowedTools: ['read_file', 'search_files'],
  },
  'ask': {
    name: 'Ask',
    description: 'Answer questions about the codebase',
    systemPrompt: 'You are a knowledgeable assistant...',
    allowedTools: ['read_file', 'search_files'],
  },
  'debug': {
    name: 'Debug',
    description: 'Trace issues, isolate root causes',
    systemPrompt: 'You are a debugging expert...',
    allowedTools: ['read_file', 'terminal', 'search_files'],
  },
};
```

---

## 4. Key Design Decisions

### Q: Can the VS Code extension install Ollama + models on its own?

**A: Yes, but CLI-first is better.**

The extension CAN trigger installation:
- On activation, check for `ollama` binary
- If missing, show a "Setup Required" wizard
- Wizard runs the same install scripts as the CLI
- Shows progress in the webview

**Why CLI as primary path:**
1. Installing system services (Ollama runs as a daemon) from a VS Code extension has permission friction
2. CLI works in CI, Docker, remote SSH — not just VS Code
3. One-liner is simpler UX: copy, paste, done
4. Extension setup wizard is the FALLBACK for users who install the extension first

**Result:** Both paths work. Extension detects Ollama → if missing, offers wizard → wizard calls same install logic as CLI.

### Q: How are model definitions kept in sync?

**A: `models.yaml` is the source of truth.**

- `dev/docs/` contains human-readable markdown docs
- `models.yaml` is machine-readable, consumed by CLI + extension
- On model changes: update `models.yaml`, regenerate docs if needed
- Future: auto-generate `models.yaml` from `dev/docs/` frontmatter

### Q: How does the extension discover Ollama?

**A: Standard Ollama REST API at `http://localhost:11434`.**

1. On activation: `GET http://localhost:11434/api/tags`
2. If response → Ollama is running, models listed
3. If connection refused → Ollama not running → show wizard
4. If empty tags → Ollama running but no models → offer to pull

---

## 5. Implementation Phases

### Phase 1: Foundation (this plan)

- [x] Project structure designed
- [x] Model documentation written (`dev/docs/`)
- [x] `models.yaml` manifest defined
- [ ] Monorepo initialized with npm workspaces

### Phase 2: trinit-core

- [ ] Ollama REST client with full API coverage
- [ ] Model manager (list, pull with progress, check)
- [ ] Chat completion wrapper (streaming + non-streaming)
- [ ] Health check and diagnostics
- [ ] npm package published

### Phase 3: Trinit CLI

- [ ] `install.ps1` (Windows one-liner)
- [ ] `install.sh` (macOS/Linux one-liner)
- [ ] CLI commands: setup, install, pull, list, status
- [ ] Progress display during model pulls
- [ ] VS Code extension auto-install (`code --install-extension`)

### Phase 4: Trinit VS Code Extension

- [ ] Extension scaffold with webview sidebar
- [ ] Chat UI with model selector
- [ ] Ollama provider integration (via trinit-core)
- [ ] Setup wizard (detect + guide installation)
- [ ] Agent team selector with generic team

### Phase 5: Agent Teams

- [ ] Sub-agent orchestration
- [ ] Generic team (code, architect, ask, debug)
- [ ] Diff preview and apply
- [ ] Context injection (active file, selection)

### Phase 6: Polish & Future

- [ ] Specialized agent teams (security, docs, testing, etc.)
- [ ] Model variant teams (same agent, different model)
- [ ] Custom agent team builder UI
- [ ] MCP server support
- [ ] Model performance benchmarks

---

## 6. First Task: Monorepo Scaffold

### Task 0: Initialize the monorepo

**Files:**
- Create: `Trinit/package.json`
- Create: `Trinit/models.yaml`
- Create: `Trinit/trinit-core/package.json`
- Create: `Trinit/trinit-cli/package.json`
- Create: `Trinit/trinit-vscode/package.json`

**Root `package.json`:**
```json
{
  "name": "trinit",
  "private": true,
  "workspaces": ["trinit-core", "trinit-cli", "trinit-vscode"],
  "scripts": {
    "build": "npm run build --workspaces",
    "dev": "npm run dev --workspaces"
  }
}
```

---
*Plan v1.0 — 2026-06-30*
