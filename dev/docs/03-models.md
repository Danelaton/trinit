# Trinit — The Models

> Version: v0.1.0 · Date: 2026-07-04  
> Source: `models.yaml` (source of truth), `dev/docs/models/ornith.md`, `dev/docs/models/gemma4.md`, `dev/docs/models/glm-ocr.md`

---

## 1. Model overview

Trinit includes 4 preconfigured open-source models, selected to cover software development use cases on consumer hardware:

| Model | Ollama reference | Size | Context | Input | Role in Trinit |
|---|---|---|---|---|---|
| **ornith** | `ornith:9b` | 5.6 GB | 256,000 tokens | Text | Agentic coding (architect, code, debug, orchestrator) |
| **glm-ocr** | `glm-ocr:latest` | 2.2 GB | 128,000 tokens | Text + Image | Multimodal OCR (ocr mode) |
| **gemma4 E2B** | `gemma4:e2b` | 7.2 GB | 128,000 tokens | Text + Image | Lightweight chat and reasoning (ask mode) |
| **gemma4 E4B** | `gemma4:e4b` | 9.6 GB | 128,000 tokens | Text + Image | Higher-quality chat and reasoning (fallback) |

**Total disk size:** ~24.5 GB (all models installed)

---

## 2. Detailed description of each model

### 2.1 ornith:9b — Agentic coding

| Attribute | Value |
|---|---|
| Parameters | 9B |
| Disk size | 5.6 GB |
| Context window | 256,000 tokens |
| Input | Text only |
| License | MIT |
| Specialty | Agentic coding with RL self-improvement |

**Description:** Ornith is a 9B-parameter model trained specifically for software development tasks using Reinforcement Learning (RL) techniques for self-improvement. Its 256K-token context window is the largest in the set, allowing it to maintain context on large projects without losing information.

**Why this model:** It is Trinit's primary model for all coding tasks. Its RL training makes it especially good at following complex instructions, using tools in a chained fashion (tool use), and maintaining coherence across multi-step tasks — exactly what the Architect, Code, Debug, and Orchestrator modes require.

**Strengths:**
- Following complex, multi-step instructions
- Chained tool use (read → edit → command → verify)
- Long context (256K) for large projects
- Reasoning across code in multiple files simultaneously

**Modes that use it:** `architect`, `orchestrator`, `code`, `debug`

---

### 2.2 glm-ocr:latest — Multimodal OCR

| Attribute | Value |
|---|---|
| Parameters | 0.9B |
| Disk size | 2.2 GB |
| Context window | 128,000 tokens |
| Input | Text + Image |
| Specialty | OCR of documents, tables, and figures |
| Benchmark | #1 on OmniDocBench |

**Description:** GLM-OCR is a multimodal model of only 0.9B parameters specialized in extracting text from images. Despite its small size, it leads the OmniDocBench benchmark for document OCR. It can process images of documents, screenshots, tables, figures, and handwritten text.

**Why this model:** It is the smallest model in the set (2.2 GB) but the most specialized. For OCR, a small, specialized model outperforms large generalist models. Its ability to process images makes it unique in the set — no other Trinit model accepts image input.

**Strengths:**
- Accurate text extraction from scanned documents
- Recognition of tables and complex structures
- Processing of figures and diagrams
- Handwritten text and low-quality documents
- Structured output in Markdown/JSON

**Modes that use it:** `ocr`

---

### 2.3 gemma4:e2b — Lightweight chat and reasoning

| Attribute | Value |
|---|---|
| Parameters | ~2B effective (edge-optimized) |
| Disk size | 7.2 GB |
| Context window | 128,000 tokens |
| Input | Text + Image |
| Developer | Google DeepMind |
| Family | Gemma 4 (edge) |

**Description:** Gemma 4 Edge 2B is the lightest variant of Google DeepMind's Gemma 4 family, optimized for execution on edge devices (consumer CPU/GPU). It supports multimodal input (text and image) with a 128K-token context window.

**Why this model:** It is used in `ask` mode because questions and explanations do not require the agentic reasoning capability of ornith. Gemma 4 E2B delivers quality responses with lower resource consumption, making it ideal for quick queries.

**Strengths:**
- High-quality conversational responses
- Image and screenshot analysis
- Clear technical explanations
- Lower RAM/VRAM consumption than larger models

**Modes that use it:** `ask`

---

### 2.4 gemma4:e4b — Higher-quality chat and reasoning

| Attribute | Value |
|---|---|
| Parameters | ~4B effective (edge-optimized) |
| Disk size | 9.6 GB |
| Context window | 128,000 tokens |
| Input | Text + Image |
| Developer | Google DeepMind |
| Family | Gemma 4 (edge) |

**Description:** Gemma 4 Edge 4B is the highest-quality variant of the Gemma 4 edge family. It offers better reasoning and comprehension than E2B at the cost of higher resource consumption.

**Why this model:** Included as a higher-quality alternative for users with more powerful hardware. In Trinit's default configuration, E2B is used in `ask` mode, but E4B is available for users who prefer higher quality in conversational responses.

**Strengths:**
- Higher reasoning quality than E2B
- Deeper image analysis
- Better comprehension of complex contexts

**Modes that use it:** Available as a manual alternative; not assigned by default to any mode in `LOCAL_MODE_BINDINGS`

---

## 3. Hardware requirements

### 3.1 Per individual model

| Model | Minimum RAM | Recommended RAM | VRAM (GPU) | CPU-only |
|---|---|---|---|---|
| `glm-ocr:latest` (2.2 GB) | 4 GB | 6 GB | 3 GB | Yes (slow) |
| `ornith:9b` (5.6 GB) | 8 GB | 12 GB | 6 GB | Yes (slow) |
| `gemma4:e2b` (7.2 GB) | 10 GB | 16 GB | 8 GB | Yes (slow) |
| `gemma4:e4b` (9.6 GB) | 12 GB | 20 GB | 10 GB | Yes (very slow) |

> **Note:** RAM values include the operating system and VS Code. VRAM values are for full GPU execution (faster). Ollama automatically manages the distribution between available RAM and VRAM.

### 3.2 Typical usage combinations

#### Minimum configuration (OCR + Ask only)
- **Models:** `glm-ocr:latest` + `gemma4:e2b`
- **RAM:** 16 GB
- **VRAM:** 8 GB (or CPU-only with patience)
- **Disk:** ~9.4 GB
- **Use case:** Document digitization and technical queries

#### Standard configuration (full Full Local)
- **Models:** All 4 models
- **RAM:** 16 GB (minimum), 32 GB (recommended)
- **VRAM:** 8 GB (minimum), 16 GB (recommended)
- **Disk:** ~24.5 GB
- **Use case:** Full development with all modes

#### Optimal configuration (maximum performance)
- **RAM:** 32 GB or more
- **VRAM:** 16 GB or more (NVIDIA RTX 3080/4070 or higher)
- **Disk:** NVMe SSD (for fast model loading)
- **Use case:** Development teams, intensive use

### 3.3 Notes on CPU vs. GPU

Ollama can run models on pure CPU, but generation speed is significantly lower:
- **With GPU:** 20–60 tokens/second (depending on the model and GPU)
- **Without GPU (CPU):** 2–8 tokens/second

For productive use, a GPU with at least 8 GB of VRAM is recommended. Trinit's models are selected to be viable on consumer GPUs (RTX 3060, RX 6700, etc.).

---

## 4. Why these models

The model selection is driven by three criteria:

1. **Task specialization:** Each model is chosen for its specific use case, not as a generalist model. Ornith for agentic coding, glm-ocr for vision, gemma4 for conversation.

2. **Viability on consumer hardware:** The largest model (gemma4:e4b, 9.6 GB) fits on a mid-to-high-tier GPU. The complete set (24.5 GB) fits on a system with 32 GB of RAM.

3. **Open-source licenses:** All models have permissive licenses (MIT, Apache 2.0, or equivalents) that allow commercial use without restrictions.

---

## 5. Model management

### Installation

Models are installed automatically during setup. The installer reads `models.yaml` and runs `ollama pull` for each model not installed:

```bash
# Automatic installation (via installer)
ollama pull glm-ocr:latest   # 2.2 GB
ollama pull gemma4:e2b       # 7.2 GB
ollama pull gemma4:e4b       # 9.6 GB
ollama pull ornith:9b        # 5.6 GB
```

### Smart skip

If a model is already installed, the installer detects it and skips it:

```
✅ glm-ocr:latest already installed
📥 Pulling ornith:9b...
```

### Additional models

Any model available in Ollama can be added manually:

```bash
ollama pull llama3.2:3b
ollama pull qwen2.5-coder:7b
```

Once installed, the model appears in Trinit's API configuration selector and can be assigned to any mode in Custom mode.
