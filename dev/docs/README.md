# Trinit — Documentación Técnica

> Versión: v0.1.0 · Fecha: 2026-07-04  
> Esta carpeta contiene la documentación técnica completa de Trinit. Es el **material fuente** para crear slides, presentaciones, videos promocionales y casos de uso.

---

## Índice de documentos

| Documento | Descripción |
|---|---|
| [00-overview.md](00-overview.md) | Visión general: qué es Trinit, propuesta de valor, a quién va dirigido, diferenciadores vs. Copilot/Cursor/Roo Code |
| [01-architecture.md](01-architecture.md) | Arquitectura técnica: monorepo, extensión VS Code, diagrama de componentes (Mermaid), flujo de datos local, integración Ollama |
| [02-features.md](02-features.md) | Features detalladas: 6 modos/agentes, Full Local vs. Custom, vinculación de modelos por modo, Teams marketplace, MCPs predefinidos |
| [03-models.md](03-models.md) | Los 4 modelos: tabla con tamaño/propósito/fortalezas, requisitos de hardware por modelo y combinaciones, por qué estos modelos |
| [04-installation.md](04-installation.md) | Experiencia de instalación: one-liner por plataforma, flujo inteligente con Mermaid, qué instala exactamente, troubleshooting |
| [05-use-cases.md](05-use-cases.md) | 7 casos de uso narrables para videos/demos: feature sin internet, OCR de contratos, debugging privado, onboarding en salud/banca, trabajo offline, código legacy, orquestación multi-modo |
| [06-deployment.md](06-deployment.md) | Proyecciones de despliegue: dev individual, equipo pequeño, empresa (compliance), aula/educación; requisitos, roadmap sugerido |
| [07-faq.md](07-faq.md) | FAQ técnica y de producto: GPU, offline, privacidad, costo, modelos propios, diferencias con Copilot/Cursor/Roo Code |

---

## Documentos de modelos (preexistentes)

| Documento | Descripción |
|---|---|
| [01-ornith.md](01-ornith.md) | Ornith 9B — modelo de coding agentico con RL |
| [02-gemma4.md](02-gemma4.md) | Gemma 4 E2B & E4B — modelos edge multimodal de Google DeepMind |
| [03-glm-ocr.md](03-glm-ocr.md) | GLM-OCR — OCR multimodal de 0.9B parámetros |
| [dev-commands.md](dev-commands.md) | Comandos de desarrollo del proyecto |

---

## Modelos en uso

| Modelo | Referencia Ollama | Tamaño | Contexto | Entrada | Rol |
|---|---|---|---|---|---|
| `glm-ocr` | `glm-ocr:latest` | 2.2 GB | 128K | Texto + Imagen | OCR (modo ocr) |
| `gemma4` | `gemma4:e2b` | 7.2 GB | 128K | Texto + Imagen | Chat ligero (modo ask) |
| `gemma4` | `gemma4:e4b` | 9.6 GB | 128K | Texto + Imagen | Chat de mayor calidad |
| `ornith` | `ornith:9b` | 5.6 GB | 256K | Texto | Coding agentico (architect, code, debug, orchestrator) |

---

## Notas para creadores de contenido

- **Slides/presentaciones:** Usar `00-overview.md` para la narrativa de alto nivel y `02-features.md` para el detalle técnico
- **Videos demo:** Los casos de uso en `05-use-cases.md` están diseñados para ser narrables — cada uno tiene escenario, pasos y beneficio clave
- **Argumentos de venta:** La tabla comparativa en `00-overview.md` y las secciones de compliance en `06-deployment.md`
- **Preguntas de audiencia:** `07-faq.md` cubre las preguntas más frecuentes con respuestas directas
- **Datos técnicos verificables:** Todos los números (tamaños de modelos, contexto, líneas de código) están verificados contra el código fuente

---

*Documentación generada: 2026-07-04*
