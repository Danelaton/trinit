# Trinit — Deployment Scenarios

> Version: v0.1.0 · Date: 2026-07-04

---

## 1. Deployment scenarios

### 1.1 Individual developer

**Profile:** Freelancer, independent developer, or employee who wants AI assistance without compromising the privacy of their code.

**Requirements:**
- Laptop or desktop with 16 GB RAM (minimum), 32 GB recommended
- GPU with 8 GB VRAM (recommended; works without GPU but slower)
- ~25 GB of disk space
- VS Code installed
- Internet connection only for the initial installation

**Installation:**
```bash
# One command, ~30 minutes (model download)
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

**Recommended configuration:** Full Local (default) — no additional configuration.

**Cost:** $0. No subscriptions, no usage limits, no surprises.

**Main use cases:**
- Personal projects with proprietary code
- Freelancing with clients under NDAs
- Learning and experimentation with no token limits

---

### 1.2 Small team (2–10 people)

**Profile:** Startup, development agency, or internal team at a midsize company.

**Requirements per machine:**
- Same requirements as the individual developer
- Each developer installs Trinit on their own machine (no shared server)

**Team installation:**
```bash
# Automatable onboarding script (non-interactive mode)
TRINIT_YES=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

**Recommended configuration:**
1. Install the "Trinit Core Team" from the marketplace on all machines
2. Create a shared `.roomodes` in the project repository with project-specific modes
3. Document how to install Trinit in the project README

**Advantages of the distributed model (each dev has their own instance):**
- No single point of failure
- No internal network latency
- No shared infrastructure costs
- Each developer can customize their configuration without affecting others

**Cost:** $0 per person. The only cost is hardware (which they already have).

---

### 1.3 Enterprise (compliance/privacy)

**Profile:** Company in a regulated sector (healthcare, banking, legal, defense, government) where code or data cannot leave the internal infrastructure.

**Requirements:**
- IT policy that allows installing Ollama and VS Code
- Internet access for the initial installation (or an internal mirror of the models)
- Development machines with 16–32 GB RAM

**Recommended deployment model:**

**Option A: Distributed installation (recommended)**
Each developer installs Trinit on their machine. The IT department can automate installation with endpoint management tools (Ansible, Puppet, SCCM):

```yaml
# Ansible example
- name: Install Trinit
  shell: |
    TRINIT_YES=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
  become: yes
```

**Option B: Shared Ollama server (advanced)**
For large teams, a centralized Ollama server with a powerful GPU can serve multiple developers. Each developer configures `ollamaBaseUrl` in Trinit to point to the internal server:

```
http://ollama-server.internal:11434
```

This requires:
- A server with a high-end GPU (NVIDIA A100, RTX 4090, etc.)
- A low-latency internal network
- Ollama server management

**Compliance arguments:**
- **GDPR/HIPAA:** Data never leaves the internal infrastructure — verifiable with network monitoring
- **SOC 2:** No dependency on external services for core functionality
- **ISO 27001:** Full control over data processing
- **Audit:** Trinit's source code is open-source and auditable

**Cost:** Hardware only. No software licenses, no per-user costs, no contracts with AI vendors.

---

### 1.4 Classroom / Education

**Profile:** Bootcamp, university, programming course, or development workshop.

**Requirements:**
- Student computers with 16 GB RAM (or a lab with suitable machines)
- Internet connection for the initial installation

**Deployment model:**

**For labs with shared machines:**
```bash
# Install once per machine
TRINIT_YES=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

**For students with their own laptops:**
Provide the one-liner in the course materials. Installation takes ~30 minutes and requires no instructor intervention.

**Advantages for education:**
- **No accounts:** Students don't need to create accounts on any service
- **No limits:** No token or usage limits — students can experiment freely
- **No cost:** Free for all students
- **Privacy:** Exercise code never leaves the student's machine
- **Reproducible:** All students have exactly the same environment

**Educational use cases:**
- Assistance with programming exercises without giving the answers directly (Ask mode)
- Guided debugging of student code (Debug mode)
- Code review with explanations (Ask mode)
- Final projects with AI assistance

---

## 2. Suggested roadmap

### v0.1.x — Stabilization (current)
- [x] Functional VS Code extension with 6 modes
- [x] One-liner installer for Windows, macOS, and Linux
- [x] 4 preconfigured models
- [x] Teams marketplace with Trinit Core Team
- [x] 5 predefined MCPs
- [x] Complete technical documentation (`dev/docs/`)
- [ ] E2E tests updated with Trinit branding

### v0.2.x — Public marketplace
- [ ] Community Teams catalog (beyond the Core Team)
- [ ] Team contribution system (PRs to `teams.yml`)
- [ ] Specialized teams: Frontend Team, Data Science Team, DevOps Team
- [ ] More models in `models.yaml` (Qwen, Llama, Mistral, etc.)

### v0.3.x — Team experience
- [ ] Shared Trinit configuration via `.trinit/` in the repository
- [ ] Versioned teams (teams with specific model versions)
- [ ] Support for shared Ollama server with authentication
- [ ] Improved CLI with team management commands

### v1.0.x — Enterprise
- [ ] Support for private models (fine-tuned on company data)
- [ ] Integration with internal identity management systems
- [ ] Usage dashboard (local, no external telemetry)
- [ ] Support for air-gapped environments (installation without internet)

---

## 3. Scenario comparison

| Scenario | # users | Hardware per machine | Monthly cost | Privacy | Setup complexity |
|---|---|---|---|---|---|
| Individual dev | 1 | 16 GB RAM, 8 GB GPU | $0 | Total | Very low (1 command) |
| Small team | 2–10 | 16 GB RAM, 8 GB GPU | $0 | Total | Low (1 command per machine) |
| Enterprise (distributed) | 10–100 | 16–32 GB RAM, GPU | $0 | Total | Medium (automatable) |
| Enterprise (shared server) | 10–100 | Powerful GPU server | $0 (+ hardware) | Total | High (server management) |
| Classroom | 10–30 | 16 GB RAM | $0 | Total | Low (1 command per machine) |

---

## 4. Scalability considerations

### Distributed model (recommended for most cases)

Each developer has their own Ollama instance. Advantages:
- Scales linearly — adding a developer = adding a machine
- No resource contention
- No single point of failure
- No network latency

### Centralized model (for large teams with powerful GPUs)

A single Ollama server serves multiple clients. Considerations:
- The server's GPU must handle multiple concurrent requests
- Ollama supports multiple requests but processes them sequentially by default
- For high concurrency, consider multiple Ollama instances with a load balancer
- Internal network latency must be low (<10ms) for a good experience

### Capacity estimate (shared server)

| Server GPU | Estimated concurrent users | Tokens/second per user |
|---|---|---|
| RTX 4090 (24 GB VRAM) | 2–4 | 15–30 |
| A100 (80 GB VRAM) | 8–16 | 20–40 |
| 2x A100 | 16–32 | 20–40 |

> **Note:** These are approximate estimates. Actual concurrency depends on context size and the model used.
