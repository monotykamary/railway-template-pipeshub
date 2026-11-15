# PipesHub 1.0 candidate

Back up every stateful service and the application volume. Keep MongoDB, Redis, Neo4j and Qdrant on their existing versions; experimental PostgreSQL migration tooling is not part of this update.

[Upstream 1.0 release notes](https://github.com/pipeshub-ai/pipeshub-ai/releases/tag/v1.0.0) remove SAML and generic OAuth sign-in. Operators using those methods must arrange a supported sign-in method before updating. Existing client-credentials applications must be bound to service accounts by an administrator. Review the new default retrieval features and MCP settings.

The existing Railway bootstrap marker must agree with the organization database; the adapter continues failing closed when either is missing. No existing secret or variable is reset by this candidate.

The attached product check exercises password authentication, rejected credentials, KB creation, upload, completed indexing, original record ID and original downloaded document bytes across upgrade/redeploy. Live provider-backed retrieval and real Railway edge behavior remain mandatory before publication.
