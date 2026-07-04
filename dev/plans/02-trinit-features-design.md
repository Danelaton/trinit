# Trinit Features — Implementation Design

> Generated: 2026-07-03
> Source repo: `C:\Users\User\Documents\Trinit\trinit-vscode`
> Companion doc: `dev/plans/zoo-code-index.md` (rebrand inventory), `dev/plans/01-trinit-architecture.md` (product vision), `models.yaml` (model manifest)
> Scope: 4 new subsystems — (1) Auth/Login Removal, (2) Per-Mode Model Binding, (3) Teams System, (4) Predefined MCPs

---

## 0. Cross-Cutting Context

Trinit is LOCAL-FIRST: Ollama running at `http://localhost:11434`, four predefined models pulled via `models.yaml`:

| Model | Ollama ref | Role |
|---|---|---|
| `ornith:9b` | agentic coding | → bound to `architect` (and general coding modes) |
| `glm-ocr:latest` | multimodal OCR | → bound to new `ocr` mode |
| `gemma4:e2b` / `gemma4:e4b` | multimodal chat/reasoning | general-purpose fallback |

All four subsystems below operate on the same fork currently mid-rebrand from Roo Code → Zoo Code → Trinit (see `zoo-code-index.md` for residual naming). Where relevant, apply the "Trinit" naming convention already established (e.g. `trinit-auth.ts`, `trinit.*` command IDs) to any new code.

### 0.1 Preservation Constraint (applies to all 4 subsystems)

**Everything that currently works must be preserved — minimal invasive changes only.** In particular:

- **Provider/model administration must remain fully intact.** The provider settings UI (`webview-ui/src/components/settings/providers/ApiOptions.tsx` and all its per-provider sub-components), the API configuration profile system (`ProviderSettingsManager.ts` — create/rename/delete/switch profiles, `apiConfigs` map, `currentApiConfigName`), and the ability to add/configure/switch between OpenAI, Anthropic, Ollama, OpenRouter, and every other existing provider stay exactly as they are today. Nothing in this design touches that machinery except where a specific provider (`trinit-gateway`) is itself the thing being removed because it cannot function without login.
- **Scope of removal is login/account/cloud-session functionality only** — not the provider system that happens to host one auth-requiring provider. Subsystem 1 below is written to delete/neutralize exactly: `trinit-auth.ts`, the `trinit-gateway` provider (which is unusable without a session token), and `packages/cloud`'s session/sharing/sync/telemetry-capture code. It explicitly does **not** touch `ProviderSettingsManager.ts`'s core CRUD, `ApiOptions.tsx`'s rendering for any other provider, or the Settings UI's "API Configuration" management (profile create/switch/delete) in any way.
- **Subsystem 2 (per-mode model binding) is additive.** It reuses the existing `modeApiConfigs` mode→config-id map and `setModeConfig`/`getModeConfigId`/`handleModeSwitch` mechanism verbatim (§2.1) — it does not replace, fork, or shadow that system with a new one. New behavior (seeding two profiles + pinning them to `architect`/`ocr`) is layered on top using the exact same APIs a user's manual per-mode selection already uses (`ModesView.tsx`'s existing config `<Select>`), so manual administration of any mode's model binding continues to work exactly as before for every other mode.
- **Practical implication for implementers:** when touching `ApiOptions.tsx`, `ProviderSettingsManager.ts`, or `ModesView.tsx`, changes must be additive/subtractive at the single-provider or single-mode granularity (e.g. delete the `trinit-gateway` case, add default seeding calls) — never a rewrite of the shared list/CRUD/switch logic those files provide for all other providers/modes.

---

## 1. Subsystem: Auth/Login Removal (login/account/cloud-session only — provider administration is out of scope and stays fully functional)

### 1.1 Current State Analysis

Two **independent** auth systems exist:

**(A) `src/services/trinit-auth.ts`** (264 lines) — powers only the optional `trinit-gateway` API provider.
- SecretStorage keys: `trinit-session-token`, `trinit-user-name`, `trinit-user-email`, `trinit-user-image` (L5-8)
- Key functions: `initTrinitAuth()` (L19), `isTrinitAuthenticated()` (L241), `resolveTrinitSessionToken()` (L80), `handleAuthCallback()` (L163), `disconnectTrinit()` (L246)
- Base URL: `getTrinitBaseUrl()` (L159) → `https://www.trinit.dev`
- Call sites: `src/extension.ts:53,164`; `src/activate/handleUri.ts:5,72,76`; `src/api/providers/trinit-gateway.ts:13,100,147,172`; `src/api/providers/fetchers/trinit-gateway.ts:6,27`; `src/core/webview/ClineProvider.ts:925,1788,2344-2346`; `src/core/webview/webviewMessageHandler.ts:2642`

**(B) `packages/cloud/` (`CloudService`)** — inherited Roo Code Cloud / Clerk auth, session, telemetry-sync, task-sharing system. **Already ~70% neutralized by a previous rebrand pass**:
- `CloudService.isEnabled()` hardcoded `return false` (`packages/cloud/src/CloudService.ts:436-438`)
- `sharingEnabled`, `publicSharingEnabled`, `taskSyncEnabled` hardcoded `false` (`ClineProvider.ts:2555,2557,2572`)
- `mdmCompliant` hardcoded `undefined` with comment `// Phase 1 cloud removal: do not let Cloud-auth MDM enforcement force login-only UI flows.` (`ClineProvider.ts:2459-2460`)
- `shareCurrentTask` handler just shows "sharing not enabled" (`webviewMessageHandler.ts:817-826`)
- Config still points at upstream Roo infra: `PRODUCTION_CLERK_BASE_URL = "https://clerk.roocode.com"`, `PRODUCTION_TRINIT_API_URL = "https://app.roocode.com"` (`packages/cloud/src/config.ts`)
- Consumers: `extension.ts:21,65,205-231,367-388` (init/dispose); `ClineProvider.ts` 9+ sites (all try/catch or `hasInstance()`-guarded); `Task.ts:1052,1085` (dead-gated telemetry); `MdmService.ts:6,69,81,85` (hard import dependency)

**Webview UI surfaces:**

| Component | Path | Status |
|---|---|---|
| `TrinitAuthBadge.tsx` | `webview-ui/src/components/chat/TrinitAuthBadge.tsx` | **Orphaned/dead code** — not imported anywhere. Safe delete. |
| `TrinitGateway.tsx` | `webview-ui/src/components/settings/providers/TrinitGateway.tsx` | **Live** — rendered in `ApiOptions.tsx:649` only when provider === `trinit-gateway`. Only real sign-in button in the whole app. |
| `useTrinitGatewayRouterModelsSync.ts` | `webview-ui/src/components/ui/hooks/` | Live, only used by `TrinitGateway.tsx` |
| `WelcomeViewProvider.tsx` | `webview-ui/src/components/welcome/` | Uses `trinitIsAuthenticated` only to pick default provider fallback; no visible login UI |
| `AccountView`, `RooCloudCTA` | — | **Do not exist** as real components (one is stale test-mock reference only) |
| `App.tsx:63,92-96` | `mdmCompliant` gate | Already permanently inert |

**Key finding:** No core feature (chat, task execution, Ollama usage) is gated behind auth anywhere. The only functioning login surface in the entire product is the Sign-In button inside the `trinit-gateway` provider's settings card.

### 1.2 Proposed Design

Given (a) the surface area already neutralized and (b) Trinit's zero-login requirement, do a **full removal** of the `trinit-gateway` provider (it is meaningless without a hosted backend and IS the only live login UI) plus a **stub-and-simplify** of `packages/cloud` (too many files import the class/types to delete the package outright in one pass without high regression risk).

Decision: **remove, don't just hide**, for anything user-visible; **stub, don't delete**, for anything with broad type-level fan-out (`packages/cloud`).

**Explicitly preserved / unaffected (verify with a smoke test after implementation):** `ApiOptions.tsx`'s provider dropdown and every provider card other than `TrinitGateway.tsx` (OpenAI, Anthropic, Ollama, OpenRouter, Bedrock, Vertex, etc.); `ProviderSettingsManager.ts`'s `upsertProviderProfile`/`listConfig`/`activateProviderProfile`/delete-profile flows; the Settings → "API Configuration" profile switcher; `ModesView.tsx`'s per-mode config `<Select>` for every mode other than the two newly-locked ones in Subsystem 2. None of these are touched by Steps A–C below except by deleting the single `trinit-gateway` case/import inside them.

### 1.3 Exact Implementation Steps

**Step A — Remove `trinit-gateway` provider entirely (kills the only live login UI)**
1. Delete `src/api/providers/trinit-gateway.ts`, `src/api/providers/fetchers/trinit-gateway.ts`, `src/services/trinit-auth.ts`, `src/services/trinit-gateway-credentials-sync.ts`.
2. Delete `webview-ui/src/components/settings/providers/TrinitGateway.tsx`, `webview-ui/src/components/ui/hooks/useTrinitGatewayRouterModelsSync.ts`, `webview-ui/src/components/chat/TrinitAuthBadge.tsx`.
3. Remove `"trinit-gateway"` from `packages/types/src/provider-settings.ts`: `providerNames` union, `dynamicProviders` array (L42), `zooGatewaySchema`/`zooGatewayDefaultModelId` (L455 area), `providerInfo` map entry (L704).
4. Remove provider entry from `packages/types/src/providers/index.ts` (model list switch, ~L124).
5. Remove `{ value: "trinit-gateway", ... }` from `webview-ui/src/components/settings/constants.ts:67`.
6. Remove render block + import in `webview-ui/src/components/settings/providers/ApiOptions.tsx` (L76 import, L648-657 render).
7. Strip `trinit-gateway` case + `trinitIsAuthenticated` param from `webview-ui/src/utils/validate.ts` (L20,22,42,135-139,306).
8. Remove `trinitIsAuthenticated` destructure/usage from `webview-ui/src/components/welcome/WelcomeViewProvider.tsx` (L25,33,42,49,64,73,92) — falls back to whatever the next default provider is (recommend hardcoding `ollama` as the fallback here, see Subsystem tie-in below).
9. Strip 3 dynamic-import sites in `src/core/webview/ClineProvider.ts` (L925, 1788, 2344-2346: `ensureTrinitGatewayProfileSeeded()`, `handleTrinitCallback()`) and the `trinit*` webview-state fields it feeds.
10. Remove `trinitSignOut` case in `webviewMessageHandler.ts:2642`.
11. Remove `initTrinitAuth` import/call in `src/extension.ts:53,164`.
12. Remove `/auth-callback` route in `src/activate/handleUri.ts:5,72,76`.
13. Update AUTH_SCOPED_PROVIDERS set in `src/api/providers/fetchers/modelCache.ts:47` to drop `trinit-gateway`.

**Step B — Neutralize `packages/cloud` (stub, keep package for type compatibility)**
1. In `packages/cloud/src/CloudService.ts`: keep the class shell; `createInstance()` should become effectively a no-op that never opens network connections — i.e. skip `WebAuthService`/`CloudSettingsService`/`RetryQueue`/`TelemetryClient` construction entirely and just set an internal `initialized=false` flag; `hasInstance()` stays `false` thereafter.
2. In `src/extension.ts:205-231`: wrap `CloudService.createInstance()` behind a feature flag constant (e.g. `const CLOUD_ENABLED = false`) so it's never called at all — simplest, zero-risk change (one `if` guard), avoids touching 18 downstream call sites since they're all already `hasInstance()`/try-catch guarded.
3. In `src/services/mdm/MdmService.ts`: remove the `@trinit/cloud` import; hardcode `isCompliant()` → `{ compliant: true }` (1-line change, matches the existing `mdmCompliant: undefined` pattern already in `ClineProvider.ts:2459`).
4. Leave `webviewMessageHandler.ts`'s `rooCloudSignIn/cloudLandingPageSignIn/rooCloudSignOut/rooCloudManualUrl` cases as-is (already guarded by `isCloudServiceAvailable()`, degrade silently to "Cloud unavailable" — but since Step B.2 means `CloudService.hasInstance()` is always false, dead code paths never execute; can be deleted in a later cleanup pass, not required for MVP zero-login).
5. Leave `ClineProvider.ts`'s try/catch-wrapped `cloudIsAuthenticated`/`cloudUserInfo`/`cloudOrganizations`/`organizationAllowList` reads in place — they already default to `false`/empty/`[]` when `CloudService.hasInstance()===false`; no user-visible cloud/account UI renders from them anywhere in webview-ui (confirmed zero webview-ui imports of `@trinit/cloud`).

**Step C — Default provider becomes Ollama (ties into removing the login-requiring option)**
1. `src/core/config/ProviderSettingsManager.ts` — set `createDefaultProfile()`/initial factory to `apiProvider: "ollama"`.
2. `packages/types/src/global-settings.ts` — add `.default("ollama")` to `apiProvider` field.
3. `webview-ui/src/components/settings/constants.ts` — move `{ value: "ollama", label: "Ollama" }` to top of dropdown list.
4. `webview-ui/src/components/welcome/WelcomeViewProvider.tsx` — hardcode fallback to `"ollama"` (replacing the now-removed `trinitIsAuthenticated` branch logic).
5. `apps/cli/src/lib/utils/provider.ts:26` — update CLI fallback provider.

### 1.4 Risks

| Risk | Mitigation |
|---|---|
| Deleting `trinit-gateway` provider breaks any saved user profiles referencing it | Add a one-time migration in `ProviderSettingsManager` migrations block that reassigns any config with `apiProvider==="trinit-gateway"` to `"ollama"` |
| `@trinit/cloud` package still needs to compile (18 files import types) | Keep package, only stub internals (Step B), don't delete the package |
| `MdmService` behavior change (always compliant) could matter for enterprise users | Not applicable — Trinit has no enterprise/MDM story; explicitly acceptable |
| Removing `handleUri.ts` `/auth-callback` route could 404 on stale deep-links from old installs | Low risk (new product, no existing user base with old links); optionally leave a no-op handler that just closes silently |

**Effort estimate: Small–Medium (1–2 days).** Most of the "hard" work (neutralizing sharing/sync/MDM) was already done by a previous pass; this is mostly deletion + import cleanup + 2 migration lines.

---

## 2. Subsystem: Per-Mode Model Binding

### 2.1 Current State Analysis

**Mode schema** — `packages/types/src/mode.ts:96-111` (`modeConfigSchema`):
```ts
export const modeConfigSchema = z.object({
  slug: z.string().regex(/^[a-zA-Z0-9-]+$/),
  name: z.string().min(1),
  roleDefinition: z.string().min(1),
  whenToUse: z.string().optional(),
  description: z.string().optional(),
  customInstructions: z.string().optional(),
  groups: groupEntryArraySchema,
  source: z.enum(["global", "project"]).optional(),
  allowedMcpServers: z.array(z.string()).optional(),
})
```
No `apiConfigId` field on the mode itself — **but the binding already exists one layer down.**

**THE key existing mechanism** — `src/core/config/ProviderSettingsManager.ts`:
```ts
// L36-51
export const providerProfilesSchema = z.object({
  currentApiConfigName: z.string(),
  apiConfigs: z.record(z.string(), providerSettingsWithIdSchema),
  modeApiConfigs: z.record(z.string(), z.string()).optional(),  // mode slug -> config id
  cloudProfileIds: z.array(z.string()).optional(),
  migrations: z.object({...}).optional(),
})
```
- Persisted in `context.secrets` under `roo_cline_config_api_config` (L613)
- `setModeConfig(mode, configId)` (L509-524), `getModeConfigId(mode)` (L529-538)
- Auto-seeded for every built-in mode on fresh install (L59-75) and migrated for existing installs (L113-123)

**Auto-apply wiring** — `src/core/webview/ClineProvider.ts`:
- `handleModeSwitch(newMode)` (L1411-1496): looks up `getModeConfigId(newMode)`, and if a saved config exists, calls `activateProviderProfile({name})` (L1454-1470) which rebuilds the actual API handler talking to Ollama. If no config saved yet, persists the *current* config as that mode's default (L1490) — first-use bootstrapping.
- A workspace setting `lockApiConfigAcrossModes` (L1447, `workspaceState`) can disable this whole mechanism — must ensure it's `false`/unset for Trinit's "always this model" requirement to hold.
- Same lookup runs on **task resume from history** (L1009-1029) — resumed subtasks reapply their mode's pinned config.
- Also runs during **new_task delegation**: `delegateParentAndOpenChild()` (L3417-3587) calls `handleModeSwitch(mode)` at **L3485-3497** *before* creating the child task — so delegating to a different mode automatically switches to that mode's pinned model. No new plumbing needed here.

**UI** — `webview-ui/src/components/modes/ModesView.tsx:930-957` — an inline `<Select>` of `listApiConfigMeta` per mode; changing it posts `loadApiConfiguration` → `webviewMessageHandler.ts:2055-2065` → `activateProviderProfile()` → `setModeConfig(currentMode, id)` (`ClineProvider.ts:1675`). This is literally the existing "pin a config to a mode" UI, just not labeled as such.

**Built-in `architect` mode** (`packages/types/src/mode.ts:176-186`): `groups: ["read", ["edit", {fileRegex: "\\.md$"}], "mcp"]`, `customInstructions` tells it to use `switch_mode` (not `new_task`) to hand off to the user — **it does not currently delegate via new_task at all**.

**Built-in `orchestrator` mode** (L221-232): `groups: []` (no direct tool access), `customInstructions` explicitly instructs breaking work into subtasks via `new_task`, choosing "the most appropriate mode for each subtask."

**`new_task` delegation tool** — `src/core/tools/NewTaskTool.ts` (145 lines): params `{mode, message, todos?}` (L14-18); resolves target mode via `getModeBySlug()` (L92); calls `provider.delegateParentAndOpenChild({parentTaskId, message, initialTodos, mode})` (L113-118).

**`.roomodes` format** confirmed — YAML `{ customModes: ModeConfig[] }`, project-scope modes take precedence over global on slug collision (`CustomModesManager.ts` merge logic L226-247, L356-402).

### 2.2 Proposed Design

No schema changes needed for the binding mechanism itself — reuse `modeApiConfigs`. Work needed:

1. **Create two dedicated Ollama provider profiles** at first-run (or via a setup script), pinned as the default config for their respective modes:
   - `"Architect (ornith)"` → `{ apiProvider: "ollama", ollamaModelId: "ornith:9b" }`
   - `"OCR (glm-ocr)"` → `{ apiProvider: "ollama", ollamaModelId: "glm-ocr:latest" }`
2. **Define the new `ocr` mode** in `.roomodes` (or as a built-in `DEFAULT_MODES` entry in `packages/types/src/mode.ts` if it should ship regardless of project — recommended, since it's core to Trinit, not project-specific).
3. **Seed `modeApiConfigs`** at first activation: `setModeConfig("architect", architectProfileId)`, `setModeConfig("ocr", ocrProfileId)` — one-time, guarded by a `globalState` flag (mirroring the `allowedCommands` seeding pattern in `extension.ts:170-172`).
4. **Give architect delegation capability to `ocr`**: extend architect's `customInstructions` to also cover "if the user's request involves reading/extracting from images, scanned documents, or screenshots, delegate to the `ocr` mode via `new_task` before continuing the plan" — OR, simpler and more consistent with existing patterns, rely on `orchestrator` (which already delegates freely) to route OCR subtasks to `ocr`, and additionally teach architect a narrower delegation instruction only for OCR-shaped subtasks (since architect's job is planning, not full multi-mode orchestration).
5. **Enforce "ALWAYS"**: ensure `lockApiConfigAcrossModes` workspace setting defaults to unset/false so the auto-apply-on-switch behavior (§2.1) is never bypassed; additionally consider making these two specific mode→config bindings **non-overridable from the UI** (stretch goal, see Risks) so a user can't accidentally point `architect` at a different model via the `ModesView.tsx` selector.

### 2.3 New `ocr` Mode Definition

```yaml
- slug: ocr
  name: 🔎 OCR
  roleDefinition: >-
    You are Trinit in OCR mode, a specialist for extracting and structuring
    text, tables, and figures from images, scanned documents, and screenshots.
    You always use the glm-ocr multimodal model to read visual content
    precisely and return clean, structured text/markdown.
  whenToUse: >-
    Use this mode when the task involves reading text from an image,
    screenshot, scanned PDF, photographed document, table, or diagram that
    requires OCR/multimodal extraction rather than pure code reasoning.
  description: Multimodal OCR extraction from images and documents
  groups:
    - read
    - - edit
      - fileRegex: \.(md|txt|json)$
        description: Extracted text/markdown/JSON output files only
  source: project   # or promote to a DEFAULT_MODES built-in, see 2.2 step 2
```

### 2.4 Exact Implementation Steps

1. `packages/types/src/mode.ts` — (Option A, recommended) add `ocr` to `DEFAULT_MODES` array (L174-232 region) alongside `architect`/`orchestrator`, so it ships regardless of `.roomodes`. (Option B) add it to the repo's `.roomodes` as a project mode instead, if it should be considered "custom" rather than core.
2. `src/core/config/ProviderSettingsManager.ts` — extend the default-seeding block (L59-75) to also create the two Ollama profiles above and call `setModeConfig()` for `architect`/`ocr` immediately after `apiConfigs` are seeded, guarded so this only happens once on genuinely first run (reuse existing migration-guard pattern already in this file, L113-123).
3. `packages/types/src/mode.ts` — update architect's `customInstructions` (L176-186) to add the OCR-delegation instruction described in §2.2 step 4.
4. No changes needed to `handleModeSwitch()`, `delegateParentAndOpenChild()`, or `NewTaskTool.ts` — the existing mechanism already satisfies "mode switch ⇒ pinned model switch" including through delegation.
5. (Stretch) `webview-ui/src/components/modes/ModesView.tsx` — for modes flagged as "locked" (new optional field, e.g. `modeConfigSchema.lockedApiConfigId?: string`, or a simpler client-side hardcoded list `["architect", "ocr"]`), render the API-config `<Select>` as disabled/read-only with a tooltip explaining "This mode always uses X".
6. Verify `models.yaml` model refs (`ornith:9b`, `glm-ocr:latest`) match exactly what's passed as `ollamaModelId` in the seeded profiles.

### 2.5 Risks

| Risk | Mitigation |
|---|---|
| User manually changes the API config while in architect/ocr mode via the existing `ModesView.tsx` selector, breaking the "ALWAYS" guarantee | Implement the stretch goal in step 5 (lock the selector for these 2 modes), or at minimum document that changing it breaks the guarantee |
| `lockApiConfigAcrossModes` workspace setting could be toggled on by a user/import, silently breaking per-mode binding | Default it false and treat it as an advanced/hidden setting for Trinit's UI (or remove the toggle from Trinit's settings UI entirely) |
| Ollama model not yet pulled (`ornith:9b`/`glm-ocr:latest` missing locally) when mode is first used | Out of scope for this design but should surface a clear error/redirect to model-pull flow (ties into the broader Ollama-detection wizard from `01-trinit-architecture.md`) |
| Architect's OCR-delegation instruction is prompt-engineering, not code — reliability depends on model following instructions | Acceptable for MVP; could be hardened later with a deterministic router (e.g. detect image attachments in the initial task and auto-suggest/force `ocr` mode) |

**Effort estimate: Small (1 day)** for the base pinning; **+ Small–Medium (1–1.5 days)** for the Full Local / Custom preset layer below.

### 2.6 "Full Local" vs "Custom" Operating Mode (additive layer on top of §2.1–2.5)

**Requirement recap:** Default = everything on Ollama with enforced local bindings (`architect→ornith:9b`, `ocr→glm-ocr:latest`, other modes → appropriate local model). If the user explicitly configures an external provider (OpenAI/Anthropic/etc.), they gain the freedom to point `architect`/`orchestrator` (the reasoning-heavy modes) at that stronger model — other modes can stay local or also be overridden, per the user's choice. **Provider management (§0.1) is the enabling mechanism, not something replaced.**

**Design — non-destructive lock layer over the existing `modeApiConfigs` map (no new provider system, no fork of `ProviderSettingsManager`):**

1. **Schema addition** — extend `providerProfilesSchema` (`ProviderSettingsManager.ts:36-51`) with one optional field:
   ```ts
   modeApiConfigLocks: z.record(z.string(), z.boolean()).optional(), // mode slug -> locked-to-local
   ```
   `true` (default for every built-in mode on fresh install) = mode is forced to its Trinit local binding regardless of what `modeApiConfigs[mode]` stores; `false` = mode behaves exactly like vanilla Roo/Zoo Code today (whatever the user picks in `ModesView.tsx`'s existing `<Select>` is used as-is, including non-Ollama providers). This is purely additive metadata sitting beside the existing map — `modeApiConfigs[mode]` itself is **never deleted or overwritten** when locked, so toggling back to unlocked instantly restores whatever the user previously chose for that mode.
2. **Local binding table** (constants, e.g. `src/shared/localModeBindings.ts`): `Record<modeSlug, ollamaModelId>` — `{ architect: "ornith:9b", ocr: "glm-ocr:latest", code: "ornith:9b", debug: "ornith:9b", ask: "gemma4:e4b", orchestrator: "ornith:9b" }` (exact non-architect/ocr assignments are a product-content decision; mechanism is agnostic to the table's contents).
3. **Resolution logic** — one small change in `ClineProvider.handleModeSwitch()` (`ClineProvider.ts:1454`, right where `getModeConfigId(newMode)` is currently called):
   ```ts
   const locked = providerProfiles.modeApiConfigLocks?.[newMode] ?? true // default locked
   const savedConfigId = locked
     ? await this.providerSettingsManager.getOrCreateLocalProfileFor(newMode) // resolves/creates the seeded local-binding profile
     : await this.providerSettingsManager.getModeConfigId(newMode)            // existing vanilla lookup, unchanged
   ```
   This is the **only** functional touch-point in the existing mechanism from §2.1 — everything else (`delegateParentAndOpenChild` → `handleModeSwitch`, task-resume re-application, `activateProviderProfile`) is reused unmodified since it just receives a resolved `configId` either way.
4. **"Custom" unlock trigger** — two ways to flip `modeApiConfigLocks[mode] = false`, both non-destructive:
   - **Global preset toggle** in a new "Operating Mode" control (Settings, or a banner in `ModesView.tsx`): "Full Local" (default) vs "Custom". Switching to Custom sets `modeApiConfigLocks[mode] = false` for **architect + orchestrator only** by default (matches "reasoning-heavy modes get the freedom"); other modes stay locked unless individually unlocked (see below). Switching back to "Full Local" re-locks everything without touching the stored `modeApiConfigs` values underneath.
   - **Per-mode unlock affordance** in `ModesView.tsx`'s existing per-mode API-config `<Select>` (`ModesView.tsx:930-957`): when a mode is locked, render the `<Select>` disabled with a small "🔒 Full Local — Unlock to use a different provider" label + unlock icon button; clicking it sets `modeApiConfigLocks[thisMode] = false` and immediately enables the `<Select>` (now identical to vanilla behavior — pick any existing API config profile, including a newly-added OpenAI/Anthropic one). This gives the exact "other execution modes can stay local or also be overridden" granularity per mode, reusing the **same** selector/message flow (`loadApiConfiguration` → `activateProviderProfile` → `setModeConfig`) already documented in §2.1 — no new webview message types needed, just a conditional `disabled` prop and one new postMessage case (`setModeApiConfigLock`) to flip the boolean.
   - **Passive nudge (optional, not required for MVP):** when `webviewMessageHandler.ts`'s `upsertApiConfiguration` handler detects a newly created profile with `apiProvider !== "ollama"`, show a one-time toast: "New provider added — switch Architect/Orchestrator to Custom to use it?" linking to the toggle. Pure UX sugar; the mechanism in steps 1-4 works with or without this prompt.
5. **First-run default:** `modeApiConfigLocks` seeded to `{ [every built-in + ocr mode]: true }` in the same seeding pass as §2.4 step 2 (Full Local is the out-of-the-box experience, matching "Full Local mode (DEFAULT)").

**Exact implementation steps (additive to §2.4):**
1. `packages/types/src/provider-settings.ts` (or co-located with `providerProfilesSchema`) — add `modeApiConfigLocks` field.
2. `src/shared/localModeBindings.ts` (new) — the local binding table constant.
3. `src/core/config/ProviderSettingsManager.ts` — add `getOrCreateLocalProfileFor(mode)` (idempotent: finds-or-creates the Ollama profile matching the binding table entry) and `setModeApiConfigLock(mode, locked)`.
4. `src/core/webview/ClineProvider.ts` — the 3-line resolution change in `handleModeSwitch()` (§2.6 step 3); add `setModeApiConfigLock` webview-message case in `webviewMessageHandler.ts` alongside the existing `loadApiConfiguration` case (`webviewMessageHandler.ts:2055-2065`).
5. `webview-ui/src/components/modes/ModesView.tsx` — conditional `disabled` + lock/unlock affordance on the existing per-mode `<Select>` (`ModesView.tsx:930-957`); optional global "Operating Mode" banner/toggle.
6. Seed `modeApiConfigLocks: { ... all true }` alongside the `modeApiConfigs` seeding added in §2.4 step 2.

**Risks (additive to §2.5):**

| Risk | Mitigation |
|---|---|
| Global toggle and per-mode unlock could get out of sync (e.g. user unlocks one mode, then hits "Full Local" preset expecting only that mode affected) | Define precisely: the global toggle is a **bulk-set convenience** (sets all locks at once), per-mode unlock is a **fine-grained override** — clicking the global "Full Local" preset always re-locks everything (explicit, predictable, documented in a tooltip), not a "smart merge" |
| `getOrCreateLocalProfileFor()` must not collide with a user's own manually-named Ollama profile | Use a reserved naming/id convention (e.g. profile id prefix `trinit-local-<mode>`) distinct from user-created profile names/ids |
| This adds a second lookup path in `handleModeSwitch` — regression risk to the well-tested vanilla path | Keep the vanilla `getModeConfigId()` call completely unchanged for the `locked===false` branch (§2.6 step 3) so Custom-mode behavior is byte-for-byte identical to upstream Roo/Zoo Code today |

**Effort estimate for §2.6 alone: Small–Medium (1–1.5 days).**

---

## 3. Subsystem: Teams System (marketplace/teams)

### 3.1 Current State Analysis

**Manager (extension host):** `src/services/marketplace/MarketplaceManager.ts` (299 lines) — orchestrator owning a `ConfigLoader` + `SimpleInstaller`; instantiated in `ClineProvider.ts:268`. Key methods: `getMarketplaceItems()` (L36), `filterItems()` (L61), `installMarketplaceItem()` (L105), `checkProjectInstallations()`/`checkGlobalInstallations()` (L210/258).

**Data source — 100% local, no remote registry:** `src/services/marketplace/ConfigLoader.ts` (69 lines): `marketplacePath = path.join(extensionPath, "assets", "marketplace")` (L25); reads `src/assets/marketplace/modes.yml` (4486 lines) and `mcps.yml` (3032 lines) via `fs.readFile` + `yaml.parse`, validated with Zod. `organizationMcps` field exists but is always `[]` (stub for future remote source, unused).

**Install code path (modes):** UI → posts `installMarketplaceItem` → `webviewMessageHandler.ts:3133` → `MarketplaceManager.installMarketplaceItem()` → `SimpleInstaller.installMode()` (`SimpleInstaller.ts:34-155`) → wraps YAML as `{customModes:[parsedMode]}` → `CustomModesManager.importModeWithRules(importYaml, target)` (`CustomModesManager.ts:927`) → validates against `modeConfigSchema`, writes to `.roomodes` (project) or global `custom_modes.yaml` (global) via `updateCustomMode()` (L982), imports any `rulesFiles[]`.

**Type schema** — `packages/types/src/marketplace.ts` (93 lines):
```ts
baseMarketplaceItemSchema: { id, name, description, author?, authorUrl?, tags?[], prerequisites?[] }
modeMarketplaceItemSchema: extends base + content: string (YAML block)
mcpMarketplaceItemSchema: extends base + url: string, content: string | McpInstallationMethod[], parameters?
marketplaceItemSchema: z.discriminatedUnion("type", [mode, mcp])
installMarketplaceItemOptionsSchema: { target: "global"|"project", parameters? }
```

**UI tab structure:** `webview-ui/src/components/marketplace/MarketplaceView.tsx` (167 lines) — hardcoded 2-tab bar (`"mcp" | "mode"`, L130-141) with an animated underline assuming exactly 2 tabs (L118-129, `left-0`/`left-1/2` classes). `MarketplaceListView.tsx` (294 lines) is a generic, `filterByType`-parameterized list/grid renderer reused for both tabs. `MarketplaceItemCard.tsx` (284 lines) + `MarketplaceInstallModal.tsx` (386 lines) handle per-item install UX (scope radio, install-method dropdown, parameter inputs).

**Filter/search/tags:** Both `MarketplaceManager.filterItems()` (L61) and webview `MarketplaceViewStateManager.filterItems()` (L306) share identical logic: type, substring search, tag any-match, install-status. No existing "category" concept beyond freeform tags.

**Built-in modes to always include:** `architect` (`packages/types/src/mode.ts:176`) and `orchestrator` (L221) are already `DEFAULT_MODES`, always present regardless of `.roomodes` — this simplifies "every team always includes architect+orchestrator" since those two never need explicit installation.

### 3.2 Proposed Design

**Team = a named, curated set of mode slugs + their model bindings.** Since `architect`+`orchestrator` are already always-on built-ins, a team definition really only needs to enumerate the *additional* modes it wants active (plus, optionally, override model bindings for any mode including architect/orchestrator themselves).

**Schema (new, `packages/types/src/marketplace.ts` addition):**
```ts
export const teamModeBindingSchema = z.object({
  slug: z.string(),                 // mode slug to activate/ensure present
  modelId: z.string().optional(),   // ollama model ref to pin, e.g. "ornith:9b"
})

export const teamMarketplaceItemSchema = baseMarketplaceItemSchema.extend({
  type: z.literal("team"),
  modes: z.array(teamModeBindingSchema).min(1),   // does NOT need to list architect/orchestrator explicitly — always injected
  version: z.string().optional(),                  // for "future: specialized teams (versioned)"
})

export const marketplaceItemSchema = z.discriminatedUnion("type", [
  modeMarketplaceItemSchema,
  mcpMarketplaceItemSchema,
  teamMarketplaceItemSchema,        // NEW
])
```

**Data source:** new `src/assets/marketplace/teams.yml`, loaded by a new `ConfigLoader.fetchTeams()` (parallel to `fetchModes()`/`fetchMcps()`).

**Default team ("Generic"):**
```yaml
items:
  - id: team-generic
    type: team
    name: Generic Team
    description: >-
      The default Trinit team — architect and orchestrator for planning, plus
      code, debug, ask, and a dedicated OCR specialist.
    tags: [default, general]
    modes:
      - slug: architect
        modelId: ornith:9b
      - slug: orchestrator
      - slug: code
      - slug: debug
      - slug: ask
      - slug: ocr
        modelId: glm-ocr:latest
```
(`architect`/`orchestrator` are listed here mainly to declare their model bindings for this team; the install logic always ensures both are present even if a future specialized team omits them.)

**Install flow (`SimpleInstaller.ts` extension):**
1. Add `case "team":` to `installItem()`'s dispatch (currently `mode`/`mcp` only, L24-31).
2. `installTeam(item, target)`:
   - Force-union `["architect", "orchestrator"]` into `item.modes` if not already present (satisfies "EVERY team always includes architect + orchestrator").
   - For each mode in the resolved set: if it's a custom (non-built-in) mode slug not yet present, install it the same way `installMode()` does (reuse `CustomModesManager.importModeWithRules()` — likely needs the mode's full definition bundled either inline in `teams.yml` or cross-referenced against `modes.yml`'s catalog by slug).
   - For each mode with a `modelId`: resolve/create an Ollama provider profile for that model (idempotent — reuse if a profile with that exact `ollamaModelId` already exists) and call `providerSettingsManager.setModeConfig(slug, profileId)` (the same mechanism as Subsystem 2).
3. Add `removeTeam()` symmetric to `removeMode()`/`removeMcp()` (optional for MVP — teams are additive/rarely removed).

**UI:**
1. Widen `ViewState["activeTab"]` in `MarketplaceViewStateManager.ts:25` to `"mcp" | "mode" | "team"`.
2. `MarketplaceView.tsx` — add third tab button, change underline math from halves to thirds (`w-1/3`, `left-0`/`left-1/3`/`left-2/3`).
3. Add `filterByType="team"` render branch (reusing `MarketplaceListView.tsx` — it's already generic).
4. New `TeamCard.tsx` (can largely copy `MarketplaceItemCard.tsx`): shows team name/description + a compact list of bundled modes and their pinned models; Install button opens a slightly adapted `MarketplaceInstallModal` (scope radio only — no per-item parameters needed since teams don't have secrets, just mode/model bindings).
5. `App.tsx` — widen `targetTab` prop type to include `"team"`.
6. `MarketplaceManager.checkProjectInstallations()`/`checkGlobalInstallations()` (`MarketplaceManager.ts:210,258`) — extend "installed" detection for a team: a team is "installed" iff all of its constituent mode slugs are present in `.roomodes`/global custom modes.

### 3.3 Exact Implementation Steps

1. `packages/types/src/marketplace.ts` — add `teamModeBindingSchema`, `teamMarketplaceItemSchema`, extend the discriminated union.
2. `src/assets/marketplace/teams.yml` — create with the single default "Generic Team" entry (§3.2). Mirror into `dist/assets/marketplace/` build output path (same as existing `modes.yml`/`mcps.yml` duplication pattern).
3. `src/services/marketplace/ConfigLoader.ts` — add `fetchTeams()` (L~47 pattern), wire into `loadAllItems()`.
4. `src/services/marketplace/SimpleInstaller.ts` — add `installTeam()`/`removeTeam()`, wire into `installItem()`/`removeItem()` dispatch (L21-31).
5. `src/services/marketplace/MarketplaceManager.ts` — extend `checkProjectInstallations`/`checkGlobalInstallations` (L210-298) for team-level "installed" status.
6. `webview-ui/src/components/marketplace/MarketplaceViewStateManager.ts` — widen `activeTab` type (L25), extend `transition()`'s `SET_ACTIVE_TAB` handling.
7. `webview-ui/src/components/marketplace/MarketplaceView.tsx` — 3rd tab button + underline math (L118-141).
8. `webview-ui/src/components/marketplace/components/TeamCard.tsx` — new component (copy pattern from `MarketplaceItemCard.tsx`).
9. `webview-ui/src/App.tsx` — widen `targetTab`/`Tab` types (L26, L242-248).
10. Reuse existing filter/search/tag machinery unchanged (§3.1) — no new filter subsystem required.

### 3.4 Risks

| Risk | Mitigation |
|---|---|
| A future specialized team references a mode slug not present in `modes.yml`'s catalog | Require team-referenced custom mode content to be inlined in `teams.yml` (like `modeMarketplaceItemSchema.content`) rather than assuming cross-file lookup, OR validate at build/CI time that every referenced slug resolves |
| Installing a team could silently overwrite a user's existing manual model binding for `architect`/`ocr` | `installTeam()` should check `getModeConfigId()` first and only set if unset, or explicitly prompt "this team will change your architect model to ornith:9b — proceed?" |
| UI tab-underline math and 2-tab assumptions scattered elsewhere | Grep for other `"mcp"|"mode"` literal-union usages beyond `MarketplaceView.tsx`/`MarketplaceViewStateManager.ts` before shipping (e.g. webviewMessageHandler filter cases) to avoid missed spots |
| "Only 1 default team for now" — schema/UI should not over-engineer for versioned specialized teams yet | Keep `version` field optional/unused for MVP; defer specialized-team UX (e.g. team categories, compare view) to a future iteration |

**Effort estimate: Medium (2–3 days).** Mode/MCP marketplace plumbing is a strong, directly reusable template; the main net-new work is the install-time "ensure architect+orchestrator present" logic and the 3rd UI tab.

---

## 4. Subsystem: Predefined MCPs

### 4.1 Current State Analysis

**McpHub** — `src/services/mcp/McpHub.ts` (2524 lines): manages MCP server lifecycle (stdio/sse/streamable-http transports), watches both global and project config files, exposes `updateServerConnections(newServers, source, ...)` (L1566-1633) as the central "apply this server map" entry point.

**Settings file schema (defined inline in McpHub.ts, not `packages/types`):**
```ts
// L72-78
BaseConfigSchema = z.object({
  disabled: z.boolean().optional(),
  timeout: z.number().min(1).max(3600).optional().default(60),
  alwaysAllow: z.array(z.string()).default([]),
  watchPaths: z.array(z.string()).optional(),
  disabledTools: z.array(z.string()).default([]),
})
// L94-145: createServerTypeSchema() — union of stdio {command,args,cwd,env} / sse {url,headers} / streamable-http {url,headers}
// L148: ServerConfigSchema = createServerTypeSchema()
// L151-153: McpSettingsSchema = z.object({ mcpServers: z.record(ServerConfigSchema) })
```

**Global settings file location & first-run creation — the key insertion point:**
- Filename: `GlobalFileNames.mcpSettings = "mcp_settings.json"` (`src/shared/globalFileNames.ts:4`)
- Directory: `ClineProvider.ensureSettingsDirectoryExists()` → `<globalStorage>/settings/` (`ClineProvider.ts:1725-1729`, `src/utils/storage.ts:63-68`)
- **`McpHub.getMcpSettingsFilePath()` (L496-517)** — called on every access; if the file doesn't exist, writes an **empty scaffold**:
  ```ts
  if (!fileExists) {
    await fs.writeFile(mcpSettingsFilePath, `{\n  "mcpServers": {\n\n  }\n}`)
  }
  ```
  **This exact spot is where default servers should be seeded instead of an empty object.**
- Project file `.roo/mcp.json` — only read if it already exists (`getProjectMcpPath()`, L603-614); no auto-creation.

**Marketplace MCP flow (for comparison/reuse):** `src/assets/marketplace/mcps.yml` (3032 lines, ~dozens of community servers with `{{PLACEHOLDER}}` parameters for secrets) loaded by `ConfigLoader.fetchMcps()` (L47-58). Install writes into the **same** `mcp_settings.json` (global) or `.roo/mcp.json` (project), keyed by `item.id` (`SimpleInstaller.ts:226-279`). "Already installed" detection (`MarketplaceManager.checkGlobalInstallations()`, L258-298) is just a key-presence check against the live config file — **meaning a pre-seeded default server automatically shows as "already installed" in the marketplace if it shares the same id.**

**No existing default/built-in MCP list found anywhere** (`McpHub.ts`, `McpServerManager.ts`, `extension.ts`, `migrateSettings.ts` all searched). Closest precedent for "seed once, track via flag": `extension.ts:170-172`:
```ts
if (!context.globalState.get("allowedCommands")) {
  context.globalState.update("allowedCommands", defaultCommands)
}
```
and `migrateSettings.ts:130-167`'s `defaultCommandsMigrationCompleted` flag pattern.

**Webview MCP tab** — `webview-ui/src/components/mcp/McpView.tsx` (544 lines): lists servers with a `source` badge ("global"/"project", L272-284), toggle/delete/restart controls, and a "Marketplace" button that deep-links to the marketplace MCP tab (L136-153).

### 4.2 Proposed Design

1. **New bundled catalog file**: `src/assets/marketplace/default-mcps.json` (or `.yml` for consistency with the others) — a small, curated list of MCP servers Trinit ships pre-configured (list TBD by user later; format matches `ServerConfigSchema` entries keyed by server id, e.g. filesystem, git, or similar zero-secret servers suitable for local-first defaults).
2. **Seeding function**: `seedDefaultMcpServers(context)` in a new file `src/services/mcp/defaultMcpServers.ts`:
   - Reads the bundled catalog.
   - Guarded by `context.globalState.get("mcpDefaultsSeeded")` (mirrors `allowedCommands`/`defaultCommandsMigrationCompleted` pattern) — only runs once, so a user who deletes a default server later doesn't get it silently re-added on every activation.
   - Reads the current `mcp_settings.json` (creating the directory if needed, but NOT going through `McpHub.getMcpSettingsFilePath()`'s empty-scaffold path — instead write the seeded map directly on first run).
   - Merges catalog entries into `existingData.mcpServers` (only adding keys not already present, in case a partial file already exists from a prior partial install).
   - Sets `context.globalState.update("mcpDefaultsSeeded", true)`.
3. **Activation wiring**: call `seedDefaultMcpServers(context)` in `src/extension.ts`, right alongside the existing `migrateSettings(context, outputChannel)` call (~L137), and **before** `McpServerManager.getInstance()` is constructed in `ClineProvider`'s constructor so the hub picks up the seeded servers on its first `initializeGlobalMcpServers()` pass — no changes needed to `McpHub`'s own file-read/connect logic, since it just reads whatever is in `mcp_settings.json` at that point.
4. **Marketplace differentiation (optional, low-effort)**: give seeded default servers the same `id` as their corresponding `mcps.yml` marketplace entry (if one exists) so `checkGlobalInstallations()` naturally shows them as "Installed" with no extra code; optionally extend `McpView.tsx`'s server-row badge (L272-284) with a `"default"` label (read from a small `DEFAULT_SERVER_IDS` set) so users understand which servers came pre-installed vs. manually added.

### 4.3 Exact Implementation Steps

1. Create `src/assets/marketplace/default-mcps.json` (schema = `Record<string, ServerConfig>`, same shape as `McpSettingsSchema.mcpServers`) — placeholder/empty-array structure now, populated once the user provides the final default MCP list.
2. Create `src/services/mcp/defaultMcpServers.ts` — exports `seedDefaultMcpServers(context: vscode.ExtensionContext)`:
   - Uses `GlobalFileNames.mcpSettings` + `getSettingsDirectoryPath()` (reuse from `src/utils/storage.ts`) to locate the file.
   - Reads/merges/writes JSON (reuse `fileExistsAtPath` helper already used by `McpHub.ts`).
   - Guards via `context.globalState`.
3. `src/extension.ts` — import and call `seedDefaultMcpServers(context)` near `migrateSettings()` (~L137), before `ClineProvider`/`McpServerManager` construction.
4. (Optional) `webview-ui/src/components/mcp/McpView.tsx` — extend `ServerRow`'s badge rendering (L272-284) with a `"default"` indicator, sourced from a new `isDefaultServer` field piggybacked onto the `McpServer` webview-state shape (would require `McpHub.getAllServers()` or the webview-state mapper to flag it — minor plumbing addition, not required for MVP).
5. No changes needed to `McpHub.ts` core logic, `ServerConfigSchema`, or the marketplace MCP install flow — this subsystem is purely additive/seed-time.

### 4.4 Risks

| Risk | Mitigation |
|---|---|
| Final default MCP server list is "TBD by user later" | Design is list-agnostic — `default-mcps.json` can be populated at any time without further code changes; ship the seeding mechanism now with an empty/minimal placeholder list |
| Re-seeding on every activation could resurrect servers a user intentionally deleted | The `mcpDefaultsSeeded` globalState guard makes seeding strictly one-time |
| Some default MCP servers may need env vars/secrets (like marketplace `{{PLACEHOLDER}}` params) | Prefer default servers that need zero configuration (e.g. local filesystem/git-type servers) for true "auto-installed" UX; if a future default needs secrets, seeding should leave it `disabled: true` until the user configures it, rather than seeding an already-broken enabled entry |
| Duplicate/conflicting server id between a seeded default and a marketplace item | Intentional (see §4.2.4) — treat as a feature (shows "Installed") rather than a bug, but document the convention so future marketplace catalog entries don't accidentally collide with unrelated defaults |

**Effort estimate: Small (0.5–1 day)**, excluding time to curate the actual default server list (a product/content decision, not engineering).

---

## 5. Recommended Implementation Order & Effort Summary

| Order | Subsystem | Rationale | Effort |
|---|---|---|---|
| 1 | **Auth/Login Removal** | Removes the only live login surface and the default-provider dependency; unblocks a genuinely zero-login first-run experience. Should land before shipping any onboarding flow. | Small–Medium (1–2 days) |
| 2 | **Per-Mode Model Binding** | Core to Trinit's local-model value prop (architect=ornith, ocr=glm-ocr); the underlying mechanism already exists, just needs seeding + a new mode. Low risk, high product value, do it early since Teams depends on it. | Small (1 day) |
| 3 | **Predefined MCPs** | Independent, low-risk, purely additive; can proceed in parallel with #2, but sequenced after Auth removal since activation-order changes (Step 3 of Subsystem 1) touch `extension.ts` similarly to Subsystem 4's seeding call — avoid merge conflicts by doing them close together. | Small (0.5–1 day) |
| 4 | **Teams System** | Builds directly on Subsystem 2's model-binding mechanism (teams assign models per mode) and reuses the marketplace UI patterns; most naturally done last since it's the most UI-heavy and depends on the other three being stable. | Medium (2–3 days) |

**Total estimated effort: ~5–7 days** for all four subsystems, assuming the investigation findings above hold once implementation begins (recommend a quick `pnpm turbo run check-types` after each subsystem to catch fork-specific drift before moving to the next).

---

## 6. Open Questions for Follow-up

1. Should the new `ocr` mode ship as a `DEFAULT_MODES` built-in (always present) or as a project-level `.roomodes` entry (opt-in per workspace)? (Recommended: built-in, since OCR delegation is core to the product.)
2. What is the final list of predefined MCP servers to bundle (Subsystem 4)? Currently unresolved ("TBD by user later") — engineering work is unblocked regardless, but content curation is pending.
3. Should the `architect`/`ocr` mode→model bindings be hard-locked in the UI (Subsystem 2, §2.4 step 5 stretch goal), or is it acceptable for advanced users to override them via the existing `ModesView.tsx` selector?
4. For future specialized/versioned Teams (Subsystem 3), should team-referenced custom modes be inlined in `teams.yml` or resolved by cross-referencing `modes.yml`'s catalog by slug? (Recommended: inline, for self-containment and easier versioning.)
