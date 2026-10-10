# ADR-005: Search Architecture & Indexing Strategy

## Status
Approved

## Context
Marketplace search in Egypt must efficiently handle:
- Arabic language orthographic variations (e.g., `أ / إ / ا`, `ة / ه`, `ى / ي`).
- Mixed Arabic and English queries (e.g., "ايفون 13 برو", "iPhone 13 Pro").
- Typos and partial keyword matching.
- Simultaneous parametric filters (Governorate, City, Price Range, Dynamic Attributes).

Options:
1. **PostgreSQL Native `pg_trgm` (Trigram) GIN Indexes:** Built directly into PostgreSQL, zero extra infrastructure, supports fuzzy substring matching across Arabic and Latin text, performant up to 200,000–300,000 listings.
2. **Dedicated Search Cluster (Elasticsearch / OpenSearch):** High search power, but consumes 2–4 GB RAM minimum and requires continuous CDC (Change Data Capture) or two-phase write synchronization.
3. **Meilisearch / Typesense:** Lightweight typo-tolerant search engines, but still introduces a separate service and persistence layer on a single VPS.

## Decision
For MVP, we select **PostgreSQL with the `pg_trgm` extension and GIN indexes**.
- Arabic text normalization functions will clean common letter variations prior to search index evaluation.
- Queries combine trigram similarity (`title % 'query'`) with standard relational WHERE filters.
- A future migration to Meilisearch or Elasticsearch is planned for Phase 2 when active listings exceed 250,000.

## Consequences
- **Positive:**
  - Zero additional server components or RAM overhead on the initial VPS.
  - ACID consistency: listings become instantly searchable the moment their status is set to `PUBLISHED` without indexing latency.
- **Negative:**
  - Complex multi-word stemming and deep semantic search are limited compared to dedicated search clusters, but more than sufficient for classifieds title/description lookups.
