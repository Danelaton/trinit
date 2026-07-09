# Trinit — Technical Documentation

> Version: v0.1.0 · Date: 2026-07-04  
> This folder contains the complete technical documentation for Trinit. It is the **source material** for creating slides, presentations, promotional videos, and use cases.

---

## Document index

| Document | Description |
|---|---|
| [00-overview.md](00-overview.md) | Overview: what Trinit is, value proposition, target audience, differentiators vs. Copilot/Cursor/Roo Code |
| [01-architecture.md](01-architecture.md) | Technical architecture: monorepo, VS Code extension, component diagram (Mermaid), local data flow, Ollama integration |
| [02-features.md](02-features.md) | Detailed features: 6 modes/agents, Full Local vs. Custom, model binding per mode, Teams marketplace, predefined MCPs |
| [03-models.md](03-models.md) | The 4 models: table with size/purpose/strengths, hardware requirements per model and combinations, why these models |
| [04-installation.md](04-installation.md) | Installation experience: one-liner per platform, smart flow with Mermaid, what it installs exactly, troubleshooting |
| [05-use-cases.md](05-use-cases.md) | 7 narratable use cases for videos/demos: feature without internet, OCR of contracts, private debugging, onboarding in healthcare/banking, offline work, legacy code, multi-mode orchestration |
| [06-deployment.md](06-deployment.md) | Deployment scenarios: individual dev, small team, enterprise (compliance), classroom/education; requirements, suggested roadmap |
| [07-faq.md](07-faq.md) | Technical and product FAQ: GPU, offline, privacy, cost, custom models, differences from Copilot/Cursor/Roo Code |

---

## Model documents

Detailed spec sheets for each model, in `models/`:

| Document | Description |
|---|---|
| [models/ornith.md](models/ornith.md) | Ornith 9B — agentic coding model with RL |
| [models/gemma4.md](models/gemma4.md) | Gemma 4 E2B & E4B — Google DeepMind's edge multimodal models |
| [models/glm-ocr.md](models/glm-ocr.md) | GLM-OCR — 0.9B-parameter multimodal OCR model |

---

## Other resources

| Document | Description |
|---|---|
| [dev-commands.md](dev-commands.md) | Project development commands |
| [TRINIT.svg](TRINIT.svg) | Trinit vector logo |

---

## Models in use

| Model | Ollama reference | Size | Context | Input | Role |
|---|---|---|---|---|---|
| `glm-ocr` | `glm-ocr:latest` | 2.2 GB | 128K | Text + Image | OCR (ocr mode) |
| `gemma4` | `gemma4:e2b` | 7.2 GB | 128K | Text + Image | Lightweight chat (ask mode) |
| `gemma4` | `gemma4:e4b` | 9.6 GB | 128K | Text + Image | Higher-quality chat |
| `ornith` | `ornith:9b` | 5.6 GB | 256K | Text | Agentic coding (architect, code, debug, orchestrator) |

---

## Notes for content creators

- **Slides/presentations:** Use `00-overview.md` for the high-level narrative and `02-features.md` for technical detail
- **Demo videos:** The use cases in `05-use-cases.md` are designed to be narratable — each has a scenario, steps, and a key benefit
- **Selling points:** The comparison table in `00-overview.md` and the compliance sections in `06-deployment.md`
- **Audience questions:** `07-faq.md` covers the most frequent questions with direct answers
- **Verifiable technical data:** All numbers (model sizes, context, lines of code) are verified against the source code

---

*Documentation generated: 2026-07-04*
