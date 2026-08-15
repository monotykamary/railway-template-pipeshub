# Railway Feasibility Assessment

## Decision

**`publish-with-documented-limit`** for PipesHub `v0.6.0` (`d77dca07974bf7abc7a91bfb4b575bb968ca53b6`, released 2026-08-10).

Core search, connector, retrieval, graph, indexing, authentication, and non-code agent functionality fit Railway. Docker-backed safe code execution does not: Railway provides neither `/var/run/docker.sock` nor privileged nested Docker. The template keeps production Docker sandbox mode without a daemon so that feature fails closed, and documents the omission prominently.

No existing PipesHub template was returned by `railway templates search pipeshub --json` during assessment.

## Platform matrix

| Area | PipesHub mapping | Decision |
|---|---|---|
| Public web | One HTTPS domain targets PipesHub port `3000` | Supported |
| Private networking | MongoDB `27017`, Redis `6379`, Qdrant `6333/6334`, and Neo4j Bolt `7687` use Railway private DNS | Live validation required before publication |
| Public TCP | No database is public | Supported |
| UDP | No required UDP path | Supported |
| Nested Docker | Upstream production code sandbox mounts the Docker socket | Code sandbox omitted; documented limit |
| Host devices | No required devices or GPU passthrough | Supported in CPU mode |
| Privileged/kernel control | Core services need neither privileged mode nor host sysctls | Supported |
| Volumes | One volume each for app, MongoDB, Redis, Qdrant, and Neo4j | Supported; no cross-service mount |
| LAN access | Some connectors may target private corporate systems | Requires an external secure route; documented |
| Shared memory | Compose requests 2 GB, but the official Helm deployment does not add a `/dev/shm` mount | Core stack passed locally with the container default 64 MiB |
| Resources | Upstream recommends 4 cores, 15 GB RAM, and 20 GB disk | Supported on an appropriately sized paid plan |

## Upstream and image evidence

| Component | Pin | Registry digest | Architectures |
|---|---|---|---|
| PipesHub | `0.6.0-slim` | `sha256:8bfc3fc47eee2968042338563f464d0853245a099c22731a5446f8b7e0325ad0` | `linux/amd64`, `linux/arm64` |
| MongoDB | `8.0.17` | `sha256:9814652e33f0cf8b9fddea8b46dfc9d8e19b130dcfdd7b510ca58bb0d40c8b71` | `linux/amd64`, `linux/arm64` |
| Redis | `8.4.0-bookworm` | `sha256:c22af04bb576503bf16b3e34a1fd2fd82de0f765afd866d2e380145e0af30d78` | `linux/amd64`, `linux/arm64` |
| Qdrant | `v1.15.5` | `sha256:0fb8897412abc81d1c0430a899b9a81eb8328aa634e7242d1bc804c1fe8fe863` | `linux/amd64`, `linux/arm64` |
| Neo4j | `5.26.0` | `sha256:5a015e53de1895e7eee1574ae0325cf8c4b89587222778108c594bdd45a474b5` | `linux/amd64`, `linux/arm64` |

The Git tag is immutable and the upstream repository is Apache-2.0. Redis `bookworm` was resolved to `8.4.0-bookworm`; Qdrant `v1.15` was resolved to `v1.15.5`; both exact tags matched the upstream alias digest at assessment time.

## Local evidence

A five-service ARM64 Compose deployment passed on Docker Engine `29.6.1` with 6 CPUs and 8.3 GB allocated memory:

- all aggregated services healthy: query, connector, indexing, Docling, and embedding
- homepage and a static asset loaded
- malformed organization creation returned `400`
- one initial administrator was created; a second organization was rejected
- password authentication succeeded before and after app recreation
- MongoDB organization state survived recreation
- one `/data/pipeshub` volume retained both the upload marker and 2.5 GB Hugging Face cache
- default `/dev/shm` was exactly 64 MiB
- two 121-second soak windows completed with repeated health and product probes
- exact soak-window logs for all five services had no matching fatal, panic, traceback, OOM, permission, DNS, connection-refused, exception, or error events
- test containers, volumes, and network were removed; test-owned images were recorded for release cleanup

Publication remains gated on the same checks in a disposable live Railway project, including private IPv6 DNS, live image builds, public rendering, exact-deployment logs, and redeploy persistence.
