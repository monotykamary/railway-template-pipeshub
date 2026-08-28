# Deploy and Host PipesHub on Railway

## About Hosting PipesHub

PipesHub is an open-source AI context layer for enterprise search, retrieval, connectors, and agentic workflows. This template deploys the stable `v0.7.0` release with MongoDB, Redis Streams, Qdrant, and Neo4j. The `PipesHub` service owns the public HTTPS domain on port `3000`; all databases remain private.

On first deployment, enter `PIPESHUB_ADMIN_EMAIL`. The template generates the administrator password and all cross-service secrets. A bootstrap adapter creates the single initial organization before the public health gate succeeds. Sign in with the email you entered and the `PIPESHUB_ADMIN_PASSWORD` value shown on the PipesHub service.

## Common Use Cases

- Unified search and retrieval across workplace data
- Knowledge-base ingestion and semantic search
- Explainable, graph-backed AI answers
- Connector-driven indexing and scheduled synchronization
- No-code agents that do not require a local code-execution sandbox

## Dependencies for PipesHub Hosting

### Deployment Dependencies

- MongoDB `8.0.17` for application and identity data
- Redis `8.4.0` for key-value data and Redis Streams
- Qdrant `1.14.1` for vectors, kept within the bundled client’s supported version window
- Neo4j Community `5.26.0` with APOC for the knowledge graph
- One persistent volume per stateful service
- Outbound HTTPS on first boot for the embedding-model download
- A user-supplied LLM provider configured after deployment

### Implementation Details

The upstream all-in-one image serves the web application on port `3000`. Railway service references wire private hostnames and shared secrets; changing those references can break the stack. `HOME`, `HF_HOME`, and the application volume are rooted at `/data/pipeshub`, preserving both local uploads and the approximately 2.5 GB model cache. Daily backups are enabled for irreplaceable volumes.

Neo4j Community logs one-time `ConstraintCreationFailed` messages when PipesHub probes Enterprise-only property-existence constraints. PipesHub `v0.7.0` catches these as optional and continues with supported unique constraints and indexes.

Railway cannot provide the Docker socket required by PipesHub's production sandbox. The template intentionally leaves `SANDBOX_MODE=docker` without a daemon, so safe code-execution and artifact-generation tools are unavailable. Never use `SANDBOX_MODE=local` for an internet-facing deployment because it runs generated code inside the main service.

PipesHub recommends at least 4 CPU cores, 15 GB RAM, and 20 GB disk. This is not a free-tier stack. LAN-only connectors require a secure public or tunneled route, and SMTP-dependent features require post-deploy SMTP configuration.

### Why Deploy PipesHub on Railway?

Railway supplies managed HTTPS, private service DNS, generated secrets, isolated persistent volumes, logs, health checks, and repeatable service wiring. This template also pins every image by stable version and digest and protects the initial-admin handoff from a public first-user race.
