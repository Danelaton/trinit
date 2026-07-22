# Work Summary — Trinit

> Período: 2026-07-14 a 2026-07-16 · Release: v0.1.1

---

## 1. Restauración baseline Zoo Code (providers)

**PR #11 trinit-vscode** — `6ddc94e9ec6b9ec194eed5d8c263ff956fae3630`

7 archivos de providers reemplazados/parcheados desde Zoo Code:

| Archivo | Cambios |
|---|---|
| `src/api/transform/openai-format.ts` | +89 |
| `src/api/providers/native-ollama.ts` | +305 |
| `src/api/providers/vscode-lm.ts` | +90 |
| `src/api/providers/anthropic.ts` | +35 |
| `src/api/providers/anthropic-vertex.ts` | +8 |
| `src/api/providers/bedrock.ts` | +1 |
| `src/api/index.ts` | +7 |

Bugs resueltos:
- `reasoning_content` DeepSeek/Z.ai (`openai-format.ts`)
- Razonamiento multi-turno (`native-ollama.ts`)
- `completePrompt` Anthropic Vertex (`anthropic-vertex.ts`)
- `guessModelInfoFromId` + `claude-sonnet-5` (`anthropic.ts`, `bedrock.ts`)
- `getCondenseContextWindow` restaurado (`vscode-lm.ts`)

Verificación funcional: onboarding, teams, no-telemetría intactos. 149/149 tests core pasando.

---

## 2. Branding y marketplace

**PR #12** — `37ecaa1d5704c79e0dda2d568fa19aa984af3441`

Fix branding `roomodes-schema`: Roo Code → Trinit. Corrige la identidad del esquema de modos para que la UI muestre "Trinit" en lugar de "Roo Code" en los selectores y labels de modo.

**PR #13** — `785dbb686c4f6c9be80a64221bfffc8b3e8f6196`

Removido `IssueFooter` ("Open a GitHub issue") del marketplace. El componente inyectaba un enlace al repo de issues en la vista de marketplace, lo cual era inconsistente con la experiencia de Trinit como producto local.

---

## 3. Fix Gemini "Unexpected API response"

**PR #14** — `71d3bae3250927acc813e08ecc25a04ede946ab4`

Causa raíz: `finishReason` (SAFETY, RECITATION, BLOCKLIST, etc.) era capturado por el handler de Gemini pero nunca verificado en `gemini.ts`. El stream terminaba sin error explícito, produciendo "Unexpected API response" genérico.

Cambios:
- Detección y lanzamiento de error específico con mensaje i18n en `en`/`es`
- Logging de diagnóstico gateado tras setting `trinit.debug`

**PR #16** — `faad570696ef77cea2e9738926111fd6d53ea775`

3 gaps adicionales diagnosticados y cerrados:

1. **Stream vacío con `finishReason=STOP`**: el modelo Gemini puede devolver un stream vacío con STOP (sin error real). Ahora se detecta como error claro y reintentable en lugar de fallar silenciosamente.
2. **Errores del SDK de Google**: los errores del SDK (`GoogleGenerativeAIError`) no propagaban el HTTP status real (429, 503, etc.) — se mostraba "API Request Failed" genérico. Ahora se extrae y propaga el código HTTP.
3. **Bloques desconocidos en `gemini-format.ts`**: los bloques de tipo desconocido se descartaban silenciosamente, causando que mensajes de usuario desaparecieran del historial (el modelo respondía al system prompt en lugar del mensaje). Ahora se preservan como texto seguro.

Tests: 63/63 (24 gemini.spec + 20 gemini-format.spec + 19 gemini-handler.spec).

---

## 4. Clean Uninstall

**PR #15 trinit-vscode** — `8c970fc3f7f579a35a5a29aaa8efb1454117f483`

Comando `Trinit: Reset All Data` (`trinit.resetAllData`):
- Borra `globalStorage`, secrets, task history, MCP OAuth tokens, custom modes
- **NUNCA toca Ollama ni modelos descargados**

**Repo padre** — commit `ca297df1e5227297abb076e4028d8cec243717e4`

Flags `-CleanUninstall` / `--clean-uninstall` + variable de entorno `TRINIT_CLEAN_UNINSTALL` en `install.ps1` e `install.sh`.

**Repo padre** — commit `3324357b911ea7bf17e770212fe9b02922c28447`

Opción `[4]` "Clean Uninstall" agregada al menú interactivo del instalador con confirmación explícita.

**Repo padre** — commit `a658b5c2da3e57141c5ac472e6438edfe340339f`

Fix: confirmación auto-cancelada bajo `curl | sh` — lectura desde `/dev/tty` para evitar que el pipe cierre stdin.

---

## 5. Release v0.1.1

**Tag**: `v0.1.1` · **Published**: 2026-07-15T05:00:31Z · **Updated**: 2026-07-16T19:18:23Z

| Propiedad | Valor |
|---|---|
| Asset único | `trinit.vsix` |
| SHA256 | `3feabf43433c7042935d97fe09ff47c9554a816d5aa5cd51322252fbadd9fe27` |
| Build | Commit `faad570` del submódulo (`trinit-vscode`) |
| Submódulo HEAD | `faad570696ef77cea2e9738926111fd6d53ea775` |

Verificado: submódulo HEAD = build local = asset publicado = release notes.

---

## 6. Decisiones de diseño relevantes

- **Ollama nunca se toca en clean uninstall**: el reset de datos de Trinit elimina exclusivamente artifacts propios de la extensión (`globalStorage`, secrets, task history, MCP OAuth, custom modes). Ollama y sus modelos son gestionados por el usuario fuera del scope de Trinit.
- **`trinitFreshInstallMigrated` descartado**: se consideró un flag para detectar instalaciones frescas y ejecutar migraciones. Descartado por riesgo de resetear perfiles de usuarios existentes que ya hubieran pasado por el flujo de instalación.
- **Rebuilds reemplazan asset en release existente**: cuando se requiere un rebuild del `.vsix`, el asset se reemplaza en el mismo release tag en lugar de crear un tag nuevo. Esto mantiene la URL de descarga estable y evita proliferación de releases.
- **Teams se mantiene completo**: el sistema de teams (marketplace, Trinit Core Team, MCPs predefinidos) no fue alterado en ninguna de las PRs de este período.