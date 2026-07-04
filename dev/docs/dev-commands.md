# Trinit — Dev Commands

## Rebuild & Reinstall Extension

```bash
cd trinit-vscode
pnpm build
cd src
npx vsce package --no-dependencies --out ../bin
code --install-extension ../bin/trinit-0.1.0.vsix
```

## Dev Mode (F5 in VS Code)

```bash
# Open trinit-vscode/ in VS Code → F5 → Extension Development Host
code trinit-vscode/
```

## Update from Upstream (Zoo-Code)

```bash
cd trinit-vscode
git fetch upstream
git merge upstream/main
# Resolve conflicts in command IDs (trinit.* vs zoo-code.*)
node scripts/rebrand.mjs
pnpm build
cd src && npx vsce package --no-dependencies --out ../bin
code --install-extension ../bin/trinit-0.1.0.vsix
```

## One-liner Install

```powershell
# Windows
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
```

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

## Index Codebase (codebase-memory-mcp)

```bash
BIN="$HOME/.local/bin/codebase-memory-mcp.exe"

# Index
$BIN cli index_repository '{"repo_path": "C:/Users/User/Documents/Trinit/trinit-vscode"}'

# Architecture
$BIN cli get_architecture '{"project": "C-Users-User-Documents-Trinit-trinit-vscode", "aspects": ["all"]}'

# Search
$BIN cli search_graph '{"project": "C-Users-User-Documents-Trinit-trinit-vscode", "label": "Function", "query": "ollama", "limit": 10}'
```

## Release

```bash
# Tag and push → GitHub Actions builds and creates release
git tag v0.1.0
git push origin v0.1.0
```
