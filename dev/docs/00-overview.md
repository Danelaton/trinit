# Trinit — Overview

> Version: v0.1.0 · Date: 2026-07-04

---

## What is Trinit?

Trinit is **a team of AI agents that runs 100% on your machine**, with no external servers, no accounts, and no subscriptions. It is a Visual Studio Code extension that turns your editor into a fully private, offline AI-assisted development environment.

Instead of a single generic assistant, Trinit organizes AI into **specialized agents** — Architect, Orchestrator, Code, Debug, Ask, and OCR — each bound to a local model optimized for its task. All models run on **Ollama**, the most popular local LLM runtime in the open-source ecosystem.

---

## Value proposition

| Dimension | Trinit |
|---|---|
| **Privacy** | Zero data leaves your machine. Ever. |
| **Cost** | Free. No paid plans, no paid tokens, no usage limits. |
| **Access** | No account, no login, no OAuth. Open VS Code and it works. |
| **Connectivity** | Works fully offline. |
| **Control** | You choose the models. You control the hardware. |
| **Extensibility** | Supports any AI provider (OpenAI, Anthropic, etc.) if the user configures it manually. |

---

## Who it is for

### Individual developers
Those who want AI assistance without surrendering control of their code to third parties. Ideal for projects with proprietary code, NDAs, or simply out of a privacy principle.

### Teams with sensitive data
Development teams in sectors such as **healthcare, banking, legal, or defense** where code or data cannot leave the internal infrastructure. Trinit enables AI adoption without compromising regulatory compliance.

### Educators and students
Classrooms and bootcamps that need AI tools without relying on external accounts, without per-student costs, and with full control over the environment.

### Developers in offline environments
Work on isolated (air-gapped) networks, labs, or areas with limited connectivity. Trinit works without a connection once installed.

---

## Key differentiators vs. the competition

| Feature | Trinit | GitHub Copilot | Cursor | Roo Code |
|---|---|---|---|---|
| **Login required** | No | Yes | Yes | Yes |
| **Cloud data** | Never | Yes | Yes | Optional |
| **Local models** | Always (by default) | No | Partial | Partial |
| **Cost** | Free | $10–$39/month | $20/month | Freemium |
| **Works offline** | Yes | No | No | No |
| **Specialized agents** | Yes (6 modes) | No | No | Yes |
| **Local OCR** | Yes (glm-ocr) | No | No | No |
| **Teams marketplace** | Yes | No | No | Yes (limited) |
| **Predefined MCPs** | Yes (5 servers) | No | No | Partial |
| **One-command install** | Yes | No | No | No |

---

## Architecture in one sentence

> Trinit = VS Code extension (fork of Roo Code) + Ollama as the model runtime + 4 preconfigured open-source models + Teams system + predefined MCPs, all without touching the internet.

---

## Current status

- **Version**: v0.1.0 (first public release)
- **Platforms**: Windows, macOS, Linux
- **Requirement**: Visual Studio Code + Ollama (the installer handles this automatically)
- **Extension**: `trinit.vsix` (~distributed via GitHub Releases)
- **E2E-verified installation**: one-liner on Windows (`install.ps1`) and macOS/Linux (`install.sh`)

---

## Design philosophy

Trinit was born from a conviction: **development AI should not require you to surrender your code to a third party**. Open-source models from 2025–2026 have reached sufficient quality for everyday development tasks running on consumer hardware. Trinit packages that capability into a single-command installation experience, with no account friction and no billing surprises.

The design is deliberately **local-first, not local-only**: if a user wants to connect OpenAI or Anthropic for tasks that require more power, they can do so from the provider settings — without losing any local functionality.
