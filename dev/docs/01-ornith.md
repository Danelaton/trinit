# 01 — Ornith 9B

**URL:** <https://ollama.com/library/ornith>  
**Tag in use:** `ornith:9b`

## Description

> *"A self-improving family of open-source models for agentic coding"*

Ornith is a family of open-source models purpose-built for **agentic coding** — autonomous programming where the model not only generates code but orchestrates the entire problem-solving process.

### Highlights

1. **State-of-the-Art on coding benchmarks:** Leading performance among open-source models of comparable size on Terminal-Bench 2.1, SWE-Bench, NL2Repo, and OpenClaw.

2. **Self-improving via RL:** Ornith-1.0 uses Reinforcement Learning to learn to generate not only solution rollouts, but also the *scaffold* that drives those rollouts. By jointly optimizing scaffold and resulting solution, the model discovers better search trajectories and produces higher-quality solutions.

3. **MIT License:** Fully open, globally accessible, no regional restrictions.

## Specifications

| Property | Value |
|---|---|
| **Tag** | `ornith:9b` |
| **Parameters** | 9B |
| **Quantization** | Q4_K_M |
| **Size** | **5.6 GB** |
| **Context** | 256K tokens |
| **Input** | Text |
| **Digest** | `a75697c14589` |
| **Updated** | 2026-06-28 |

## Commands

```bash
# Pull
ollama pull ornith:9b

# Run
ollama run ornith:9b
```
