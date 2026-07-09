# Trinit — Use Cases

> Version: v0.1.0 · Date: 2026-07-04  
> These use cases are designed to be narratable in videos, demos, and presentations.

---

## Case 1: Develop a complete feature without internet

**Scenario:** A backend developer works on a REST API with customer data. The company has a policy of not sending code to external services. They need to implement a new JWT authentication endpoint.

**Actors:** Architect mode → Code mode → Debug mode

**Steps:**

1. **Planning (Architect):** The developer opens Trinit in Architect mode and describes the feature: "I need an `/auth/refresh` endpoint that validates a refresh token and returns a new JWT access token."

2. **Architect responds:** It gathers context by reading the existing authentication files, asks clarifying questions about token lifetimes and storage, and creates a structured task list:
   - Create `RefreshTokenService`
   - Add `POST /auth/refresh` endpoint
   - Write unit tests
   - Update OpenAPI documentation

3. **Implementation (Code):** The developer switches to Code mode. Trinit implements each task on the list, reading existing code to maintain style consistency, writing the necessary files, and running the tests.

4. **Debugging (Debug):** A test fails. The developer switches to Debug mode. Trinit analyzes the stack trace, identifies that the problem is a race condition in handling expired tokens, adds logs to confirm, and proposes the fix before applying it.

**Key benefit:** All of the company's code — including authentication logic, tokens, and database structure — never leaves the machine. The developer gets professional-grade AI assistance without compromising security.

**Models used:** `ornith:9b` in all steps

---

## Case 2: Digitize documents with local OCR

**Scenario:** A law firm has 200 contracts scanned as PDFs that it needs to index. The documents contain confidential client information. They need to extract the key clauses and structure them as JSON.

**Actors:** OCR mode → Code mode

**Steps:**

1. **Extraction (OCR):** The developer opens Trinit in OCR mode and attaches an image of the scanned contract. They ask: "Extract all clauses from this contract and structure them as JSON with fields: clause_number, title, content, parties_involved."

2. **OCR responds:** `glm-ocr:latest` processes the image, recognizes the text including tables and signatures, and returns a structured JSON with all identified clauses.

3. **Automation (Code):** The developer switches to Code mode and asks: "Create a Python script that processes all PDFs in the `/contracts` folder using this output format."

4. **Result:** A script that processes the 200 contracts locally, generating one JSON file per contract, without any document leaving the internal network.

**Key benefit:** Confidential client data processed with AI without any risk of exposure. The OCR model runs entirely locally — neither the images nor the extracted text pass through any external server.

**Models used:** `glm-ocr:latest` (OCR), `ornith:9b` (Code)

---

## Case 3: Private debugging of proprietary code

**Scenario:** A fintech team has a critical bug in production: the compound interest calculation gives incorrect results in certain edge cases. The code is proprietary and cannot be shared with any external service.

**Actors:** Debug mode

**Steps:**

1. **Initial diagnosis:** The developer opens Debug mode and pastes the error's stack trace along with the financial calculation module's code.

2. **Systematic analysis:** Trinit reflects on 5–7 possible causes (floating-point precision, integer overflow, a formula error, a rounding issue, etc.), narrows them down to the 2 most likely, and proposes adding specific logs to confirm.

3. **Confirmation:** The developer runs the code with the added logs and shares the output. Trinit confirms the problem is floating-point precision in the daily interest accumulation.

4. **Proposed fix:** Trinit proposes using `Decimal` instead of `float` for financial calculations, shows the modified code, and **waits for the developer's confirmation before applying the change** (explicit behavior of Debug mode).

5. **Verification:** The developer approves, Trinit applies the fix and suggests additional test cases for the identified edge cases.

**Key benefit:** Proprietary financial algorithms analyzed with AI without leaving the machine. Debug mode is designed to be conservative — it always asks for confirmation before modifying code, which is critical in financial systems.

**Models used:** `ornith:9b`

---

## Case 4: Onboarding a team with sensitive data (healthcare/banking/legal)

**Scenario:** A hospital wants to adopt AI to assist its internal software development team. The code handles patient data (HIPAA/GDPR). The IT department rejects any solution that sends data to the cloud.

**Actors:** IT administrator + Development team

**Steps:**

1. **Centralized installation:** The IT administrator runs the one-liner on each development machine:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
   ```
   In non-interactive mode, installation is fully automatable.

2. **Privacy verification:** The administrator can verify with a network sniffer that no request leaves `localhost:11434` during normal Trinit usage. There is no telemetry, no calls to external APIs, no authentication with remote servers.

3. **Team configuration:** The administrator installs the "Trinit Core Team" from the marketplace for all developers. Everyone has the same 6 modes with the same models — a reproducible environment.

4. **Daily use:** Developers use Trinit to:
   - Review code that handles patient data (Ask mode — read-only)
   - Implement new features in the medical records system (Code mode)
   - Debug problems in the billing module (Debug mode)
   - Plan database migrations (Architect mode)

5. **Regulatory compliance:** The compliance team can document that "the AI assistant operates exclusively on internal infrastructure, with no data transmission to third parties" — a technically verifiable claim.

**Key benefit:** AI adoption in a regulated environment without compromising regulatory compliance. Trinit is the only AI assistance solution that can make this claim in a verifiable way.

**Models used:** All models in the set

---

## Case 5: Offline development in an area without connectivity

**Scenario:** A consultant works on a project for a mining company in a remote location with intermittent connectivity. They need AI assistance to develop equipment control software.

**Actors:** Architect mode → Code mode

**Steps:**

1. **Pre-installation:** Before traveling, the consultant installs Trinit with all models on their laptop. Once installed, they need no internet at all.

2. **Offline work:** At the remote location, with no internet connection, the consultant uses Trinit normally:
   - Architect to plan the control system architecture
   - Code to implement the modules
   - Debug to resolve issues

3. **No interruptions:** No "offline" messages, no feature degradation, no usage limits. Trinit works exactly the same with or without internet.

**Key benefit:** AI productivity guaranteed regardless of connectivity. Once installed, Trinit is fully autonomous.

**Models used:** `ornith:9b` (Architect, Code), `gemma4:e2b` (Ask)

---

## Case 6: Legacy code analysis with long context

**Scenario:** A team inherits a 15-year-old codebase with little documentation. They need to understand the architecture before refactoring.

**Actors:** Ask mode → Architect mode

**Steps:**

1. **Exploration (Ask):** The developer uses Ask mode to ask questions about the existing code. `gemma4:e2b` can read multiple files simultaneously thanks to the 128K-token context window.

2. **Documentation (Architect):** Once the architecture is understood, the developer switches to Architect. `ornith:9b` with its 256K-token window can maintain context of the entire codebase while creating the refactoring plan.

3. **Result:** A detailed refactoring plan with Mermaid diagrams of the current and proposed architecture, a prioritized task list, and risk assessment.

**Key benefit:** The 256K-token context window of `ornith:9b` allows analyzing large projects without losing context — something that models with smaller context cannot do.

**Models used:** `gemma4:e2b` (Ask), `ornith:9b` (Architect)

---

## Case 7: Orchestrating complex multi-mode tasks

**Scenario:** A developer needs to migrate a monolithic application to microservices. The task involves code analysis, architecture design, implementing multiple services, and updating documentation.

**Actors:** Orchestrator mode → Architect → Code → Code → Code

**Steps:**

1. **Orchestration:** The developer describes the complete task to Orchestrator mode. Trinit decomposes it into subtasks and delegates them:
   - Subtask 1 → Architect: "Analyze the monolith and design the microservices architecture"
   - Subtask 2 → Code: "Implement the users service"
   - Subtask 3 → Code: "Implement the orders service"
   - Subtask 4 → Code: "Implement the API Gateway"

2. **Conceptual parallel execution:** Each subtask runs in its own context with the appropriate mode. The Orchestrator receives the results and coordinates the next step.

3. **Synthesis:** On completing all subtasks, the Orchestrator provides a summary of what was implemented and the next steps.

**Key benefit:** Tasks that would normally require days of manual work are organized and executed in a structured way. The Orchestrator acts as a virtual tech lead coordinating the work.

**Models used:** `ornith:9b` in all modes
