# Trinit — Proyecciones de Despliegue

> Versión: v0.1.0 · Fecha: 2026-07-04

---

## 1. Escenarios de despliegue

### 1.1 Desarrollador individual

**Perfil:** Freelancer, desarrollador independiente, o empleado que quiere asistencia de IA sin comprometer la privacidad de su código.

**Requisitos:**
- Laptop o desktop con 16 GB RAM (mínimo), 32 GB recomendado
- GPU con 8 GB VRAM (recomendado; funciona sin GPU pero más lento)
- ~25 GB de espacio en disco
- VS Code instalado
- Conexión a internet solo para la instalación inicial

**Instalación:**
```bash
# Un comando, ~30 minutos (descarga de modelos)
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

**Configuración recomendada:** Full Local (por defecto) — sin configuración adicional.

**Costo:** $0. Sin suscripciones, sin límites de uso, sin sorpresas.

**Casos de uso principales:**
- Desarrollo de proyectos personales con código propietario
- Freelancing con clientes que tienen NDAs
- Aprendizaje y experimentación sin límites de tokens

---

### 1.2 Equipo pequeño (2-10 personas)

**Perfil:** Startup, agencia de desarrollo, o equipo interno de una empresa mediana.

**Requisitos por máquina:**
- Mismos requisitos que el desarrollador individual
- Cada desarrollador instala Trinit en su propia máquina (no hay servidor compartido)

**Instalación en equipo:**
```bash
# Script de onboarding automatizable (modo no-interactivo)
TRINIT_YES=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

**Configuración recomendada:**
1. Instalar el "Trinit Core Team" desde el marketplace en todos los equipos
2. Crear un `.roomodes` compartido en el repositorio del proyecto con modos específicos del proyecto
3. Documentar en el README del proyecto cómo instalar Trinit

**Ventajas del modelo distribuido (cada dev tiene su instancia):**
- Sin punto único de fallo
- Sin latencia de red interna
- Sin costos de infraestructura compartida
- Cada desarrollador puede personalizar su configuración sin afectar a otros

**Costo:** $0 por persona. El único costo es el hardware (que ya tienen).

---

### 1.3 Empresa (compliance/privacidad)

**Perfil:** Empresa en sector regulado (salud, banca, legal, defensa, gobierno) donde el código o los datos no pueden salir de la infraestructura interna.

**Requisitos:**
- Política de IT que permita instalar Ollama y VS Code
- Acceso a internet para la instalación inicial (o mirror interno de los modelos)
- Máquinas de desarrollo con 16-32 GB RAM

**Modelo de despliegue recomendado:**

**Opción A: Instalación distribuida (recomendada)**
Cada desarrollador instala Trinit en su máquina. El departamento de IT puede automatizar la instalación con herramientas de gestión de endpoints (Ansible, Puppet, SCCM):

```yaml
# Ejemplo Ansible
- name: Install Trinit
  shell: |
    TRINIT_YES=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
  become: yes
```

**Opción B: Servidor Ollama compartido (avanzado)**
Para equipos grandes, un servidor Ollama centralizado con GPU potente puede servir a múltiples desarrolladores. Cada desarrollador configura `ollamaBaseUrl` en Trinit para apuntar al servidor interno:

```
http://ollama-server.internal:11434
```

Esto requiere:
- Servidor con GPU de alta gama (NVIDIA A100, RTX 4090, etc.)
- Red interna de baja latencia
- Gestión del servidor Ollama

**Argumentos de compliance:**
- **GDPR/HIPAA:** Los datos nunca salen de la infraestructura interna — verificable con monitoreo de red
- **SOC 2:** Sin dependencia de servicios externos para la funcionalidad principal
- **ISO 27001:** Control total sobre el procesamiento de datos
- **Auditoría:** El código fuente de Trinit es open-source y auditable

**Costo:** Solo hardware. Sin licencias de software, sin costos por usuario, sin contratos con proveedores de IA.

---

### 1.4 Aula / Educación

**Perfil:** Bootcamp, universidad, curso de programación, o taller de desarrollo.

**Requisitos:**
- Computadoras de los estudiantes con 16 GB RAM (o laboratorio con máquinas adecuadas)
- Conexión a internet para la instalación inicial

**Modelo de despliegue:**

**Para laboratorios con máquinas compartidas:**
```bash
# Instalación una vez por máquina
TRINIT_YES=1 curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

**Para estudiantes con sus propias laptops:**
Proporcionar el one-liner en el material del curso. La instalación tarda ~30 minutos y no requiere intervención del instructor.

**Ventajas para educación:**
- **Sin cuentas:** Los estudiantes no necesitan crear cuentas en ningún servicio
- **Sin límites:** No hay límites de tokens ni de uso — los estudiantes pueden experimentar libremente
- **Sin costos:** Gratis para todos los estudiantes
- **Privacidad:** El código de los ejercicios no sale de la máquina del estudiante
- **Reproducible:** Todos los estudiantes tienen exactamente el mismo entorno

**Casos de uso educativos:**
- Asistencia en ejercicios de programación sin dar las respuestas directamente (modo Ask)
- Debugging guiado de código de estudiantes (modo Debug)
- Revisión de código con explicaciones (modo Ask)
- Proyectos finales con asistencia de IA

---

## 2. Roadmap sugerido

### v0.1.x — Estabilización (actual)
- [x] Extensión VS Code funcional con 6 modos
- [x] Instalador one-liner para Windows, macOS y Linux
- [x] 4 modelos preconfigurados
- [x] Teams marketplace con Trinit Core Team
- [x] 5 MCPs predefinidos
- [x] Documentación técnica completa (`dev/docs/`)
- [ ] Tests E2E actualizados con branding Trinit

### v0.2.x — Marketplace público
- [ ] Catálogo de Teams de la comunidad (más allá del Core Team)
- [ ] Sistema de contribución de Teams (PR a `teams.yml`)
- [ ] Teams especializados: Frontend Team, Data Science Team, DevOps Team
- [ ] Más modelos en `models.yaml` (Qwen, Llama, Mistral, etc.)

### v0.3.x — Experiencia de equipo
- [ ] Configuración de Trinit compartida via `.trinit/` en el repositorio
- [ ] Teams versionados (equipos con versiones específicas de modelos)
- [ ] Soporte para servidor Ollama compartido con autenticación
- [ ] CLI mejorado con comandos de gestión de equipo

### v1.0.x — Enterprise
- [ ] Soporte para modelos privados (fine-tuned en datos de la empresa)
- [ ] Integración con sistemas de gestión de identidad internos
- [ ] Dashboard de uso (local, sin telemetría externa)
- [ ] Soporte para air-gapped environments (instalación sin internet)

---

## 3. Comparativa de escenarios

| Escenario | Nº usuarios | Hardware por máquina | Costo mensual | Privacidad | Complejidad setup |
|---|---|---|---|---|---|
| Dev individual | 1 | 16 GB RAM, GPU 8 GB | $0 | Total | Muy baja (1 comando) |
| Equipo pequeño | 2-10 | 16 GB RAM, GPU 8 GB | $0 | Total | Baja (1 comando por máquina) |
| Empresa (distribuido) | 10-100 | 16-32 GB RAM, GPU | $0 | Total | Media (automatizable) |
| Empresa (servidor compartido) | 10-100 | Servidor GPU potente | $0 (+ hardware) | Total | Alta (gestión de servidor) |
| Aula | 10-30 | 16 GB RAM | $0 | Total | Baja (1 comando por máquina) |

---

## 4. Consideraciones de escalabilidad

### Modelo distribuido (recomendado para la mayoría)

Cada desarrollador tiene su propia instancia de Ollama. Ventajas:
- Escala linealmente — añadir un desarrollador = añadir una máquina
- Sin contención de recursos
- Sin punto único de fallo
- Sin latencia de red

### Modelo centralizado (para equipos grandes con GPU potente)

Un servidor Ollama sirve a múltiples clientes. Consideraciones:
- La GPU del servidor debe poder manejar múltiples peticiones concurrentes
- Ollama soporta múltiples peticiones pero las procesa secuencialmente por defecto
- Para alta concurrencia, considerar múltiples instancias de Ollama con un load balancer
- La latencia de red interna debe ser baja (<10ms) para buena experiencia

### Estimación de capacidad (servidor compartido)

| GPU del servidor | Usuarios concurrentes estimados | Tokens/segundo por usuario |
|---|---|---|
| RTX 4090 (24 GB VRAM) | 2-4 | 15-30 |
| A100 (80 GB VRAM) | 8-16 | 20-40 |
| 2x A100 | 16-32 | 20-40 |

> **Nota:** Estos son estimados aproximados. La concurrencia real depende del tamaño del contexto y el modelo usado.
