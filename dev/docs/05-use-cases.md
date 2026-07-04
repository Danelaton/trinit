# Trinit — Casos de Uso

> Versión: v0.1.0 · Fecha: 2026-07-04  
> Estos casos de uso están diseñados para ser narrables en videos, demos y presentaciones.

---

## Caso 1: Desarrolla una feature completa sin internet

**Escenario:** Un desarrollador backend trabaja en una API REST con datos de clientes. La empresa tiene política de no enviar código a servicios externos. Necesita implementar un nuevo endpoint de autenticación con JWT.

**Actores:** Modo Architect → Modo Code → Modo Debug

**Pasos:**

1. **Planificación (Architect):** El desarrollador abre Trinit en modo Architect y describe la feature: "Necesito un endpoint `/auth/refresh` que valide un refresh token y devuelva un nuevo access token JWT."

2. **Architect responde:** Recopila contexto leyendo los archivos existentes de autenticación, hace preguntas clarificadoras sobre la duración de los tokens y el almacenamiento, y crea una lista de tareas estructurada:
   - Crear `RefreshTokenService`
   - Añadir endpoint `POST /auth/refresh`
   - Escribir tests unitarios
   - Actualizar documentación OpenAPI

3. **Implementación (Code):** El desarrollador cambia a modo Code. Trinit implementa cada tarea de la lista, leyendo el código existente para mantener consistencia de estilo, escribiendo los archivos necesarios y ejecutando los tests.

4. **Debugging (Debug):** Un test falla. El desarrollador cambia a modo Debug. Trinit analiza el stack trace, identifica que el problema es una condición de carrera en el manejo de tokens expirados, añade logs para confirmar, y propone el fix antes de aplicarlo.

**Beneficio clave:** Todo el código de la empresa — incluyendo la lógica de autenticación, los tokens y la estructura de la base de datos — nunca sale de la máquina. El desarrollador tiene asistencia de IA de nivel profesional sin comprometer la seguridad.

**Modelos usados:** `ornith:9b` en todos los pasos

---

## Caso 2: Digitaliza documentos con OCR local

**Escenario:** Un despacho de abogados tiene 200 contratos escaneados en PDF que necesita indexar. Los documentos contienen información confidencial de clientes. Necesitan extraer las cláusulas clave y estructurarlas en JSON.

**Actores:** Modo OCR → Modo Code

**Pasos:**

1. **Extracción (OCR):** El desarrollador abre Trinit en modo OCR y adjunta una imagen del contrato escaneado. Pide: "Extrae todas las cláusulas de este contrato y estructúralas en JSON con campos: número_cláusula, título, contenido, partes_involucradas."

2. **OCR responde:** `glm-ocr:latest` procesa la imagen, reconoce el texto incluyendo tablas y firmas, y devuelve un JSON estructurado con todas las cláusulas identificadas.

3. **Automatización (Code):** El desarrollador cambia a modo Code y pide: "Crea un script Python que procese todos los PDFs de la carpeta `/contratos` usando este formato de salida."

4. **Resultado:** Un script que procesa los 200 contratos localmente, generando un archivo JSON por contrato, sin que ningún documento salga de la red interna.

**Beneficio clave:** Datos de clientes confidenciales procesados con IA sin ningún riesgo de exposición. El modelo OCR corre completamente en local — ni las imágenes ni el texto extraído pasan por ningún servidor externo.

**Modelos usados:** `glm-ocr:latest` (OCR), `ornith:9b` (Code)

---

## Caso 3: Debugging privado de código propietario

**Escenario:** Un equipo de fintech tiene un bug crítico en producción: el cálculo de intereses compuestos da resultados incorrectos en ciertos casos edge. El código es propietario y no puede compartirse con ningún servicio externo.

**Actores:** Modo Debug

**Pasos:**

1. **Diagnóstico inicial:** El desarrollador abre el modo Debug y pega el stack trace del error junto con el código del módulo de cálculo financiero.

2. **Análisis sistemático:** Trinit reflexiona sobre 5-7 posibles causas (precisión de punto flotante, desbordamiento de enteros, error en la fórmula, problema de redondeo, etc.), las reduce a las 2 más probables, y propone añadir logs específicos para confirmar.

3. **Confirmación:** El desarrollador ejecuta el código con los logs añadidos y comparte el output. Trinit confirma que el problema es precisión de punto flotante en la acumulación de intereses diarios.

4. **Fix propuesto:** Trinit propone usar `Decimal` en lugar de `float` para los cálculos financieros, muestra el código modificado, y **espera confirmación del desarrollador antes de aplicar el cambio** (comportamiento explícito del modo Debug).

5. **Verificación:** El desarrollador aprueba, Trinit aplica el fix y sugiere casos de test adicionales para los edge cases identificados.

**Beneficio clave:** Algoritmos financieros propietarios analizados con IA sin salir de la máquina. El modo Debug está diseñado para ser conservador — siempre pide confirmación antes de modificar código, lo que es crítico en sistemas financieros.

**Modelos usados:** `ornith:9b`

---

## Caso 4: Onboarding de un equipo con datos sensibles (salud/banca/legal)

**Escenario:** Un hospital quiere adoptar IA para asistir a su equipo de desarrollo de software interno. El código maneja datos de pacientes (HIPAA/GDPR). El departamento de IT rechaza cualquier solución que envíe datos a la nube.

**Actores:** Administrador IT + Equipo de desarrollo

**Pasos:**

1. **Instalación centralizada:** El administrador IT ejecuta el one-liner en cada máquina de desarrollo:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
   ```
   En modo no-interactivo, la instalación es completamente automatizable.

2. **Verificación de privacidad:** El administrador puede verificar con un sniffer de red que ninguna petición sale de `localhost:11434` durante el uso normal de Trinit. No hay telemetría, no hay llamadas a APIs externas, no hay autenticación con servidores remotos.

3. **Configuración del equipo:** El administrador instala el "Trinit Core Team" desde el marketplace para todos los desarrolladores. Todos tienen los mismos 6 modos con los mismos modelos — entorno reproducible.

4. **Uso diario:** Los desarrolladores usan Trinit para:
   - Revisar código que maneja datos de pacientes (modo Ask — solo lectura)
   - Implementar nuevas features del sistema de historiales (modo Code)
   - Debuggear problemas en el módulo de facturación (modo Debug)
   - Planificar migraciones de base de datos (modo Architect)

5. **Cumplimiento normativo:** El equipo de compliance puede documentar que "el asistente de IA opera exclusivamente en infraestructura interna, sin transmisión de datos a terceros" — una afirmación verificable técnicamente.

**Beneficio clave:** Adopción de IA en un entorno regulado sin comprometer el cumplimiento normativo. Trinit es la única solución de asistencia de IA que puede hacer esta afirmación de forma verificable.

**Modelos usados:** Todos los modelos del conjunto

---

## Caso 5: Desarrollo offline en zona sin conectividad

**Escenario:** Un consultor trabaja en un proyecto para una empresa minera en una ubicación remota con conectividad intermitente. Necesita asistencia de IA para desarrollar software de control de equipos.

**Actores:** Modo Architect → Modo Code

**Pasos:**

1. **Instalación previa:** Antes de viajar, el consultor instala Trinit con todos los modelos en su laptop. Una vez instalado, no necesita internet para nada.

2. **Trabajo offline:** En la ubicación remota, sin conexión a internet, el consultor usa Trinit normalmente:
   - Architect para planificar la arquitectura del sistema de control
   - Code para implementar los módulos
   - Debug para resolver problemas

3. **Sin interrupciones:** No hay mensajes de "sin conexión", no hay degradación de funcionalidad, no hay límites de uso. Trinit funciona exactamente igual con o sin internet.

**Beneficio clave:** Productividad de IA garantizada independientemente de la conectividad. Una vez instalado, Trinit es completamente autónomo.

**Modelos usados:** `ornith:9b` (Architect, Code), `gemma4:e2b` (Ask)

---

## Caso 6: Análisis de código legacy con contexto largo

**Escenario:** Un equipo hereda una base de código de 15 años con poca documentación. Necesitan entender la arquitectura antes de refactorizar.

**Actores:** Modo Ask → Modo Architect

**Pasos:**

1. **Exploración (Ask):** El desarrollador usa el modo Ask para hacer preguntas sobre el código existente. `gemma4:e2b` puede leer múltiples archivos simultáneamente gracias a la ventana de contexto de 128K tokens.

2. **Documentación (Architect):** Una vez entendida la arquitectura, el desarrollador cambia a Architect. `ornith:9b` con su ventana de 256K tokens puede mantener el contexto de toda la base de código mientras crea el plan de refactorización.

3. **Resultado:** Un plan detallado de refactorización con diagramas Mermaid de la arquitectura actual y propuesta, lista de tareas priorizada, y estimación de riesgos.

**Beneficio clave:** La ventana de contexto de 256K tokens de `ornith:9b` permite analizar proyectos grandes sin perder contexto — algo que los modelos de menor contexto no pueden hacer.

**Modelos usados:** `gemma4:e2b` (Ask), `ornith:9b` (Architect)

---

## Caso 7: Orquestación de tareas complejas multi-modo

**Escenario:** Un desarrollador necesita migrar una aplicación monolítica a microservicios. La tarea involucra análisis de código, diseño de arquitectura, implementación de múltiples servicios, y actualización de documentación.

**Actores:** Modo Orchestrator → Architect → Code → Code → Code

**Pasos:**

1. **Orquestación:** El desarrollador describe la tarea completa al modo Orchestrator. Trinit la descompone en subtareas y las delega:
   - Subtarea 1 → Architect: "Analiza el monolito y diseña la arquitectura de microservicios"
   - Subtarea 2 → Code: "Implementa el servicio de usuarios"
   - Subtarea 3 → Code: "Implementa el servicio de pedidos"
   - Subtarea 4 → Code: "Implementa el API Gateway"

2. **Ejecución paralela conceptual:** Cada subtarea se ejecuta en su propio contexto con el modo apropiado. El Orchestrator recibe los resultados y coordina el siguiente paso.

3. **Síntesis:** Al completar todas las subtareas, el Orchestrator proporciona un resumen de lo que se implementó y los próximos pasos.

**Beneficio clave:** Tareas que normalmente requerirían días de trabajo manual se organizan y ejecutan de forma estructurada. El Orchestrator actúa como un tech lead virtual que coordina el trabajo.

**Modelos usados:** `ornith:9b` en todos los modos
