# GLM-OCR

**URL:** <https://ollama.com/library/glm-ocr>  
**Tag in use:** `glm-ocr:latest`

## Description

> *"GLM-OCR is a multimodal OCR model for complex document understanding, built on the GLM-V encoder–decoder architecture."*

GLM-OCR is a multimodal model specialized in **OCR and document understanding**. At only **0.9B parameters**, it is designed for efficient edge deployment and high-concurrency inference.

### Architecture

| Component | Description |
|---|---|
| **Visual encoder** | CogViT — pre-trained on large-scale image-text data |
| **Cross-modal connector** | Lightweight, with efficient token downsampling |
| **Language decoder** | GLM-0.5B |
| **Total parameters** | ~0.9B |

## Specifications

| Property | Value |
|---|---|
| **Tag** | `glm-ocr:latest` |
| **Parameters** | 0.9B |
| **Quantization** | Q4_K_M |
| **Size** | **2.2 GB** |
| **Context** | 128K tokens |
| **Input** | Text + Image |

## Key Features

1. **State-of-the-Art Performance:** Score of **94.62 on OmniDocBench V1.5**, rank #1 overall. SOTA results on formula recognition, table recognition, and information extraction benchmarks.

2. **Optimized for Real-World Scenarios:** Robust performance on complex tables, code-heavy documents, seals, and other challenging real-world layouts.

3. **Efficient Inference:** Only 0.9B parameters. Supports deployment via vLLM, SGLang, and Ollama. Ideal for high-concurrency services and edge deployments.

4. **Easy to Use:** Fully open-source with a comprehensive SDK. Simple installation, one-line invocation, smooth integration into production pipelines.

## Usage

```bash
# Pull
ollama pull glm-ocr:latest

# Text recognition
ollama run glm-ocr Text Recognition: ./document.png

# Table recognition
ollama run glm-ocr Table Recognition: ./table.png

# Figure recognition
ollama run glm-ocr Figure Recognition: ./figure.png
```

### Recognition modes

| Mode | Command | Purpose |
|---|---|---|
| Text Recognition | `Text Recognition: ./img.png` | Extract general text |
| Table Recognition | `Table Recognition: ./img.png` | Extract and structure tables |
| Figure Recognition | `Figure Recognition: ./img.png` | Describe figures/diagrams |

### Agent integration

```bash
ollama launch claude --model glm-ocr
ollama launch codex --model glm-ocr
ollama launch hermes --model glm-ocr
ollama launch opencode --model glm-ocr
```
