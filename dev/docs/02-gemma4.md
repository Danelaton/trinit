# 02 — Gemma 4 (E2B / E4B)

**URL:** <https://ollama.com/library/gemma4>  
**Tags in use:** `gemma4:e2b`, `gemma4:e4b`

## Description

> *"Gemma 4 models are designed to deliver frontier-level performance at each size. They are well-suited for reasoning, agentic workflows, coding, and multimodal understanding."*

Gemma 4 is the fourth generation of the open model family by **Google DeepMind**. These are **multimodal** models that accept text and images as input and produce text output.

### Edge Models (E2B, E4B)

The "E" stands for **"effective parameters."** These are designed for edge device deployment with efficient architectures, but they include a full visual encoder that significantly increases the total model weight.

## Specifications

| Property | `gemma4:e2b` | `gemma4:e4b` |
|---|---|---|
| **Effective params** | 2B | 4B |
| **Quantization** | Q4_K_M | Q4_K_M |
| **Size** | **7.2 GB** | **9.6 GB** |
| **Context** | 128K tokens | 128K tokens |
| **Input** | Text + Image | Text + Image |

### Key capabilities

- **Multimodal:** Text + image input
- **Reasoning:** Frontier-level benchmark performance
- **Agentic workflows:** Optimized for autonomous workflows
- **Coding:** Strong performance on LiveCodeBench, Codeforces ELO
- **Audio:** Audio support on edge models (CoVoST, FLEURS)

## Relevant Benchmarks

| Benchmark | E4B | E2B |
|---|---|---|
| MMLU Pro | 69.4% | 60.0% |
| AIME 2026 (no tools) | 42.5% | 37.5% |
| LiveCodeBench v6 | 52.0% | 44.0% |
| Codeforces ELO | 940 | 633 |
| GPQA Diamond | 58.6% | 43.4% |
| MMMLU | 76.6% | 67.4% |
| MMMU Pro (Vision) | 52.6% | 44.2% |
| MATH-Vision | 59.5% | 52.4% |
| OmniDocBench 1.5 ↓ | 0.181 | 0.290 |

## Commands

```bash
# Pull
ollama pull gemma4:e2b
ollama pull gemma4:e4b

# Run
ollama run gemma4:e2b
ollama run gemma4:e4b
```
