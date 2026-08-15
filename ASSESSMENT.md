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
| Qdrant | `v1.14.1` | `sha256:419d72603f5346ee22ffc4606bdb7beb52fcb63077766fab678e6622ba247366` | `linux/amd64`, `linux/arm64` |
| Neo4j | `5.26.0` | `sha256:5a015e53de1895e7eee1574ae0325cf8c4b89587222778108c594bdd45a474b5` | `linux/amd64`, `linux/arm64` |

The Git tag is immutable and the upstream repository is Apache-2.0. Redis `bookworm` was resolved to `8.4.0-bookworm`. Upstream declares Qdrant `v1.15`, but PipesHub bundles `qdrant-client==1.13.1`; live validation showed that client flagging a two-minor gap as incompatible. The wrapper therefore pins the latest stable `v1.14.1`, which stays within the client’s supported one-minor window.

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

## Live Railway evidence

A fresh deployment from the serialized template passed the release gate on 2026-08-15/16 UTC:

- all five services built from the public wrapper repository and reached `SUCCESS`
- the generated HTTPS route rendered the PipesHub sign-in page and loaded a static asset
- query, connector, indexing, Docling, and embedding reported healthy
- the generated administrator completed password authentication and retrieved the bootstrapped organization
- MongoDB, Redis, Qdrant, Neo4j, and PipesHub all survived source redeploys; the exact organization ID and creation timestamp persisted
- seven health, page, and authenticated organization probes passed over a 125-second final soak
- final soak telemetry had zero HTTP errors, failed DNS lookups, or dropped network flows
- exact final deployment logs had no crash, OOM, panic, fatal, Qdrant version-mismatch, or deprecated Neo4j memory-setting signals
- Neo4j Community emitted expected startup errors for Enterprise-only property-existence constraints; PipesHub explicitly catches those unsupported constraints and continued healthy
- the canonical marketplace route rendered the exact `PipesHub` title, creator, source repository, five-service topology, `v0.6.0`, and Qdrant `1.14.1` markers
