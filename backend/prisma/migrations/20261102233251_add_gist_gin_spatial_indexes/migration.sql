-- CreateIndex
CREATE INDEX "areas_centroid_idx" ON "areas" USING GIST ("centroid");

-- CreateIndex
CREATE INDEX "idx_branches_location" ON "branches" USING GIST ("location");

-- CreateIndex
CREATE INDEX "idx_listings_physical_loc" ON "listings" USING GIST ("physical_location");

-- CreateIndex
CREATE INDEX "idx_listings_display_loc" ON "listings" USING GIST ("display_location");

-- CreateIndex
CREATE INDEX "idx_listings_attributes_gin" ON "listings" USING GIN ("attributes");
