-- AlterTable
ALTER TABLE "accounts" ADD COLUMN     "is_demo" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "areas" ALTER COLUMN "centroid" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326);

-- AlterTable
ALTER TABLE "branches" ALTER COLUMN "location" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326);

-- AlterTable
ALTER TABLE "listings" ADD COLUMN     "is_demo" BOOLEAN NOT NULL DEFAULT false,
ALTER COLUMN "physical_location" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326),
ALTER COLUMN "display_location" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326);

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "is_demo" BOOLEAN NOT NULL DEFAULT false;

-- CreateIndex
CREATE INDEX "accounts_is_demo_idx" ON "accounts"("is_demo");

-- CreateIndex
CREATE INDEX "listings_branch_id_idx" ON "listings"("branch_id");

-- CreateIndex
CREATE INDEX "listings_project_id_idx" ON "listings"("project_id");

-- CreateIndex
CREATE INDEX "listings_is_demo_idx" ON "listings"("is_demo");

-- CreateIndex
CREATE INDEX "users_is_demo_idx" ON "users"("is_demo");
