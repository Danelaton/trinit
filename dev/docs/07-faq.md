# Trinit — FAQ Técnica y de Producto

> Versión: v0.1.0 · Fecha: 2026-07-04

---

## Preguntas generales

### ¿Qué es Trinit exactamente?

Trinit es una extensión para Visual Studio Code que añade un equipo de agentes de IA especializados que corren completamente en tu máquina. No es un plugin de autocompletado — es un asistente conversacional completo que puede leer tu código, escribir archivos, ejecutar comandos, y coordinar tareas complejas, todo sin enviar nada a internet.

### ¿Es gratis?

Sí, completamente gratis. No hay planes de pago, no hay límites de uso, no hay tokens que comprar. El único costo es el hardware donde corre (que ya tienes).

### ¿Necesito crear una cuenta?

No. Trinit no tiene sistema de cuentas. No hay login, no hay OAuth, no hay email que verificar. Instalas y usas.

### ¿Cuál es la diferencia con GitHub Copilot?

| | Trinit | GitHub Copilot |
|---|---|---|
| Login | No | Sí (cuenta GitHub) |
| Datos en la nube | Nunca | Sí |
| Funciona offline | Sí | No |
| Costo | $0 | $10-$39/mes |
| Agentes especializados | 6 modos | No |
| OCR local | Sí | No |

Copilot es principalmente autocompletado de código en el editor. Trinit es un sistema de agentes conversacionales que puede planificar, implementar, debuggear y coordinar tareas complejas.

### ¿Cuál es la diferencia con Cursor?

Cursor es un editor completo (fork de VS Code) con IA integrada que requiere cuenta y envía código a sus servidores. Trinit es una extensión para VS Code existente que corre todo localmente. Si ya usas VS Code, Trinit no requiere cambiar de editor.

### ¿Cuál es la diferencia con Roo Code?

Trinit es un fork de Roo Code con tres diferencias principales:
1. **Sin login:** Roo Code tiene un sistema de autenticación con su gateway cloud. Trinit lo elimina completamente.
2. **Ollama por defecto:** Roo Code requiere configurar un proveedor. Trinit viene preconfigurado con Ollama y 4 modelos locales.
3. **Teams y OCR:** Trinit añade el sistema de Teams y el modo OCR especializado con `glm-ocr`.

---

## Preguntas técnicas

### ¿Necesito GPU?

No es estrictamente necesario, pero sí recomendado. Sin GPU, los modelos corren en CPU y la velocidad de generación es de 2-8 tokens/segundo (lento pero funcional). Con una GPU de 8 GB VRAM, la velocidad sube a 20-60 tokens/segundo.

**Recomendación mínima para uso productivo:** GPU con 8 GB VRAM (NVIDIA RTX 3060, AMD RX 6700, o equivalente).

### ¿Funciona completamente offline?

Sí, una vez instalado. La instalación inicial requiere internet para descargar los modelos (~24.5 GB en total). Después, Trinit funciona sin ninguna conexión a internet.

### ¿Mis datos salen de mi PC?

No. Nunca. Todo el procesamiento ocurre en `http://localhost:11434` (Ollama). No hay telemetría activa, no hay llamadas a APIs externas durante el uso normal. Puedes verificarlo con cualquier monitor de red.

**Técnicamente:** El código fuente de Trinit es open-source y auditable. La única comunicación de red que ocurre es entre la extensión VS Code y el daemon Ollama en localhost.

### ¿Cuánto espacio en disco necesito?

Los 4 modelos preconfigurados ocupan ~24.5 GB:
- `glm-ocr:latest`: 2.2 GB
- `ornith:9b`: 5.6 GB
- `gemma4:e2b`: 7.2 GB
- `gemma4:e4b`: 9.6 GB

Si el espacio es limitado, puedes instalar solo los modelos que necesitas. El mínimo funcional es `glm-ocr:latest` + `ornith:9b` (~7.8 GB).

### ¿Cuánta RAM necesito?

**Mínimo:** 16 GB RAM (para correr un modelo a la vez con el sistema operativo y VS Code)  
**Recomendado:** 32 GB RAM (para mayor comodidad y modelos más grandes)

Ollama gestiona automáticamente la distribución entre RAM y VRAM disponibles.

### ¿Puedo usar mis propios modelos?

Sí. Cualquier modelo disponible en Ollama puede usarse con Trinit. Instala el modelo con `ollama pull <modelo>` y aparecerá en el selector de configuración API. Puedes asignarlo a cualquier modo en modo Custom.

```bash
# Ejemplos de modelos adicionales
ollama pull llama3.2:3b
ollama pull qwen2.5-coder:7b
ollama pull deepseek-coder-v2:16b
```

### ¿Puedo usar proveedores externos como OpenAI o Anthropic?

Sí. Trinit preserva intacto el sistema de proveedores de Roo Code. Puedes configurar OpenAI, Anthropic, OpenRouter, AWS Bedrock, Google Vertex, y cualquier otro proveedor compatible. En modo Custom, puedes asignar esos proveedores a modos específicos.

El modo Full Local (por defecto) usa exclusivamente Ollama. Cambiar a Custom es una decisión consciente del usuario.

### ¿Qué es Ollama y por qué lo necesito?

Ollama es el runtime de modelos de lenguaje locales más popular del ecosistema open-source. Gestiona la descarga, almacenamiento y ejecución de modelos LLM en tu máquina, exponiendo una API compatible con OpenAI en `http://localhost:11434`.

Trinit usa Ollama como su motor de inferencia local. El instalador de Trinit detecta y opcionalmente instala Ollama automáticamente.

### ¿Funciona en Windows, macOS y Linux?

Sí, en las tres plataformas. El instalador tiene versiones específicas para cada una:
- **Windows:** `install.ps1` (PowerShell)
- **macOS/Linux:** `install.sh` (bash)

### ¿Qué versión de VS Code necesito?

Trinit requiere VS Code. La versión mínima compatible no está especificada explícitamente en v0.1.0, pero se recomienda usar una versión reciente (1.85+).

---

## Preguntas sobre modelos y modos

### ¿Por qué hay 6 modos diferentes?

Cada modo está optimizado para un tipo de tarea:
- **Architect:** Planificación y diseño (no puede modificar código, solo `.md`)
- **Orchestrator:** Coordinación de tareas complejas multi-paso
- **Code:** Implementación (acceso completo a archivos y terminal)
- **Debug:** Diagnóstico sistemático (siempre pide confirmación antes de modificar)
- **Ask:** Consultas y explicaciones (solo lectura, nunca modifica nada)
- **OCR:** Extracción de texto de imágenes (usa modelo multimodal especializado)

### ¿Por qué el modo Ask usa un modelo diferente?

El modo Ask usa `gemma4:e2b` en lugar de `ornith:9b` porque las preguntas y explicaciones no requieren la capacidad de razonamiento agentico de ornith. Gemma 4 E2B es más ligero y suficientemente capaz para respuestas conversacionales, lo que reduce el consumo de recursos.

### ¿Puedo cambiar qué modelo usa cada modo?

En modo Full Local (por defecto), los modelos están vinculados y no se pueden cambiar desde la UI (el selector aparece bloqueado). Esto garantiza que siempre uses el modelo optimizado para cada tarea.

En modo Custom, puedes desbloquear cualquier modo y asignarle cualquier modelo o proveedor disponible.

### ¿Qué es el modo Full Local vs. Custom?

Hay un **toggle global** en la vista de modos (`ModesView.tsx`) que aplica un preset completo:

- **Full Local (por defecto):** Llama a `applyFullLocalPreset()` — bloquea todos los modos y resuelve cada modelo desde la tabla `LOCAL_MODE_BINDINGS`. Los selectores de configuración API aparecen deshabilitados en la UI.
- **Custom:** Llama a `applyCustomPreset()` — desbloquea `architect` y `orchestrator` por defecto, dejando el resto en local. El usuario puede desbloquear modos adicionales individualmente y asignarles cualquier modelo o proveedor (OpenAI, Anthropic, etc.).

### ¿Qué son los Teams?

Un Team es un conjunto curado de modos con sus vinculaciones de modelo. Instalar un Team activa todos sus modos y configura los modelos automáticamente. El "Trinit Core Team" incluye los 6 modos predefinidos con sus modelos locales.

En el futuro, habrá Teams especializados (Frontend Team, Data Science Team, etc.) disponibles en el marketplace.

### ¿Qué son los MCPs?

MCP (Model Context Protocol) son servidores que extienden las capacidades del agente con herramientas adicionales. Trinit incluye 5 MCPs predefinidos:
- `filesystem`: acceso al sistema de archivos
- `fetch`: peticiones HTTP
- `git`: operaciones Git
- `memory`: memoria persistente entre sesiones
- `sequential-thinking`: razonamiento estructurado

Estos se configuran automáticamente en la primera activación.

---

## Preguntas de privacidad y seguridad

### ¿Trinit envía telemetría?

No. La telemetría de Roo Code (PostHog) está desactivada en Trinit. No se envían datos de uso a ningún servidor externo.

### ¿El código que escribo en el chat se guarda en algún servidor?

No. El historial de conversaciones se guarda localmente en el `globalStorage` de VS Code (en tu máquina). Nunca sale de tu sistema.

### ¿Puedo usar Trinit con código bajo NDA?

Sí. Dado que ningún dato sale de tu máquina, no hay riesgo de violación de NDA. El código que compartes con Trinit solo lo ve el modelo local corriendo en tu hardware.

### ¿Es Trinit adecuado para entornos HIPAA/GDPR?

Técnicamente sí — Trinit no transmite datos a terceros. Sin embargo, el cumplimiento normativo depende de muchos factores más allá de la herramienta en sí. Consulta con tu equipo de compliance para una evaluación completa.

---

## Preguntas de instalación

### ¿Qué pasa si ya tengo Ollama instalado?

El instalador lo detecta, muestra la versión, y pregunta si quieres actualizarlo (default: No). Si no actualizas, continúa con la versión existente.

### ¿Qué pasa si ya tengo algunos modelos instalados?

El instalador verifica qué modelos están instalados y solo descarga los que faltan. Los modelos existentes no se tocan.

### ¿Puedo instalar Trinit sin internet?

La instalación inicial requiere internet para descargar los modelos y la extensión. Para entornos air-gapped, necesitarías:
1. Descargar los modelos en una máquina con internet y transferirlos
2. Descargar `trinit.vsix` de GitHub Releases y instalarlo manualmente con `code --install-extension trinit.vsix`

Esta funcionalidad está en el roadmap para versiones futuras.

### ¿Cómo actualizo Trinit?

Actualmente, la actualización es manual:
1. Descargar la nueva versión de `trinit.vsix` desde GitHub Releases
2. Ejecutar `code --install-extension trinit.vsix`

En versiones futuras, se añadirá un mecanismo de actualización automática.
