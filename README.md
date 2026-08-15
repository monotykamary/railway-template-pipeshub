# PipesHub on Railway

Deploy a pinned, persistent [PipesHub](https://github.com/pipeshub-ai/pipeshub-ai) AI context layer on Railway.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pipeshub)

## What this repository provides

- PipesHub `v0.6.0` using the immutable `0.6.0-slim` image digest
- MongoDB, Redis Streams, Qdrant, and Neo4j on Railway private networking
- generated database, API, encryption, and initial-admin secrets
- a one-time administrator bootstrap that completes before the public health gate
- persistent uploads and Hugging Face model cache on one application volume
- digest-pinned service roots so updates are deliberate and auditable

## Topology

| Service | Version | Exposure | Persistent path |
|---|---:|---|---|
| PipesHub | `0.6.0-slim` | Public HTTPS on port `3000` | `/data/pipeshub` |
| MongoDB | `8.0.17` | Private `27017` | `/data/db` |
| Redis | `8.4.0` | Private `6379` | `/data` |
| Qdrant | `1.14.1` | Private `6333`/`6334` | `/qdrant/storage` |
| Neo4j Community | `5.26.0` | Private `7687` | `/data` |

PipesHub runs its frontend, Node.js API, embedding, connector, query, Docling, and indexing processes in the upstream all-in-one container. Redis provides both the key-value store and message broker, avoiding Kafka, ZooKeeper, and etcd.

## Post-deploy setup

1. Supply `PIPESHUB_ADMIN_EMAIL` in Railway's deploy form.
2. Wait for `/api/v1/health/services` to report all application services healthy. The first boot downloads about 2.5 GB of embedding-model data and can take several minutes.
3. Open the generated HTTPS domain and sign in with `PIPESHUB_ADMIN_EMAIL` and the generated `PIPESHUB_ADMIN_PASSWORD` shown in the PipesHub service variables.
4. Configure an LLM provider in the PipesHub administration UI. SMTP is optional, but invitations and password-reset email require it.

The bootstrap marker and organization database are checked together on every restart. The adapter refuses to expose a deployment when one exists without the other.

## Important limitations

- **Safe code execution is unavailable.** Railway does not expose a Docker socket or privileged nested Docker. `SANDBOX_MODE=docker` is retained so code-execution requests fail rather than run untrusted code in the application container. Do not switch an internet-facing deployment to `local` mode.
- Neo4j Community logs one-time `ConstraintCreationFailed` messages when PipesHub probes Enterprise-only property-existence constraints. PipesHub `v0.6.0` catches these as optional and continues with supported unique constraints and indexes.
- PipesHub recommends at least **4 CPU cores, 15 GB RAM, and 20 GB free disk**. Use a Railway plan and service limits that can sustain this multi-database stack.
- The template is a single application replica. Railway volumes cannot be shared across replicas.
- Connectors that target private LAN-only systems need a separately secured public or tunneled route.
- The first boot requires outbound access to download the embedding model. The application volume retains that cache for later redeploys.

See [`ASSESSMENT.md`](ASSESSMENT.md) for the explicit Railway feasibility matrix.

## Updating

1. Select a stable PipesHub release and verify its Git tag and multi-architecture image.
2. Update the tag and registry digest in `app/Dockerfile`.
3. Resolve any moving upstream dependency aliases to exact versions and update their Dockerfiles.
4. Run `npm test`, `bash -n app/entrypoint.sh`, `sh -n redis/start.sh`, the icon check, local product validation, and a disposable live Railway validation.
5. Redeploy and verify health, login, persistence, migrations, logs, and both runtime soak windows before updating the marketplace template.

## Upstream and license

- Source: <https://github.com/pipeshub-ai/pipeshub-ai>
- Release: <https://github.com/pipeshub-ai/pipeshub-ai/releases/tag/v0.6.0>
- Documentation: <https://docs.pipeshub.com/>
- PipesHub license: Apache-2.0

Wrapper code and documentation are licensed under Apache-2.0. Referenced containerized dependencies retain their own upstream licenses; see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
