-- AlterTable
ALTER TABLE "areas" ALTER COLUMN "centroid" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326);

-- AlterTable
ALTER TABLE "branches" ALTER COLUMN "location" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326);

-- AlterTable
ALTER TABLE "listings" ALTER COLUMN "physical_location" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326),
ALTER COLUMN "display_location" SET DEFAULT ST_SetSRID(ST_MakePoint(31.2357, 30.0444), 4326);

-- AlterTable
ALTER TABLE "otps" ADD COLUMN     "purpose" VARCHAR(30) NOT NULL DEFAULT 'AUTH';

-- AlterTable
ALTER TABLE "user_sessions" ADD COLUMN     "family_id" UUID;

-- CreateIndex
CREATE INDEX "otps_phone_purpose_expires_at_is_consumed_idx" ON "otps"("phone", "purpose", "expires_at", "is_consumed");

-- CreateIndex
CREATE INDEX "user_sessions_family_id_idx" ON "user_sessions"("family_id");
