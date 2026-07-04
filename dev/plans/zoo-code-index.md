# Zoo Code Fork — Rebrand Roadmap to Trinit

> Generated: 2026-07-03  
> Source repo: `C:\Users\User\Documents\Trinit\trinit-vscode`  
> Fork lineage: Roo Code → Zoo Code → **Trinit** (in progress)

---

## 1. Directory Structure

| Path | Role |
|------|------|
| `src/` | VS Code extension host — activation, API handlers, services, webview provider |
| `webview-ui/` | React/Vite frontend rendered inside the VS Code webview panel |
| `packages/types/` | Shared Zod schemas + TypeScript types (provider settings, events, modes, API) |
| `packages/core/` | Platform-agnostic agent logic (message utils, task history, custom tools, worktree) |
| `packages/cloud/` | Zoo/Trinit cloud auth, settings sync, telemetry client |
| `packages/ipc/` | IPC client/server for CLI ↔ extension communication |
| `packages/telemetry/` | PostHog telemetry wrapper |
| `packages/vscode-shim/` | VS Code API mock for CLI/Node environments |
| `packages/build/` | Shared esbuild/tsup build helpers |
| `packages/config-eslint/` | Shared ESLint config |
| `packages/config-typescript/` | Shared TypeScript base configs |
| `apps/cli/` | Standalone CLI (`@roo-code/cli`) — runs the agent outside VS Code |
| `apps/vscode-e2e/` | End-to-end VS Code extension tests |
| `apps/vscode-nightly/` | Nightly build manifest (`zoo-code-nightly`) |
| `locales/` | Translated CONTRIBUTING.md and README.md (ca, de, es, fr, hi, id, it, ja, ko, nl, pl, pt-BR, ru, tr, vi, zh-CN, zh-TW) |
| `schemas/` | JSON schemas (e.g. `.roomodes`) |
| `scripts/` | Repo-level helper scripts |
| `bin/` | Output directory for `.vsix` packages |

---

## 2. Branding Inventory

### 2a. Already Rebranded to "Trinit"

| Category | File | Key Lines | Notes |
|----------|------|-----------|-------|
| Extension metadata | `src/package.json` | L2–6 | `name: "trinit"`, `displayName: "Trinit"`, `publisher: "DanElaton"` |
| Extension metadata | `src/package.json` | L61–64 | View container id `trinit-ActivityBar`, sidebar id `trinit.SidebarProvider` |
| Extension metadata | `src/package.json` | L69–169 | All commands prefixed `trinit.*` |
| Extension metadata | `src/package.json` | L297–434 | All config keys prefixed `trinit.*` |
| NLS strings | `src/package.nls.json` | L2–7 | `displayName`, `contextMenu.label`, `activitybar.title`, `configuration.title` all = `"Trinit"` |
| Provider label | `packages/types/src/provider-settings.ts` | L704 | `"trinit-gateway": { label: "Trinit Gateway" }` |
| Provider key | `packages/types/src/provider-settings.ts` | L42 | `"trinit-gateway"` in `dynamicProviders` array |
| Auth service | `src/services/trinit-auth.ts` | L5–8 | Secret storage keys: `trinit-session-token`, `trinit-user-name`, etc. |
| Auth service | `src/services/trinit-auth.ts` | L159–160 | `getZooCodeBaseUrl()` returns `https://www.trinit.dev` |
| Settings UI | `webview-ui/src/components/settings/constants.ts` | L67 | `{ value: "trinit-gateway", label: "Trinit Gateway" }` |
| Package.ts | `src/shared/package.ts` | L13 | `outputChannel: "Zoo-Code"` ← **still Zoo-Code** |

### 2b. Residual "Zoo Code" / "ZooCode" Strings (need Trinit rebrand)

| Category | File | Line(s) | String |
|----------|------|---------|--------|
| **Output channel** | `src/shared/package.ts` | L13 | `outputChannel: "Zoo-Code"` |
| **Webview panel title** | `src/activate/registerCommands.ts` | L254 | `createWebviewPanel(…, "Roo Code", …)` |
| **Log message** | `src/activate/registerCommands.ts` | L25 | `"Cannot find any visible Roo Code instances."` |
| **Extension comment** | `src/extension.ts` | L72, L100–102 | `"Zoo Code sidebar"`, `"Zoo Code auth service"` |
| **E2E test suite** | `apps/vscode-e2e/src/suite/extension.test.ts` | L6 | `suite("Zoo Code Extension", …)` |
| **E2E test** | `apps/vscode-e2e/src/suite/index.ts` | L11 | `getExtension("ZooCodeOrganization.zoo-code")` |
| **E2E test** | `apps/vscode-e2e/src/suite/index.ts` | L31 | `executeCommand("zoo-code.SidebarProvider.focus")` |
| **E2E test** | `apps/vscode-e2e/src/suite/providers/bedrock.test.ts` | L74, L84, L90, L95, L140 | `ZooCode#` user-agent assertions |
| **E2E test** | `apps/vscode-e2e/src/suite/providers/openrouter.test.ts` | L143, L159, L162–167 | `"Zoo Code"` X-Title header, `Zoo-Code-Org/Zoo-Code` referer |
| **E2E test** | `apps/vscode-e2e/src/suite/tools/terminal-profile.test.ts` | L172, L179 | `"Zoo Code"` terminal name |
| **Nightly manifest** | `apps/vscode-nightly/package.nightly.json` | L2 | `"name": "zoo-code-nightly"` |
| **Nightly NLS** | `apps/vscode-nightly/package.nls.nightly.json` | L2–6 | All display strings = `"Zoo Code Nightly"` |
| **CHANGELOG** | `CHANGELOG.md` | L1, L113, L121, L138, L140, L147, L184–202 | `"Zoo Code Changelog"`, `"Zoo Code"` throughout |
| **CONTRIBUTING** | `CONTRIBUTING.md` | L14, L16, L57, L60, L74, L83–93, L102, L176 | `"Zoo Code"` throughout |
| **Locales** | `locales/*/CONTRIBUTING.md`, `locales/*/README.md` | many | `"Zoo Code"` in all 17 locale files |
| **Gateway handler** | `src/api/providers/trinit-gateway.ts` | L141 | `ZOO_GATEWAY_AUTH_ERROR` const string mentions "Zoo Code" |
| **Gateway handler** | `src/api/providers/trinit-gateway.ts` | L157–158 | Headers `X-Zoo-Editor`, `X-Zoo-Extension-Version` |
| **Gateway handler** | `src/api/providers/trinit-gateway.ts` | L200–203 | Headers `X-Zoo-Task-ID`, `X-Zoo-Mode` |
| **CLI runtime config** | `apps/cli/src/agent/extension-host.ts` | L450 | `setRuntimeConfigValues("zoo-code", …)` |
| **CLI test** | `apps/cli/src/agent/__tests__/extension-host.test.ts` | L264 | `expect(setRuntimeConfigValues).toHaveBeenCalledWith("zoo-code", …)` |
| **CLI UI** | `apps/cli/src/ui/components/Header.tsx` | L35 | `"Roo Code CLI v${version}"` |
| **CLI onboarding** | `apps/cli/src/ui/components/onboarding/OnboardingScreen.tsx` | L17 | `"Welcome! Roo Code works without login."` |
| **CLI auth status** | `apps/cli/src/commands/auth/status.ts` | L27, L42 | `"Roo Code Router has been removed"` |
| **CLI upgrade** | `apps/cli/src/commands/cli/upgrade.ts` | L6, L8 | GitHub URLs pointing to `RooCodeInc/Roo-Code` |
| **CLI README** | `apps/cli/README.md` | L1, L3, L7, L13, L16, L27, L33, L41, L68, L137, L147, L222 | `@roo-code/cli`, `Roo Code CLI`, install URLs |

### 2c. Residual "@roo-code/" Package Scopes (internal workspace packages)

All internal packages still use the `@roo-code/` npm scope. These are workspace-internal and not published externally (except `@roo-code/types`), but they appear in every `package.json`, `import` statement, and `turbo.json` across the monorepo.

| Package | Current name | Target name |
|---------|-------------|-------------|
| `packages/types` | `@roo-code/types` | `@trinit/types` |
| `packages/core` | `@roo-code/core` | `@trinit/core` |
| `packages/cloud` | `@roo-code/cloud` | `@trinit/cloud` |
| `packages/ipc` | `@roo-code/ipc` | `@trinit/ipc` |
| `packages/telemetry` | `@roo-code/telemetry` | `@trinit/telemetry` |
| `packages/vscode-shim` | `@roo-code/vscode-shim` | `@trinit/vscode-shim` |
| `packages/build` | `@roo-code/build` | `@trinit/build` |
| `packages/config-eslint` | `@roo-code/config-eslint` | `@trinit/config-eslint` |
| `packages/config-typescript` | `@roo-code/config-typescript` | `@trinit/config-typescript` |
| `apps/cli` | `@roo-code/cli` | `@trinit/cli` |

> **Note:** `RooCodeSettings`, `RooCodeAPI`, `RooCodeEventName` are exported TypeScript types from `@roo-code/types`. These are part of the public API surface and must be renamed carefully (or aliased for backward compat).

### 2d. TypeScript Identifiers Still Using "Roo/Zoo" Naming

| Identifier | File | Notes |
|-----------|------|-------|
| `RooCodeSettings` | `packages/types/src/global-settings.ts:285` | Core settings type, used everywhere |
| `RooCodeAPI` | `packages/types/src/api.ts` | Public extension API interface |
| `RooCodeEventName` | `packages/types/src/events.ts:11` | Event enum |
| `ZooGatewayHandler` | `src/api/providers/trinit-gateway.ts:143` | Gateway API handler class |
| `zooGatewaySchema` | `packages/types/src/provider-settings.ts:455` | Zod schema |
| `zooGatewayDefaultModelId` | `packages/types/src/…` | Constant |
| `DEFAULT_AUTO_CLOSE_ZOO_OPENED_FILES` | `packages/types/src/global-settings.ts` | Constant |
| `getRooCodeApiUrl` | `packages/cloud/src/…` | Cloud API URL helper |
| `initZooCodeAuth` | `src/services/trinit-auth.ts:19` | Auth init function |
| `clearZooCodeToken` | `src/services/trinit-auth.ts` | Token management |
| `isZooCodeAuthenticated` | `src/services/trinit-auth.ts` | Auth check |

---

## 3. Provider System

### Where Providers Are Defined

| File | Role |
|------|------|
| `packages/types/src/provider-settings.ts` | Master provider registry: Zod schemas, `providerNames` union, `dynamicProviders`, `localProviders`, `providerInfo` map |
| `packages/types/src/providers/index.ts` | Per-provider model lists and `getModelInfo()` switch |
| `src/api/index.ts` | `buildApiHandler()` factory — maps `apiProvider` string to handler class (line 189 for `trinit-gateway`) |
| `src/api/providers/` | One file per provider handler (e.g. `trinit-gateway.ts`, `ollama.ts`, `openrouter.ts`) |
| `src/api/providers/fetchers/modelCache.ts` | Dynamic model list cache; `AUTH_SCOPED_PROVIDERS` set (line 47) |
| `webview-ui/src/components/settings/constants.ts` | UI provider dropdown list (line 67) |

### Ollama Provider

- **Schema** (`packages/types/src/provider-settings.ts:265–267`):
  ```ts
  const ollamaSchema = baseProviderSettingsSchema.extend({
    ollamaModelId: z.string().optional(),
    ollamaBaseUrl: z.string().optional(),
  })
  ```
- **Handler**: `src/api/providers/ollama.ts` — calls `http://localhost:11434` (or `ollamaBaseUrl`) via the `ollama` npm package
- **Model discovery**: `src/api/providers/fetchers/modelCache.ts` — `localProviders` are fetched from localhost; Ollama is in `localProviders` array (`packages/types/src/provider-settings.ts:62`)
- **Embeddings**: `src/services/code-index/embedders/ollama.ts` — separate embedder for code indexing

### Making Ollama the Default Provider

The default provider is set when a new profile is created. To make Ollama the default:

1. **`src/core/config/ProviderSettingsManager.ts`** — find the `createDefaultProfile()` or initial settings factory and set `apiProvider: "ollama"`.
2. **`packages/types/src/global-settings.ts`** — the `rooCodeSettingsSchema` default for `apiProvider` (currently unset, falls through to `undefined`). Add `.default("ollama")` to the `apiProvider` field.
3. **`webview-ui/src/components/settings/constants.ts`** — move `{ value: "ollama", label: "Ollama" }` to the top of the provider list so it appears first in the UI dropdown.
4. **`apps/cli/src/lib/utils/provider.ts:26`** — the CLI `buildProviderConfig()` function; update the fallback provider.

---

## 4. Agent Modes

### How `.roomodes` Works

- **File**: `.roomodes` at workspace root (YAML format, JSON fallback)
- **Manager**: `src/core/config/CustomModesManager.ts`
  - Constant `ROOMODES_FILENAME = ".roomodes"` (line 19)
  - Loads on startup and watches for file changes (line 316)
  - `.roomodes` takes **precedence** over VS Code settings-stored custom modes (line 297–327)
  - Merges project modes (from `.roomodes`) with global modes (from settings), project wins on slug collision (line 301)
  - Schema validated via `packages/types/src/mode.ts` → `modeConfigSchema`

### Current `.roomodes` in This Repo

The repo ships 4 project modes in `.roomodes`:

| Slug | Name | Purpose |
|------|------|---------|
| `translate` | 🌐 Translate | Manage localization files |
| `issue-fixer` | 🔧 Issue Fixer | Fix GitHub issues |
| `pr-fixer` | 🛠️ PR Fixer | Address PR review feedback |
| `merge-resolver` | 🔀 Merge Resolver | Resolve merge conflicts |

All 4 modes reference "Zoo" in their `roleDefinition` (e.g. `"You are Zoo, a…"`).

### Mode Switching UI

- **Component**: `webview-ui/src/components/chat/ModeSelector.tsx` — dropdown in the chat input bar
- **Chat integration**: `webview-ui/src/components/chat/ChatView.tsx:1531–1547` — `switchToMode()`, `switchToNextMode()`, `switchToPreviousMode()`
- **Text area**: `webview-ui/src/components/chat/ChatTextArea.tsx:49` — `setMode` prop
- **Modes management page**: `webview-ui/src/components/modes/ModesView.tsx:175` — `switchMode()` callback

### How Custom Modes Are Loaded

1. `CustomModesManager.getCustomModes()` reads `.roomodes` (YAML/JSON) + VS Code global state
2. Merged list is pushed to `ClineProvider` via `updateGlobalState("customModes", …)`
3. Webview receives modes via `ExtensionState` message
4. `webview-ui/src/context/ExtensionStateContext.tsx` exposes `customModes` to all components

---

## 5. Build System

### pnpm Workspace Layout

```
pnpm-workspace.yaml
├── src/           (VS Code extension — "should be apps/vscode" per comment)
├── webview-ui/    (React frontend — "should be apps/vscode-webview" per comment)
├── apps/*         (cli, vscode-e2e, vscode-nightly)
└── packages/*     (types, core, cloud, ipc, telemetry, vscode-shim, build, config-*)
```

### Turbo Pipeline (`turbo.json`)

| Task | Depends on | Outputs |
|------|-----------|---------|
| `build` | (none, per-package) | `dist/**` |
| `test` | `@roo-code/types#build` | — |
| `test:coverage` | `@roo-code/types#build` | `coverage/**` |
| `lint` | — | — |
| `check-types` | — | — |
| `bundle` (src only) | `turbo run bundle --cwd ..` | `dist/extension.js` |

### Build Commands

```bash
# Install dependencies
pnpm install

# Build all packages
pnpm turbo run build

# Build only the extension bundle (esbuild)
pnpm --filter src bundle

# Type-check everything
pnpm turbo run check-types

# Run all tests
pnpm turbo run test

# Package as .vsix (output: bin/trinit-<version>.vsix)
pnpm --filter src vsix

# Full marketplace publish
pnpm --filter src publish:marketplace
```

The extension bundler is `src/esbuild.mjs` (custom esbuild script). The webview uses Vite (`webview-ui/vite.config.ts`).

---

## 6. Entry Points

### Extension Activation

- **File**: `src/extension.ts`
- **Export**: `activate(context: vscode.ExtensionContext)` (line 122)
- **Activation events** (`src/package.json:45–48`): `onLanguage`, `onStartupFinished`
- **Activation sequence**:
  1. Load `.env` (optional, dev only)
  2. `initializeNetworkProxy()`
  3. `migrateSettings()`
  4. Initialize `TelemetryService` + `PostHogTelemetryClient`
  5. Initialize `MdmService`
  6. `initializeI18n()`
  7. `TerminalRegistry.initialize()`
  8. `openAiCodexOAuthManager.initialize()`
  9. `initZooCodeAuth()` — loads session token from `SecretStorage`
  10. Create `ContextProxy`, `CodeIndexManager[]`
  11. Create `ClineProvider` (sidebar)
  12. `registerCommands()`, `registerCodeActions()`, `registerTerminalActions()`
  13. Register `handleUri()` for OAuth callbacks
  14. Initialize `CloudService`, `McpServerManager`

### Webview Setup

- **Provider**: `src/core/webview/ClineProvider.ts`
  - Sidebar id: `trinit.SidebarProvider` (line 155)
  - Tab panel id: `trinit.TabPanelProvider` (line 156)
  - `resolveWebviewView()` (line 776) — sets up HTML, message handlers, state hydration
- **Frontend entry**: `webview-ui/src/index.tsx` → `webview-ui/src/App.tsx`
- **Dev mode**: Vite dev server at `http://localhost:5173`; production uses bundled `webview-ui/dist/`

### Command Registration

- **File**: `src/activate/registerCommands.ts`
- **Function**: `registerCommands(options)` (line 65) — iterates `getCommandsMap()` and calls `vscode.commands.registerCommand()`
- **Command IDs**: All prefixed `trinit.*` (defined in `src/package.json` and typed in `packages/types/src/…`)
- **Code actions**: `src/activate/registerCodeActions.ts`
- **Terminal actions**: `src/activate/registerTerminalActions.ts`

---

## 7. Gateway/API — `trinit-gateway` Provider

### What It Connects To

The `trinit-gateway` provider is a **hosted AI gateway** operated at `https://www.trinit.dev/api/gateway/v1` (configurable via `ZOO_CODE_BASE_URL` env var or `zooGatewayBaseUrl` setting).

It proxies requests to upstream LLM providers (same model set as Vercel AI Gateway) using an OpenAI-compatible streaming API.

### How It Works

| Component | File | Notes |
|-----------|------|-------|
| Handler class | `src/api/providers/trinit-gateway.ts:143` | `ZooGatewayHandler extends RouterProvider` |
| Auth | `src/services/trinit-auth.ts` | Session token stored in VS Code `SecretStorage` under key `trinit-session-token` |
| Base URL | `src/services/trinit-auth.ts:159–160` | `getZooCodeBaseUrl()` → `ZOO_CODE_BASE_URL` env or `https://www.trinit.dev` |
| Model fetcher | `src/api/providers/fetchers/trinit-gateway.ts` | `getZooGatewayModels()` — fetches model list from gateway |
| Model cache | `src/api/providers/fetchers/modelCache.ts:47` | `AUTH_SCOPED_PROVIDERS` includes `"trinit-gateway"` — token required to fetch models |
| Credentials sync | `src/services/trinit-gateway-credentials-sync.ts` | `postZooGatewayCredentialsReady()` — syncs token to all gateway profiles |
| Webview component | `webview-ui/src/components/settings/providers/ZooGateway.tsx` | Settings UI for the gateway |
| Auth flow | OAuth callback via `handleUri()` in `src/activate/` | Redirect URI: `${uriScheme}://${publisher}.${name}/auth-callback` |

### Request Headers Sent

```
X-Zoo-Editor: vscode
X-Zoo-Extension-Version: <version>
X-Zoo-Task-ID: <taskId>   (per-request)
X-Zoo-Mode: <mode>        (per-request)
```

### Error Handling

| HTTP Status | Action |
|------------|--------|
| 401 | Clear token → prompt sign-in → open `trinit.dev/dashboard/connect` |
| 402 / 429 (budget) | Prompt add credits → open `trinit.dev/dashboard/credits` |
| 403 | Prompt contact support → open `trinit.dev/support` |

---

## Rebrand Checklist Summary

### High Priority (breaks functionality or identity)

- [ ] `src/shared/package.ts:13` — change `outputChannel: "Zoo-Code"` → `"Trinit"`
- [ ] `src/activate/registerCommands.ts:254` — change `"Roo Code"` panel title → `"Trinit"`
- [ ] `apps/vscode-e2e/src/suite/index.ts:11` — update extension ID from `ZooCodeOrganization.zoo-code` to `DanElaton.trinit`
- [ ] `apps/vscode-nightly/package.nightly.json` + `package.nls.nightly.json` — rebrand nightly to `trinit-nightly`
- [ ] `.roomodes` — update `roleDefinition` strings from `"You are Zoo"` → `"You are Trinit"` (4 modes)
- [ ] `apps/cli/src/commands/cli/upgrade.ts:6,8` — update GitHub release URLs from `RooCodeInc/Roo-Code` to the Trinit repo

### Medium Priority (user-visible strings)

- [ ] `apps/cli/src/ui/components/Header.tsx:35` — `"Roo Code CLI"` → `"Trinit CLI"`
- [ ] `apps/cli/src/ui/components/onboarding/OnboardingScreen.tsx:17` — `"Roo Code"` → `"Trinit"`
- [ ] `apps/cli/src/commands/auth/status.ts:27,42` — `"Roo Code Router"` → `"Trinit"`
- [ ] `src/api/providers/trinit-gateway.ts:141` — `ZOO_GATEWAY_AUTH_ERROR` message
- [ ] `src/api/providers/trinit-gateway.ts:157–203` — HTTP headers `X-Zoo-*` → `X-Trinit-*`
- [ ] `CHANGELOG.md` — update header and references
- [ ] `CONTRIBUTING.md` + all `locales/*/CONTRIBUTING.md` — update Zoo Code references

### Low Priority (internal identifiers — rename when convenient)

- [ ] `@roo-code/*` package scopes → `@trinit/*` (large refactor, touch every import)
- [ ] TypeScript identifiers: `RooCodeSettings`, `RooCodeAPI`, `RooCodeEventName`, `ZooGatewayHandler`, `zooGatewaySchema`, etc.
- [ ] `apps/cli/src/agent/extension-host.ts:450` — `setRuntimeConfigValues("zoo-code", …)` → `"trinit"`
- [ ] E2E test assertions for `ZooCode#` user-agent and `Zoo Code` X-Title header (update after gateway headers change)
