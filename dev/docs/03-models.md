# Trinit — Los Modelos

> Versión: v0.1.0 · Fecha: 2026-07-04  
> Fuente: `models.yaml` (fuente de verdad), `dev/docs/01-ornith.md`, `dev/docs/02-gemma4.md`, `dev/docs/03-glm-ocr.md`

---

## 1. Resumen de modelos

Trinit incluye 4 modelos open-source preconfigurados, seleccionados para cubrir los casos de uso de desarrollo de software con hardware de consumo:

| Modelo | Referencia Ollama | Tamaño | Contexto | Entrada | Rol en Trinit |
|---|---|---|---|---|---|
| **ornith** | `ornith:9b` | 5.6 GB | 256.000 tokens | Texto | Coding agentico (architect, code, debug, orchestrator) |
| **glm-ocr** | `glm-ocr:latest` | 2.2 GB | 128.000 tokens | Texto + Imagen | OCR multimodal (modo ocr) |
| **gemma4 E2B** | `gemma4:e2b` | 7.2 GB | 128.000 tokens | Texto + Imagen | Chat y razonamiento ligero (modo ask) |
| **gemma4 E4B** | `gemma4:e4b` | 9.6 GB | 128.000 tokens | Texto + Imagen | Chat y razonamiento de mayor calidad (fallback) |

**Tamaño total en disco:** ~24.5 GB (todos los modelos instalados)

---

## 2. Descripción detallada de cada modelo

### 2.1 ornith:9b — Coding agentico

| Atributo | Valor |
|---|---|
| Parámetros | 9B |
| Tamaño en disco | 5.6 GB |
| Ventana de contexto | 256.000 tokens |
| Entrada | Solo texto |
| Licencia | MIT |
| Especialidad | Coding agentico con RL self-improvement |

**Descripción:** Ornith es un modelo de 9B parámetros entrenado específicamente para tareas de desarrollo de software con técnicas de Reinforcement Learning (RL) para auto-mejora. Su ventana de contexto de 256K tokens es la más grande del conjunto, lo que le permite mantener el contexto de proyectos grandes sin perder información.

**Por qué este modelo:** Es el modelo principal de Trinit para todas las tareas de coding. Su entrenamiento con RL lo hace especialmente bueno en seguir instrucciones complejas, usar herramientas de forma encadenada (tool use), y mantener coherencia en tareas multi-paso — exactamente lo que requieren los modos Architect, Code, Debug y Orchestrator.

**Fortalezas:**
- Seguimiento de instrucciones complejas y multi-paso
- Tool use encadenado (read → edit → command → verify)
- Contexto largo (256K) para proyectos grandes
- Razonamiento sobre código en múltiples archivos simultáneamente

**Modos que lo usan:** `architect`, `orchestrator`, `code`, `debug`

---

### 2.2 glm-ocr:latest — OCR multimodal

| Atributo | Valor |
|---|---|
| Parámetros | 0.9B |
| Tamaño en disco | 2.2 GB |
| Ventana de contexto | 128.000 tokens |
| Entrada | Texto + Imagen |
| Especialidad | OCR de documentos, tablas y figuras |
| Benchmark | #1 en OmniDocBench |

**Descripción:** GLM-OCR es un modelo multimodal de solo 0.9B parámetros especializado en extracción de texto de imágenes. A pesar de su pequeño tamaño, lidera el benchmark OmniDocBench para OCR de documentos. Puede procesar imágenes de documentos, capturas de pantalla, tablas, figuras y texto manuscrito.

**Por qué este modelo:** Es el modelo más pequeño del conjunto (2.2 GB) pero el más especializado. Para OCR, un modelo pequeño y especializado supera a modelos grandes generalistas. Su capacidad de procesar imágenes lo hace único en el conjunto — ningún otro modelo de Trinit acepta entrada de imagen.

**Fortalezas:**
- Extracción precisa de texto de documentos escaneados
- Reconocimiento de tablas y estructuras complejas
- Procesamiento de figuras y diagramas
- Texto manuscrito y documentos de baja calidad
- Salida estructurada en Markdown/JSON

**Modos que lo usan:** `ocr`

---

### 2.3 gemma4:e2b — Chat y razonamiento ligero

| Atributo | Valor |
|---|---|
| Parámetros | ~2B efectivos (edge-optimized) |
| Tamaño en disco | 7.2 GB |
| Ventana de contexto | 128.000 tokens |
| Entrada | Texto + Imagen |
| Desarrollador | Google DeepMind |
| Familia | Gemma 4 (edge) |

**Descripción:** Gemma 4 Edge 2B es la variante más ligera de la familia Gemma 4 de Google DeepMind, optimizada para ejecución en dispositivos edge (CPU/GPU de consumo). Soporta entrada multimodal (texto e imagen) con una ventana de contexto de 128K tokens.

**Por qué este modelo:** Se usa en el modo `ask` porque las preguntas y explicaciones no requieren la capacidad de razonamiento agentico de ornith. Gemma 4 E2B ofrece respuestas de calidad con menor consumo de recursos, lo que lo hace ideal para consultas rápidas.

**Fortalezas:**
- Respuestas conversacionales de alta calidad
- Análisis de imágenes y capturas de pantalla
- Explicaciones técnicas claras
- Menor consumo de RAM/VRAM que modelos más grandes

**Modos que lo usan:** `ask`

---

### 2.4 gemma4:e4b — Chat y razonamiento de mayor calidad

| Atributo | Valor |
|---|---|
| Parámetros | ~4B efectivos (edge-optimized) |
| Tamaño en disco | 9.6 GB |
| Ventana de contexto | 128.000 tokens |
| Entrada | Texto + Imagen |
| Desarrollador | Google DeepMind |
| Familia | Gemma 4 (edge) |

**Descripción:** Gemma 4 Edge 4B es la variante de mayor calidad de la familia edge de Gemma 4. Ofrece mejor razonamiento y comprensión que E2B a costa de mayor consumo de recursos.

**Por qué este modelo:** Incluido como alternativa de mayor calidad para usuarios con hardware más potente. En la configuración por defecto de Trinit, E2B se usa en el modo `ask`, pero E4B está disponible para usuarios que prefieran mayor calidad en las respuestas conversacionales.

**Fortalezas:**
- Mayor calidad de razonamiento que E2B
- Análisis más profundo de imágenes
- Mejor comprensión de contextos complejos

**Modos que lo usan:** Disponible como alternativa manual; no asignado por defecto a ningún modo en `LOCAL_MODE_BINDINGS`

---

## 3. Requisitos de hardware

### 3.1 Por modelo individual

| Modelo | RAM mínima | RAM recomendada | VRAM (GPU) | CPU-only |
|---|---|---|---|---|
| `glm-ocr:latest` (2.2 GB) | 4 GB | 6 GB | 3 GB | Sí (lento) |
| `ornith:9b` (5.6 GB) | 8 GB | 12 GB | 6 GB | Sí (lento) |
| `gemma4:e2b` (7.2 GB) | 10 GB | 16 GB | 8 GB | Sí (lento) |
| `gemma4:e4b` (9.6 GB) | 12 GB | 20 GB | 10 GB | Sí (muy lento) |

> **Nota:** Los valores de RAM incluyen el sistema operativo y VS Code. Los valores de VRAM son para ejecución completa en GPU (más rápida). Ollama gestiona automáticamente la distribución entre RAM y VRAM disponibles.

### 3.2 Combinaciones típicas de uso

#### Configuración mínima (solo OCR + Ask)
- **Modelos:** `glm-ocr:latest` + `gemma4:e2b`
- **RAM:** 16 GB
- **VRAM:** 8 GB (o CPU-only con paciencia)
- **Disco:** ~9.4 GB
- **Caso de uso:** Digitalización de documentos y consultas técnicas

#### Configuración estándar (Full Local completo)
- **Modelos:** Los 4 modelos
- **RAM:** 16 GB (mínimo), 32 GB (recomendado)
- **VRAM:** 8 GB (mínimo), 16 GB (recomendado)
- **Disco:** ~24.5 GB
- **Caso de uso:** Desarrollo completo con todos los modos

#### Configuración óptima (máximo rendimiento)
- **RAM:** 32 GB o más
- **VRAM:** 16 GB o más (NVIDIA RTX 3080/4070 o superior)
- **Disco:** SSD NVMe (para carga rápida de modelos)
- **Caso de uso:** Equipos de desarrollo, uso intensivo

### 3.3 Notas sobre CPU vs. GPU

Ollama puede correr modelos en CPU pura, pero la velocidad de generación es significativamente menor:
- **Con GPU:** 20-60 tokens/segundo (dependiendo del modelo y GPU)
- **Sin GPU (CPU):** 2-8 tokens/segundo

Para uso productivo, se recomienda al menos una GPU con 8 GB de VRAM. Los modelos de Trinit están seleccionados para ser viables en GPUs de consumo (RTX 3060, RX 6700, etc.).

---

## 4. Por qué estos modelos

La selección de modelos responde a tres criterios:

1. **Especialización por tarea:** Cada modelo está elegido para su caso de uso específico, no como un modelo generalista. ornith para coding agentico, glm-ocr para visión, gemma4 para conversación.

2. **Viabilidad en hardware de consumo:** El modelo más grande (gemma4:e4b, 9.6 GB) cabe en una GPU de gama media-alta. El conjunto completo (24.5 GB) cabe en un sistema con 32 GB de RAM.

3. **Licencias open-source:** Todos los modelos tienen licencias permisivas (MIT, Apache 2.0, o equivalentes) que permiten uso comercial sin restricciones.

---

## 5. Gestión de modelos

### Instalación

Los modelos se instalan automáticamente durante el setup. El instalador lee `models.yaml` y ejecuta `ollama pull` para cada modelo no instalado:

```bash
# Instalación automática (vía installer)
ollama pull glm-ocr:latest   # 2.2 GB
ollama pull gemma4:e2b       # 7.2 GB
ollama pull gemma4:e4b       # 9.6 GB
ollama pull ornith:9b        # 5.6 GB
```

### Skip inteligente

Si un modelo ya está instalado, el instalador lo detecta y lo omite:

```
✅ glm-ocr:latest already installed
📥 Pulling ornith:9b...
```

### Modelos adicionales

Cualquier modelo disponible en Ollama puede añadirse manualmente:

```bash
ollama pull llama3.2:3b
ollama pull qwen2.5-coder:7b
```

Una vez instalado, el modelo aparece en el selector de configuración API de Trinit y puede asignarse a cualquier modo en modo Custom.
