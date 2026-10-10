# ADR-004: Dynamic Category-Specific Attribute Storage Strategy

## Status
Approved

## Context
Market Space spans diverse categories with vastly divergent attributes:
- *Cars:* Make, Model, Year, Mileage, Transmission, Fuel Type.
- *Properties:* Property Type, Area (sqm), Bedrooms, Bathrooms, Finishing.
- *Mobile Phones:* Brand, Storage Capacity, RAM, Color, Warranty.
- *Fashion / Furniture:* Size, Material, Condition.

Storage architectural approaches:
1. **Fully Normalized Entity-Attribute-Value (EAV):** `listing_attribute_values` table joining attributes. High query overhead; complex multi-join queries when filtering across 5 attributes simultaneously.
2. **Dedicated Table Per Subcategory (e.g. `car_listings`, `property_listings`):** High schema rigidity; requires database migrations whenever a new category or field is introduced by an admin.
3. **Pure NoSQL / MongoDB:** Loses relational integrity, foreign key cascades, and ACID transactions for financial and user data.
4. **Hybrid Relational + PostgreSQL `JSONB` Column:** Normalized columns for core listing attributes (Title, Price, Location, Condition, Status); a `JSONB` column (`attributes`) stores subcategory-specific attributes validated against dynamic schemas in `category_fields`.

## Decision
We adopt the **Hybrid Relational + PostgreSQL `JSONB`** storage pattern.
- The `listings` table contains `attributes JSONB`.
- PostgreSQL GIN indexes (`jsonb_path_ops`) are applied to enable fast key-value containment queries (e.g., `attributes @> '{"year": 2021}'`).
- Validation is enforced at the application layer via metadata configured in `category_fields`.

## Consequences
- **Positive:**
  - Administrators can add new subcategories and custom dynamic attributes via the Next.js admin dashboard without running database migrations.
  - Efficient indexing and parametric filtering within PostgreSQL.
- **Negative:**
  - Schema integrity for dynamic attributes relies on backend validation pipes rather than PostgreSQL DDL constraints.
