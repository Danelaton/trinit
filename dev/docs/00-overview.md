# Trinit — Visión General

> Versión: v0.1.0 · Fecha: 2026-07-04

---

## ¿Qué es Trinit?

Trinit es un **equipo de agentes de inteligencia artificial que corre 100% en tu máquina**, sin servidores externos, sin cuentas, sin suscripciones. Es una extensión para Visual Studio Code que convierte tu editor en un entorno de desarrollo asistido por IA completamente privado y offline.

En lugar de un único asistente genérico, Trinit organiza la IA en **agentes especializados** — Architect, Orchestrator, Code, Debug, Ask y OCR — cada uno vinculado a un modelo local optimizado para su tarea. Todos los modelos corren sobre **Ollama**, el runtime de LLMs locales más popular del ecosistema open-source.

---

## Propuesta de valor

| Dimensión | Trinit |
|---|---|
| **Privacidad** | Cero datos salen de tu máquina. Nunca. |
| **Costo** | Gratis. Sin planes, sin tokens de pago, sin límites de uso. |
| **Acceso** | Sin cuenta, sin login, sin OAuth. Abre VS Code y funciona. |
| **Conectividad** | Funciona completamente offline. |
| **Control** | Tú eliges los modelos. Tú controlas el hardware. |
| **Extensibilidad** | Soporta cualquier proveedor de IA (OpenAI, Anthropic, etc.) si el usuario lo configura manualmente. |

---

## A quién va dirigido

### Desarrolladores individuales
Quienes quieren asistencia de IA sin ceder el control de su código a terceros. Ideal para proyectos con código propietario, NDA, o simplemente por principio de privacidad.

### Equipos con datos sensibles
Equipos de desarrollo en sectores como **salud, banca, legal o defensa** donde el código o los datos no pueden salir de la infraestructura interna. Trinit permite adoptar IA sin comprometer el cumplimiento normativo.

### Educadores y estudiantes
Aulas y bootcamps que necesitan herramientas de IA sin depender de cuentas externas, sin costos por alumno, y con control total sobre el entorno.

### Desarrolladores en entornos sin internet
Trabajo en redes aisladas (air-gapped), laboratorios, o zonas con conectividad limitada. Trinit funciona sin conexión una vez instalado.

---

## Diferenciadores clave vs. la competencia

| Característica | Trinit | GitHub Copilot | Cursor | Roo Code |
|---|---|---|---|---|
| **Login requerido** | No | Sí | Sí | Sí |
| **Datos en la nube** | Nunca | Sí | Sí | Opcional |
| **Modelos locales** | Siempre (por defecto) | No | Parcial | Parcial |
| **Costo** | Gratis | $10–$39/mes | $20/mes | Freemium |
| **Funciona offline** | Sí | No | No | No |
| **Agentes especializados** | Sí (6 modos) | No | No | Sí |
| **OCR local** | Sí (glm-ocr) | No | No | No |
| **Teams marketplace** | Sí | No | No | Sí (limitado) |
| **MCPs predefinidos** | Sí (5 servidores) | No | No | Parcial |
| **Instalación en 1 comando** | Sí | No | No | No |

---

## Arquitectura en una frase

> Trinit = extensión VS Code (fork de Roo Code) + Ollama como runtime de modelos + 4 modelos open-source preconfigurados + sistema de Teams + MCPs predefinidos, todo sin tocar internet.

---

## Estado actual

- **Versión**: v0.1.0 (primera release pública)
- **Plataformas**: Windows, macOS, Linux
- **Requisito**: Visual Studio Code + Ollama (el instalador lo gestiona automáticamente)
- **Extensión**: `trinit.vsix` (~distribuida vía GitHub Releases)
- **Instalación verificada E2E**: one-liner en Windows (`install.ps1`) y macOS/Linux (`install.sh`)

---

## Filosofía de diseño

Trinit nace de una convicción: **la IA de desarrollo no debería requerir que cedas tu código a un tercero**. Los modelos open-source de 2025-2026 han alcanzado una calidad suficiente para tareas de desarrollo cotidianas corriendo en hardware de consumo. Trinit empaqueta esa capacidad en una experiencia de instalación de un solo comando, sin fricción de cuentas, sin sorpresas de facturación.

El diseño es deliberadamente **local-first, no local-only**: si un usuario quiere conectar OpenAI o Anthropic para tareas que requieren más potencia, puede hacerlo desde la configuración de proveedores — sin perder ninguna funcionalidad local.
