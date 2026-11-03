-- Enable PostGIS Extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- CreateTable
CREATE TABLE "governorates" (
    "id" SERIAL NOT NULL,
    "name_ar" VARCHAR(100) NOT NULL,
    "name_en" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "governorates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cities" (
    "id" SERIAL NOT NULL,
    "governorate_id" INTEGER NOT NULL,
    "name_ar" VARCHAR(150) NOT NULL,
    "name_en" VARCHAR(150) NOT NULL,
    "slug" VARCHAR(150) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "cities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "areas" (
    "id" UUID NOT NULL,
    "city_id" INTEGER NOT NULL,
    "name_ar" VARCHAR(150) NOT NULL,
    "name_en" VARCHAR(150) NOT NULL,
    "centroid" geometry(Point, 4326) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "areas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "email" VARCHAR(255),
    "password_hash" VARCHAR(255),
    "full_name" VARCHAR(120) NOT NULL,
    "avatar_url" VARCHAR(500),
    "is_phone_verified" BOOLEAN NOT NULL DEFAULT false,
    "is_email_verified" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "preferred_language" VARCHAR(5) NOT NULL DEFAULT 'ar',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_sessions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "refresh_token_hash" VARCHAR(255) NOT NULL,
    "device_fingerprint" VARCHAR(255),
    "user_agent" VARCHAR(500),
    "ip_address" VARCHAR(50) NOT NULL,
    "is_revoked" BOOLEAN NOT NULL DEFAULT false,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_used_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_devices" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "fcm_token" TEXT NOT NULL,
    "platform" VARCHAR(10) NOT NULL,
    "app_version" VARCHAR(30),
    "last_seen_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "otps" (
    "id" UUID NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "code_hash" VARCHAR(255) NOT NULL,
    "attempts" SMALLINT NOT NULL DEFAULT 0,
    "is_consumed" BOOLEAN NOT NULL DEFAULT false,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "otps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounts" (
    "id" UUID NOT NULL,
    "owner_user_id" UUID NOT NULL,
    "account_type" VARCHAR(20) NOT NULL,
    "display_name" VARCHAR(150) NOT NULL,
    "slug" VARCHAR(160) NOT NULL,
    "bio" TEXT,
    "logo_url" VARCHAR(500),
    "banner_url" VARCHAR(500),
    "verification_status" VARCHAR(20) NOT NULL DEFAULT 'pending',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account_members" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" VARCHAR(20) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "account_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account_verifications" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "document_type" VARCHAR(50) NOT NULL,
    "document_number" VARCHAR(100),
    "file_url" VARCHAR(500) NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending',
    "rejection_reason" TEXT,
    "reviewed_by_staff_id" UUID,
    "reviewed_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "account_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "area_id" UUID NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "address" TEXT NOT NULL,
    "location" geometry(Point, 4326) NOT NULL,
    "phone" VARCHAR(20),
    "working_hours" JSONB DEFAULT '{}',
    "is_main" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "service_areas" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "area_id" UUID NOT NULL,
    "radius_km" INTEGER NOT NULL DEFAULT 10,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "service_areas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "area_id" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "status" VARCHAR(30) NOT NULL,
    "delivery_date" DATE,
    "description" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categories" (
    "id" UUID NOT NULL,
    "parent_id" UUID,
    "name_ar" VARCHAR(150) NOT NULL,
    "name_en" VARCHAR(150) NOT NULL,
    "slug" VARCHAR(150) NOT NULL,
    "icon_url" VARCHAR(500),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category_fields" (
    "id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "field_key" VARCHAR(50) NOT NULL,
    "label_ar" VARCHAR(150) NOT NULL,
    "label_en" VARCHAR(150) NOT NULL,
    "field_type" VARCHAR(20) NOT NULL,
    "is_required" BOOLEAN NOT NULL DEFAULT false,
    "is_filterable" BOOLEAN NOT NULL DEFAULT true,
    "validation_rules" JSONB NOT NULL DEFAULT '{}',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "category_fields_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listings" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "area_id" UUID NOT NULL,
    "branch_id" UUID,
    "project_id" UUID,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT NOT NULL,
    "price" DECIMAL(14,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'EGP',
    "listing_kind" VARCHAR(20) NOT NULL,
    "contact_channel" VARCHAR(20) NOT NULL DEFAULT 'in_app',
    "moderation_status" VARCHAR(20) NOT NULL DEFAULT 'draft',
    "publication_status" VARCHAR(20) NOT NULL DEFAULT 'unpublished',
    "availability_status" VARCHAR(20) NOT NULL DEFAULT 'available',
    "physical_location" geometry(Point, 4326) NOT NULL,
    "display_location" geometry(Point, 4326) NOT NULL,
    "attributes" JSONB NOT NULL DEFAULT '{}',
    "views_count" INTEGER NOT NULL DEFAULT 0,
    "contact_reveals_count" INTEGER NOT NULL DEFAULT 0,
    "approved_at" TIMESTAMPTZ,
    "refreshed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "listings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_media" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "media_type" VARCHAR(10) NOT NULL,
    "storage_key" VARCHAR(500) NOT NULL,
    "public_url" VARCHAR(500) NOT NULL,
    "thumbnail_url" VARCHAR(500),
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "processing_status" VARCHAR(20) NOT NULL DEFAULT 'ready',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "listing_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "favorites" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favorites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reports" (
    "id" UUID NOT NULL,
    "reporter_user_id" UUID NOT NULL,
    "listing_id" UUID,
    "reported_account_id" UUID,
    "reason" VARCHAR(30) NOT NULL,
    "details" TEXT,
    "status" VARCHAR(20) NOT NULL DEFAULT 'open',
    "resolved_by_staff_id" UUID,
    "resolution_notes" TEXT,
    "resolved_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "buyer_user_id" UUID NOT NULL,
    "seller_account_id" UUID NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'open',
    "last_message_text" VARCHAR(500),
    "last_message_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" UUID NOT NULL,
    "conversation_id" UUID NOT NULL,
    "sender_user_id" UUID NOT NULL,
    "body" TEXT NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'sent',
    "sent_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "delivered_at" TIMESTAMPTZ,
    "read_at" TIMESTAMPTZ,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" VARCHAR(50) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "body" TEXT NOT NULL,
    "payload" JSONB DEFAULT '{}',
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "daily_quotas" (
    "id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "quota_type" VARCHAR(30) NOT NULL,
    "usage_date" DATE NOT NULL,
    "used_count" INTEGER NOT NULL DEFAULT 0,
    "limit_snapshot" INTEGER NOT NULL,

    CONSTRAINT "daily_quotas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_settings" (
    "key" VARCHAR(100) NOT NULL,
    "value" JSONB NOT NULL,
    "description" TEXT,
    "updated_by_staff_id" UUID,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "platform_settings_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "staff_roles" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "permissions" JSONB NOT NULL DEFAULT '[]',

    CONSTRAINT "staff_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_users" (
    "id" UUID NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "full_name" VARCHAR(120) NOT NULL,
    "role_id" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "staff_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "moderation_log" (
    "id" UUID NOT NULL,
    "staff_id" UUID,
    "target_type" VARCHAR(30) NOT NULL,
    "target_id" UUID NOT NULL,
    "action" VARCHAR(30) NOT NULL,
    "reason_code" VARCHAR(50),
    "notes" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "moderation_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_log" (
    "id" UUID NOT NULL,
    "actor_type" VARCHAR(20) NOT NULL,
    "actor_id" UUID,
    "action" VARCHAR(100) NOT NULL,
    "target_entity" VARCHAR(50) NOT NULL,
    "target_id" UUID,
    "ip_address" VARCHAR(50),
    "user_agent" VARCHAR(500),
    "diff_payload" JSONB,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_events" (
    "id" UUID NOT NULL,
    "aggregate_type" VARCHAR(50) NOT NULL,
    "aggregate_id" UUID NOT NULL,
    "event_type" VARCHAR(100) NOT NULL,
    "payload" JSONB NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    "error" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMPTZ,

    CONSTRAINT "outbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "governorates_slug_key" ON "governorates"("slug");

-- CreateIndex
CREATE INDEX "cities_governorate_id_idx" ON "cities"("governorate_id");

-- CreateIndex
CREATE UNIQUE INDEX "cities_governorate_id_slug_key" ON "cities"("governorate_id", "slug");

-- CreateIndex
CREATE INDEX "areas_city_id_idx" ON "areas"("city_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "user_sessions_user_id_is_revoked_idx" ON "user_sessions"("user_id", "is_revoked");

-- CreateIndex
CREATE INDEX "user_sessions_refresh_token_hash_idx" ON "user_sessions"("refresh_token_hash");

-- CreateIndex
CREATE UNIQUE INDEX "user_devices_user_id_fcm_token_key" ON "user_devices"("user_id", "fcm_token");

-- CreateIndex
CREATE INDEX "otps_phone_expires_at_is_consumed_idx" ON "otps"("phone", "expires_at", "is_consumed");

-- CreateIndex
CREATE UNIQUE INDEX "accounts_slug_key" ON "accounts"("slug");

-- CreateIndex
CREATE INDEX "accounts_owner_user_id_idx" ON "accounts"("owner_user_id");

-- CreateIndex
CREATE INDEX "accounts_verification_status_is_active_idx" ON "accounts"("verification_status", "is_active");

-- CreateIndex
CREATE INDEX "account_members_user_id_idx" ON "account_members"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "account_members_account_id_user_id_key" ON "account_members"("account_id", "user_id");

-- CreateIndex
CREATE INDEX "account_verifications_status_created_at_idx" ON "account_verifications"("status", "created_at");

-- CreateIndex
CREATE INDEX "branches_account_id_idx" ON "branches"("account_id");

-- CreateIndex
CREATE UNIQUE INDEX "service_areas_account_id_area_id_key" ON "service_areas"("account_id", "area_id");

-- CreateIndex
CREATE INDEX "projects_account_id_idx" ON "projects"("account_id");

-- CreateIndex
CREATE UNIQUE INDEX "categories_slug_key" ON "categories"("slug");

-- CreateIndex
CREATE INDEX "categories_parent_id_idx" ON "categories"("parent_id");

-- CreateIndex
CREATE UNIQUE INDEX "category_fields_category_id_field_key_key" ON "category_fields"("category_id", "field_key");

-- CreateIndex
CREATE INDEX "idx_listings_search" ON "listings"("moderation_status", "publication_status", "availability_status", "category_id", "refreshed_at" DESC);

-- CreateIndex
CREATE INDEX "listings_account_id_idx" ON "listings"("account_id");

-- CreateIndex
CREATE INDEX "listing_media_listing_id_sort_order_idx" ON "listing_media"("listing_id", "sort_order");

-- CreateIndex
CREATE INDEX "favorites_user_id_created_at_idx" ON "favorites"("user_id", "created_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "favorites_user_id_listing_id_key" ON "favorites"("user_id", "listing_id");

-- CreateIndex
CREATE INDEX "reports_status_created_at_idx" ON "reports"("status", "created_at");

-- CreateIndex
CREATE INDEX "conversations_buyer_user_id_last_message_at_idx" ON "conversations"("buyer_user_id", "last_message_at" DESC);

-- CreateIndex
CREATE INDEX "conversations_seller_account_id_last_message_at_idx" ON "conversations"("seller_account_id", "last_message_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "conversations_listing_id_buyer_user_id_key" ON "conversations"("listing_id", "buyer_user_id");

-- CreateIndex
CREATE INDEX "messages_conversation_id_sent_at_idx" ON "messages"("conversation_id", "sent_at");

-- CreateIndex
CREATE INDEX "notifications_user_id_is_read_created_at_idx" ON "notifications"("user_id", "is_read", "created_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "daily_quotas_account_id_quota_type_usage_date_key" ON "daily_quotas"("account_id", "quota_type", "usage_date");

-- CreateIndex
CREATE UNIQUE INDEX "staff_roles_name_key" ON "staff_roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "staff_users_email_key" ON "staff_users"("email");

-- CreateIndex
CREATE INDEX "moderation_log_target_type_target_id_created_at_idx" ON "moderation_log"("target_type", "target_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "moderation_log_staff_id_created_at_idx" ON "moderation_log"("staff_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "audit_log_target_entity_target_id_created_at_idx" ON "audit_log"("target_entity", "target_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "outbox_events_status_created_at_idx" ON "outbox_events"("status", "created_at");

-- AddForeignKey
ALTER TABLE "cities" ADD CONSTRAINT "cities_governorate_id_fkey" FOREIGN KEY ("governorate_id") REFERENCES "governorates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "areas" ADD CONSTRAINT "areas_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sessions" ADD CONSTRAINT "user_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_devices" ADD CONSTRAINT "user_devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts" ADD CONSTRAINT "accounts_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account_members" ADD CONSTRAINT "account_members_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account_members" ADD CONSTRAINT "account_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account_verifications" ADD CONSTRAINT "account_verifications_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account_verifications" ADD CONSTRAINT "account_verifications_reviewed_by_staff_id_fkey" FOREIGN KEY ("reviewed_by_staff_id") REFERENCES "staff_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service_areas" ADD CONSTRAINT "service_areas_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service_areas" ADD CONSTRAINT "service_areas_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "areas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "categories" ADD CONSTRAINT "categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_fields" ADD CONSTRAINT "category_fields_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_media" ADD CONSTRAINT "listing_media_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reporter_user_id_fkey" FOREIGN KEY ("reporter_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reported_account_id_fkey" FOREIGN KEY ("reported_account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_resolved_by_staff_id_fkey" FOREIGN KEY ("resolved_by_staff_id") REFERENCES "staff_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_buyer_user_id_fkey" FOREIGN KEY ("buyer_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_seller_account_id_fkey" FOREIGN KEY ("seller_account_id") REFERENCES "accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_user_id_fkey" FOREIGN KEY ("sender_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_quotas" ADD CONSTRAINT "daily_quotas_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_settings" ADD CONSTRAINT "platform_settings_updated_by_staff_id_fkey" FOREIGN KEY ("updated_by_staff_id") REFERENCES "staff_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_users" ADD CONSTRAINT "staff_users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "staff_roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "moderation_log" ADD CONSTRAINT "moderation_log_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- PostGIS Spatial GIST Indexes
CREATE INDEX "idx_areas_centroid" ON "areas" USING GIST ("centroid");
CREATE INDEX "idx_branches_location" ON "branches" USING GIST ("location");
CREATE INDEX "idx_listings_physical_loc" ON "listings" USING GIST ("physical_location");
CREATE INDEX "idx_listings_display_loc" ON "listings" USING GIST ("display_location");

-- Dynamic Attributes GIN Index
CREATE INDEX "idx_listings_attributes_gin" ON "listings" USING GIN ("attributes" jsonb_path_ops);

-- Domain Data Integrity Check Constraints
ALTER TABLE "listings" ADD CONSTRAINT "chk_listings_price" CHECK ("price" >= 0);
ALTER TABLE "accounts" ADD CONSTRAINT "chk_account_type" CHECK ("account_type" IN ('individual', 'company', 'factory', 'office', 'store'));
ALTER TABLE "accounts" ADD CONSTRAINT "chk_account_verification_status" CHECK ("verification_status" IN ('pending', 'approved', 'rejected'));
ALTER TABLE "account_members" ADD CONSTRAINT "chk_account_member_role" CHECK ("role" IN ('owner', 'manager', 'lister', 'responder'));
ALTER TABLE "listings" ADD CONSTRAINT "chk_listing_kind" CHECK ("listing_kind" IN ('sale', 'rent', 'buy', 'service', 'product'));
ALTER TABLE "listings" ADD CONSTRAINT "chk_contact_channel" CHECK ("contact_channel" IN ('in_app', 'external'));
ALTER TABLE "listings" ADD CONSTRAINT "chk_moderation_status" CHECK ("moderation_status" IN ('draft', 'pending', 'approved', 'rejected'));
ALTER TABLE "listings" ADD CONSTRAINT "chk_publication_status" CHECK ("publication_status" IN ('unpublished', 'published', 'hidden', 'archived', 'expired'));
ALTER TABLE "listings" ADD CONSTRAINT "chk_availability_status" CHECK ("availability_status" IN ('available', 'reserved', 'sold', 'rented', 'out_of_stock', 'discontinued'));
ALTER TABLE "listing_media" ADD CONSTRAINT "chk_media_type" CHECK ("media_type" IN ('image', 'video'));
ALTER TABLE "listing_media" ADD CONSTRAINT "chk_processing_status" CHECK ("processing_status" IN ('pending', 'ready', 'failed'));
ALTER TABLE "reports" ADD CONSTRAINT "chk_report_reason" CHECK ("reason" IN ('scam', 'inappropriate', 'false_info', 'duplicate', 'prohibited', 'other'));
ALTER TABLE "reports" ADD CONSTRAINT "chk_report_status" CHECK ("status" IN ('open', 'resolved', 'dismissed'));
ALTER TABLE "conversations" ADD CONSTRAINT "chk_conversation_status" CHECK ("status" IN ('open', 'closed', 'archived'));
ALTER TABLE "messages" ADD CONSTRAINT "chk_message_status" CHECK ("status" IN ('sent', 'delivered', 'read'));
ALTER TABLE "daily_quotas" ADD CONSTRAINT "chk_quota_type" CHECK ("quota_type" IN ('listings', 'messages', 'contact_reveal'));

