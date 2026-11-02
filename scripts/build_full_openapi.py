#!/usr/bin/env python3
"""
Generates and validates the complete OpenAPI 3.0.3 specification for Deal One (55 REST Endpoints).
"""
import yaml
import sys
from pathlib import Path

def generate_openapi_spec():
    spec = {
        "openapi": "3.0.3",
        "info": {
            "title": "Deal One API Specification (صفقة ون)",
            "version": "1.0.0",
            "description": (
                "Production-grade OpenAPI 3.0.3 specification for the Deal One Hybrid Multi-Category Platform in Egypt.\n"
                "Serving Real Estate, Automotive, Building Materials, Services, Fashion, and Home Appliances.\n"
                "Contains all 55 REST endpoints, uniform response envelopes, cursor pagination, and security models.\n"
            ),
            "contact": {
                "name": "Deal One Engineering Team",
                "email": "engineering@deal-one.eg",
                "url": "https://deal-one.eg"
            }
        },
        "servers": [
            {
                "url": "https://api.deal-one.eg/api/v1",
                "description": "Production API Gateway (Cloudflare WAF Protected)"
            },
            {
                "url": "https://staging-api.deal-one.eg/api/v1",
                "description": "Staging Environment"
            },
            {
                "url": "http://localhost:3000/api/v1",
                "description": "Local Docker / Fastify Development Server"
            }
        ],
        "security": [
            {"BearerAuth": []}
        ],
        "tags": [
            {"name": "Authentication", "description": "SMS OTP, JWT Access & Refresh Token Management"},
            {"name": "Users", "description": "User Profiles, FCM Device Tokens & Account Deletion"},
            {"name": "Accounts", "description": "Multi-Tenant Business Accounts, Verification & Team RBAC"},
            {"name": "Locations", "description": "Egypt Governorates, Cities, Granular Areas & Branches"},
            {"name": "Categories", "description": "Two-Level Taxonomy & Dynamic Attribute Definitions"},
            {"name": "Listings", "description": "3-Axis Listing Lifecycle Management"},
            {"name": "Search & Explore", "description": "Faceted & Spatial PostGIS Discovery"},
            {"name": "Media", "description": "Direct Cloudflare R2 Presigned Uploads & Processing"},
            {"name": "Chat", "description": "In-App Listing-Bound Conversations & Messages"},
            {"name": "Engagement", "description": "Favorites & Abuse/Fraud Reporting"},
            {"name": "Quotas & Notifications", "description": "Daily Usage Limits & In-App Alerts"},
            {"name": "Admin & Moderation", "description": "Control Center, Content Moderation & Auditing"}
        ],
        "paths": {},
        "components": {
            "securitySchemes": {
                "BearerAuth": {
                    "type": "http",
                    "scheme": "bearer",
                    "bearerFormat": "JWT",
                    "description": "JWT Access Token (15-min lifespan). Header: 'Authorization: Bearer <token>'"
                },
                "AccountContext": {
                    "type": "apiKey",
                    "in": "header",
                    "name": "X-Account-ID",
                    "description": "Active Seller Account UUID context for multi-tenant isolation"
                }
            },
            "parameters": {
                "AccountContextParam": {
                    "name": "X-Account-ID",
                    "in": "header",
                    "required": True,
                    "description": "Active Seller Account UUID",
                    "schema": {"type": "string", "format": "uuid"}
                },
                "CursorParam": {
                    "name": "cursor",
                    "in": "query",
                    "required": False,
                    "description": "Opaque cursor string for keyset pagination",
                    "schema": {"type": "string"}
                },
                "LimitParam": {
                    "name": "limit",
                    "in": "query",
                    "required": False,
                    "description": "Max number of items to return (1-50, default 20)",
                    "schema": {"type": "integer", "minimum": 1, "maximum": 50, "default": 20}
                }
            },
            "schemas": {
                "ApiResponseGeneric": {
                    "type": "object",
                    "required": ["success", "data"],
                    "properties": {
                        "success": {"type": "boolean", "example": True},
                        "data": {"type": "object"},
                        "meta": {
                            "type": "object",
                            "properties": {
                                "next_cursor": {"type": "string", "nullable": True, "example": "eyJpZCI6IjhmN2IzYzIwLi4uIn0="},
                                "total_count": {"type": "integer", "example": 42}
                            }
                        }
                    }
                },
                "ApiErrorResponse": {
                    "type": "object",
                    "required": ["success", "error"],
                    "properties": {
                        "success": {"type": "boolean", "example": False},
                        "error": {
                            "type": "object",
                            "required": ["code", "message", "trace_id"],
                            "properties": {
                                "code": {"type": "string", "example": "VALIDATION_FAILED"},
                                "message": {"type": "string", "example": "Invalid input parameters"},
                                "details": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "properties": {
                                            "field": {"type": "string", "example": "phone"},
                                            "issue": {"type": "string", "example": "Must be a valid Egyptian mobile number"}
                                        }
                                    }
                                },
                                "trace_id": {"type": "string", "format": "uuid", "example": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"}
                            }
                        }
                    }
                },
                "User": {
                    "type": "object",
                    "required": ["id", "phone", "full_name", "is_active", "created_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "phone": {"type": "string", "example": "+201012732095"},
                        "email": {"type": "string", "format": "email", "nullable": True},
                        "full_name": {"type": "string", "example": "إبراهيم الشيشتاوي"},
                        "avatar_url": {"type": "string", "format": "uri", "nullable": True},
                        "is_active": {"type": "boolean"},
                        "created_at": {"type": "string", "format": "date-time"}
                    }
                },
                "Account": {
                    "type": "object",
                    "required": ["id", "display_name", "slug", "account_type", "is_verified", "created_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "display_name": {"type": "string", "example": "شركة الشيشتاوي للمقاولات"},
                        "slug": {"type": "string", "example": "el-shishtawy-contracting"},
                        "account_type": {"type": "string", "enum": ["individual", "company", "factory", "store"]},
                        "is_verified": {"type": "boolean"},
                        "avatar_url": {"type": "string", "format": "uri", "nullable": True},
                        "bio": {"type": "string", "nullable": True},
                        "contact_phone": {"type": "string", "nullable": True, "example": "+201012732095"},
                        "whatsapp_number": {"type": "string", "nullable": True, "example": "+201012732095"},
                        "my_role": {"type": "string", "enum": ["owner", "manager", "lister", "responder"]},
                        "created_at": {"type": "string", "format": "date-time"}
                    }
                },
                "AccountMember": {
                    "type": "object",
                    "required": ["id", "user_id", "account_id", "role", "created_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "user_id": {"type": "string", "format": "uuid"},
                        "account_id": {"type": "string", "format": "uuid"},
                        "role": {"type": "string", "enum": ["owner", "manager", "lister", "responder"]},
                        "user": {"$ref": "#/components/schemas/User"},
                        "created_at": {"type": "string", "format": "date-time"}
                    }
                },
                "Governorate": {
                    "type": "object",
                    "required": ["id", "name_ar", "name_en", "slug"],
                    "properties": {
                        "id": {"type": "integer", "example": 1},
                        "name_ar": {"type": "string", "example": "القاهرة"},
                        "name_en": {"type": "string", "example": "Cairo"},
                        "slug": {"type": "string", "example": "cairo"},
                        "cities": {
                            "type": "array",
                            "items": {"$ref": "#/components/schemas/City"}
                        }
                    }
                },
                "City": {
                    "type": "object",
                    "required": ["id", "governorate_id", "name_ar", "name_en", "slug"],
                    "properties": {
                        "id": {"type": "integer", "example": 101},
                        "governorate_id": {"type": "integer", "example": 1},
                        "name_ar": {"type": "string", "example": "مدينة نصر"},
                        "name_en": {"type": "string", "example": "Nasr City"},
                        "slug": {"type": "string", "example": "nasr-city"}
                    }
                },
                "Area": {
                    "type": "object",
                    "required": ["id", "city_id", "name_ar", "name_en", "slug"],
                    "properties": {
                        "id": {"type": "integer", "example": 1001},
                        "city_id": {"type": "integer", "example": 101},
                        "name_ar": {"type": "string", "example": "الحي السابع"},
                        "name_en": {"type": "string", "example": "7th District"},
                        "slug": {"type": "string", "example": "7th-district"},
                        "centroid_lat": {"type": "number", "example": 30.0444},
                        "centroid_lng": {"type": "number", "example": 31.2357}
                    }
                },
                "Branch": {
                    "type": "object",
                    "required": ["id", "account_id", "name_ar", "name_en", "lat", "lng", "is_main"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "account_id": {"type": "string", "format": "uuid"},
                        "name_ar": {"type": "string", "example": "فرع التجمع الخامس"},
                        "name_en": {"type": "string", "example": "5th Settlement Branch"},
                        "address": {"type": "string", "example": "شارع التسعين الشمالي"},
                        "lat": {"type": "number", "example": 30.0131},
                        "lng": {"type": "number", "example": 31.4289},
                        "phone": {"type": "string", "nullable": True, "example": "+201012732095"},
                        "is_main": {"type": "boolean", "example": True}
                    }
                },
                "Category": {
                    "type": "object",
                    "required": ["id", "name_ar", "name_en", "slug"],
                    "properties": {
                        "id": {"type": "integer", "example": 1},
                        "name_ar": {"type": "string", "example": "عقارات"},
                        "name_en": {"type": "string", "example": "Real Estate"},
                        "slug": {"type": "string", "example": "real-estate"},
                        "icon_url": {"type": "string", "format": "uri", "nullable": True},
                        "parent_id": {"type": "integer", "nullable": True},
                        "children": {
                            "type": "array",
                            "items": {"$ref": "#/components/schemas/Category"}
                        }
                    }
                },
                "CategoryField": {
                    "type": "object",
                    "required": ["id", "category_id", "field_name", "field_type", "label_ar", "label_en", "is_required"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "category_id": {"type": "integer"},
                        "field_name": {"type": "string", "example": "bedrooms"},
                        "field_type": {"type": "string", "enum": ["text", "number", "select", "multiselect", "boolean", "date"]},
                        "label_ar": {"type": "string", "example": "عدد الغرف"},
                        "label_en": {"type": "string", "example": "Bedrooms"},
                        "is_required": {"type": "boolean"},
                        "options": {"type": "array", "items": {"type": "string"}},
                        "validation_rules": {"type": "object"}
                    }
                },
                "Listing": {
                    "type": "object",
                    "required": ["id", "account_id", "category_id", "title", "description", "price", "currency", "moderation_status", "publication_status", "availability_status"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "account_id": {"type": "string", "format": "uuid"},
                        "category_id": {"type": "integer"},
                        "title": {"type": "string", "example": "شقة للبيع 180م في التجمع الخامس تشطيب ألترا سوبر لوكس"},
                        "description": {"type": "string"},
                        "price": {"type": "number", "example": 3500000.0},
                        "currency": {"type": "string", "example": "EGP"},
                        "price_on_inquiry": {"type": "boolean", "example": False},
                        "display_lat": {"type": "number", "example": 30.0131},
                        "display_lng": {"type": "number", "example": 31.4289},
                        "area_id": {"type": "integer", "nullable": True},
                        "moderation_status": {"type": "string", "enum": ["pending", "approved", "rejected"]},
                        "publication_status": {"type": "string", "enum": ["draft", "published", "hidden", "expired", "deleted"]},
                        "availability_status": {"type": "string", "enum": ["available", "reserved", "sold"]},
                        "attributes": {"type": "object"},
                        "media": {
                            "type": "array",
                            "items": {"$ref": "#/components/schemas/ListingMedia"}
                        },
                        "account": {"$ref": "#/components/schemas/Account"},
                        "view_count": {"type": "integer", "example": 128},
                        "created_at": {"type": "string", "format": "date-time"},
                        "refreshed_at": {"type": "string", "format": "date-time"}
                    }
                },
                "ListingMedia": {
                    "type": "object",
                    "required": ["id", "media_type", "original_url", "sort_order"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "media_type": {"type": "string", "enum": ["image", "video"]},
                        "original_url": {"type": "string", "format": "uri"},
                        "thumbnail_url": {"type": "string", "format": "uri", "nullable": True},
                        "sort_order": {"type": "integer"}
                    }
                },
                "Conversation": {
                    "type": "object",
                    "required": ["id", "listing_id", "buyer_account_id", "seller_account_id", "updated_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "listing_id": {"type": "string", "format": "uuid"},
                        "buyer_account_id": {"type": "string", "format": "uuid"},
                        "seller_account_id": {"type": "string", "format": "uuid"},
                        "last_message": {"type": "string", "nullable": True},
                        "unread_count": {"type": "integer", "example": 2},
                        "listing": {"$ref": "#/components/schemas/Listing"},
                        "updated_at": {"type": "string", "format": "date-time"}
                    }
                },
                "ChatMessage": {
                    "type": "object",
                    "required": ["id", "conversation_id", "sender_account_id", "message_type", "content", "created_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "conversation_id": {"type": "string", "format": "uuid"},
                        "sender_account_id": {"type": "string", "format": "uuid"},
                        "message_type": {"type": "string", "enum": ["text", "image", "location"]},
                        "content": {"type": "string"},
                        "media_url": {"type": "string", "format": "uri", "nullable": True},
                        "is_read": {"type": "boolean"},
                        "created_at": {"type": "string", "format": "date-time"}
                    }
                },
                "DailyQuota": {
                    "type": "object",
                    "required": ["account_id", "date", "listings_submitted", "contact_reveals_used", "chats_initiated", "limits"],
                    "properties": {
                        "account_id": {"type": "string", "format": "uuid"},
                        "date": {"type": "string", "format": "date", "example": "2026-11-02"},
                        "listings_submitted": {"type": "integer", "example": 1},
                        "contact_reveals_used": {"type": "integer", "example": 5},
                        "chats_initiated": {"type": "integer", "example": 8},
                        "limits": {
                            "type": "object",
                            "properties": {
                                "max_listings": {"type": "integer", "example": 3},
                                "max_reveals": {"type": "integer", "example": 15},
                                "max_chats": {"type": "integer", "example": 20}
                            }
                        }
                    }
                },
                "Notification": {
                    "type": "object",
                    "required": ["id", "title", "body", "notification_type", "is_read", "created_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "title": {"type": "string", "example": "تم قبول إعلانك بنجاح"},
                        "body": {"type": "string", "example": "إعلانك 'شقة للبيع في التجمع' معروض للجمهور الآن."},
                        "notification_type": {"type": "string", "enum": ["moderation_approved", "moderation_rejected", "chat_message", "quota_warning", "system"]},
                        "entity_id": {"type": "string", "nullable": True},
                        "is_read": {"type": "boolean"},
                        "created_at": {"type": "string", "format": "date-time"}
                    }
                },
                "AuditLog": {
                    "type": "object",
                    "required": ["id", "staff_user_id", "action", "resource_type", "resource_id", "created_at"],
                    "properties": {
                        "id": {"type": "string", "format": "uuid"},
                        "staff_user_id": {"type": "string", "format": "uuid"},
                        "action": {"type": "string", "example": "APPROVE_LISTING"},
                        "resource_type": {"type": "string", "example": "listing"},
                        "resource_id": {"type": "string", "example": "lst-uuid-1"},
                        "diff": {"type": "object"},
                        "ip_address": {"type": "string", "example": "197.38.12.44"},
                        "created_at": {"type": "string", "format": "date-time"}
                    }
                }
            }
        }
    }

    # Helper function to generate standard path definition
    paths = spec["paths"]

    def add_endpoint(path, method, tag, summary, op_id, req_schema=None, res_schema=None, is_auth=True, account_ctx=False, params=None, responses=None):
        if path not in paths:
            paths[path] = {}
        
        endpoint_def = {
            "tags": [tag],
            "summary": summary,
            "operationId": op_id,
            "responses": {}
        }
        
        if not is_auth:
            endpoint_def["security"] = []
        elif account_ctx:
            endpoint_def["security"] = [{"BearerAuth": [], "AccountContext": []}]

        if params:
            endpoint_def["parameters"] = params

        if req_schema:
            endpoint_def["requestBody"] = {
                "required": True,
                "content": {
                    "application/json": {
                        "schema": req_schema
                    }
                }
            }

        # Setup standard responses
        if responses:
            endpoint_def["responses"] = responses
        else:
            success_status = "201" if method.lower() == "post" else "200"
            endpoint_def["responses"][success_status] = {
                "description": "Successful operation",
                "content": {
                    "application/json": {
                        "schema": res_schema or {"$ref": "#/components/schemas/ApiResponseGeneric"}
                    }
                }
            }
            endpoint_def["responses"]["400"] = {
                "description": "Validation failed / Invalid parameters",
                "content": {"application/json": {"schema": {"$ref": "#/components/schemas/ApiErrorResponse"}}}
            }
            if is_auth:
                endpoint_def["responses"]["401"] = {
                    "description": "Unauthorized / Missing or invalid JWT",
                    "content": {"application/json": {"schema": {"$ref": "#/components/schemas/ApiErrorResponse"}}}
                }
                endpoint_def["responses"]["403"] = {
                    "description": "Forbidden / Insufficient permissions",
                    "content": {"application/json": {"schema": {"$ref": "#/components/schemas/ApiErrorResponse"}}}
                }
            endpoint_def["responses"]["429"] = {
                "description": "Rate limit or daily quota exceeded",
                "content": {"application/json": {"schema": {"$ref": "#/components/schemas/ApiErrorResponse"}}}
            }
            endpoint_def["responses"]["500"] = {
                "description": "Internal server error",
                "content": {"application/json": {"schema": {"$ref": "#/components/schemas/ApiErrorResponse"}}}
            }

        paths[path][method.lower()] = endpoint_def

    # =========================================================================
    # MODULE 1: AUTHENTICATION (6 Endpoints)
    # =========================================================================
    # 1. API-AUTH-001: Request SMS OTP
    add_endpoint(
        "/auth/otp/send", "post", "Authentication", "Request 6-digit SMS OTP", "sendOtp",
        req_schema={
            "type": "object",
            "required": ["phone", "turnstile_token"],
            "properties": {
                "phone": {"type": "string", "example": "+201012732095", "pattern": r"^\+20(10|11|12|15)[0-9]{8}$"},
                "turnstile_token": {"type": "string", "example": "0.XXXXX.YYYYY"}
            }
        },
        is_auth=False
    )
    # 2. API-AUTH-002: Verify SMS OTP
    add_endpoint(
        "/auth/otp/verify", "post", "Authentication", "Verify SMS OTP and Sign In", "verifyOtp",
        req_schema={
            "type": "object",
            "required": ["phone", "code"],
            "properties": {
                "phone": {"type": "string", "example": "+201012732095"},
                "code": {"type": "string", "example": "583921", "pattern": r"^[0-9]{6}$"},
                "device_info": {
                    "type": "object",
                    "properties": {
                        "platform": {"type": "string", "enum": ["android", "ios", "web"]},
                        "fcm_token": {"type": "string"},
                        "app_version": {"type": "string"}
                    }
                }
            }
        },
        is_auth=False
    )
    # 3. API-AUTH-003: Silent Refresh Token Rotation
    add_endpoint(
        "/auth/token/refresh", "post", "Authentication", "Rotate Refresh Token & Mint New Access Token", "refreshToken",
        req_schema={
            "type": "object",
            "required": ["refresh_token"],
            "properties": {
                "refresh_token": {"type": "string", "example": "4f3c2b1a-8e9d-4c3b-2a1f-0e9d8c7b6a5f"}
            }
        },
        is_auth=False
    )
    # 4. API-AUTH-004: Password Login
    add_endpoint(
        "/auth/password/login", "post", "Authentication", "Sign In with Email and Password", "loginPassword",
        req_schema={
            "type": "object",
            "required": ["email", "password"],
            "properties": {
                "email": {"type": "string", "format": "email", "example": "admin@deal-one.eg"},
                "password": {"type": "string", "format": "password", "minLength": 8}
            }
        },
        is_auth=False
    )
    # 5. API-AUTH-005: Logout
    add_endpoint(
        "/auth/logout", "post", "Authentication", "Terminate Active Session", "logout",
        req_schema={
            "type": "object",
            "required": ["refresh_token"],
            "properties": {
                "refresh_token": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 6. API-AUTH-006: Terminate All Sessions
    add_endpoint(
        "/auth/sessions/terminate-all", "post", "Authentication", "Revoke All Active User Sessions", "terminateAllSessions",
        is_auth=True
    )

    # =========================================================================
    # MODULE 2: USERS (4 Endpoints)
    # =========================================================================
    # 7. API-USR-001: Get My Profile
    add_endpoint("/users/me", "get", "Users", "Get Current User Profile", "getMyProfile", is_auth=True)
    # 8. API-USR-002: Update My Profile
    add_endpoint(
        "/users/me", "patch", "Users", "Update Personal Profile", "updateMyProfile",
        req_schema={
            "type": "object",
            "properties": {
                "full_name": {"type": "string", "minLength": 3},
                "email": {"type": "string", "format": "email"},
                "avatar_url": {"type": "string", "format": "uri"}
            }
        },
        is_auth=True
    )
    # 9. API-USR-003: Register FCM Device
    add_endpoint(
        "/users/devices", "post", "Users", "Register or Update FCM Device Token", "registerDevice",
        req_schema={
            "type": "object",
            "required": ["fcm_token", "platform"],
            "properties": {
                "fcm_token": {"type": "string"},
                "platform": {"type": "string", "enum": ["android", "ios", "web"]},
                "device_model": {"type": "string"},
                "os_version": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 10. API-USR-004: Request Account Deletion
    add_endpoint(
        "/users/me/delete-request", "post", "Users", "Request Permanent User Deletion (GDPR/Compliance)", "requestDeletion",
        req_schema={
            "type": "object",
            "required": ["reason"],
            "properties": {
                "reason": {"type": "string"}
            }
        },
        is_auth=True
    )

    # =========================================================================
    # MODULE 3: ACCOUNTS & RBAC (7 Endpoints)
    # =========================================================================
    # 11. API-ACC-001: List My Accounts
    add_endpoint("/accounts/my-accounts", "get", "Accounts", "List All Seller Accounts for Current User", "getMyAccounts", is_auth=True)
    # 12. API-ACC-002: Create Seller Account
    add_endpoint(
        "/accounts", "post", "Accounts", "Create New Seller Account", "createAccount",
        req_schema={
            "type": "object",
            "required": ["display_name", "account_type"],
            "properties": {
                "display_name": {"type": "string", "minLength": 3},
                "account_type": {"type": "string", "enum": ["individual", "company", "factory", "store"]},
                "contact_phone": {"type": "string"},
                "whatsapp_number": {"type": "string"},
                "bio": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 13. API-ACC-003: Upload Verification Documents
    add_endpoint(
        "/accounts/{accountId}/verification-documents", "post", "Accounts", "Upload Commercial Documents for Verification", "uploadVerificationDocs",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["document_type", "document_urls"],
            "properties": {
                "document_type": {"type": "string", "enum": ["commercial_register", "tax_card", "license", "national_id"]},
                "document_urls": {"type": "array", "items": {"type": "string", "format": "uri"}},
                "registration_number": {"type": "string"}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 14. API-ACC-004: Get Account Details
    add_endpoint(
        "/accounts/{accountId}", "get", "Accounts", "Get Public Account Profile and Details", "getAccountDetails",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=False
    )
    # 15. API-ACC-005: List Account Members
    add_endpoint(
        "/accounts/{accountId}/members", "get", "Accounts", "List Account Team Members (RBAC)", "getAccountMembers",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=True, account_ctx=True
    )
    # 16. API-ACC-006: Invite Member
    add_endpoint(
        "/accounts/{accountId}/members/invite", "post", "Accounts", "Invite Team Member to Account", "inviteAccountMember",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["phone", "role"],
            "properties": {
                "phone": {"type": "string", "pattern": r"^\+20[0-9]{10}$"},
                "role": {"type": "string", "enum": ["manager", "lister", "responder"]}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 17. API-ACC-007: Remove Member
    add_endpoint(
        "/accounts/{accountId}/members/{userId}", "delete", "Accounts", "Remove Member from Account Team", "removeAccountMember",
        params=[
            {"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}},
            {"name": "userId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}
        ],
        is_auth=True, account_ctx=True
    )

    # =========================================================================
    # MODULE 4: GEOGRAPHIC TAXONOMY & LOCATIONS (5 Endpoints)
    # =========================================================================
    # 18. API-GEO-001: List Governorates & Cities
    add_endpoint("/locations/governorates", "get", "Locations", "List Egypt Governorates with Nested Cities", "listGovernorates", is_auth=False)
    # 19. API-GEO-002: List Areas
    add_endpoint(
        "/locations/cities/{cityId}/areas", "get", "Locations", "List Granular Neighborhoods in City", "listCityAreas",
        params=[{"name": "cityId", "in": "path", "required": True, "schema": {"type": "integer"}}],
        is_auth=False
    )
    # 20. API-GEO-003: Add Branch
    add_endpoint(
        "/accounts/{accountId}/branches", "post", "Locations", "Add Commercial Store / Showroom Branch", "addBranch",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["name_ar", "lat", "lng"],
            "properties": {
                "name_ar": {"type": "string"},
                "name_en": {"type": "string"},
                "address": {"type": "string"},
                "lat": {"type": "number"},
                "lng": {"type": "number"},
                "phone": {"type": "string"},
                "is_main": {"type": "boolean", "default": False}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 21. API-GEO-004: List Account Branches
    add_endpoint(
        "/accounts/{accountId}/branches", "get", "Locations", "List Commercial Branches for Account", "listBranches",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=False
    )
    # 22. API-GEO-005: Configure Service Areas
    add_endpoint(
        "/accounts/{accountId}/service-areas", "put", "Locations", "Configure Service Coverage Areas (Cities/Districts)", "setServiceAreas",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["city_ids"],
            "properties": {
                "city_ids": {"type": "array", "items": {"type": "integer"}},
                "area_ids": {"type": "array", "items": {"type": "integer"}}
            }
        },
        is_auth=True, account_ctx=True
    )

    # =========================================================================
    # MODULE 5: CATEGORIES (2 Endpoints)
    # =========================================================================
    # 23. API-CAT-001: Get Category Tree
    add_endpoint("/categories", "get", "Categories", "Get Complete 2-Level Category Taxonomy Tree", "getCategories", is_auth=False)
    # 24. API-CAT-002: Get Category Fields
    add_endpoint(
        "/categories/{categoryId}/fields", "get", "Categories", "Get Dynamic Attribute Field Definitions for Subcategory", "getCategoryFields",
        params=[{"name": "categoryId", "in": "path", "required": True, "schema": {"type": "integer"}}],
        is_auth=False
    )

    # =========================================================================
    # MODULE 6: LISTINGS CORE (8 Endpoints)
    # =========================================================================
    # 25. API-LST-001: Create Draft Listing
    add_endpoint(
        "/listings", "post", "Listings", "Create New Listing (Draft State)", "createListing",
        req_schema={
            "type": "object",
            "required": ["category_id", "title", "description", "price"],
            "properties": {
                "category_id": {"type": "integer"},
                "title": {"type": "string", "minLength": 5, "maxLength": 120},
                "description": {"type": "string", "minLength": 10},
                "price": {"type": "number", "minimum": 0},
                "price_on_inquiry": {"type": "boolean", "default": False},
                "physical_lat": {"type": "number"},
                "physical_lng": {"type": "number"},
                "area_id": {"type": "integer"},
                "attributes": {"type": "object"},
                "media_ids": {"type": "array", "items": {"type": "string", "format": "uuid"}}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 26. API-LST-002: Submit Listing for Review
    add_endpoint(
        "/listings/{listingId}/submit", "post", "Listings", "Submit Draft Listing for Moderation Review", "submitListing",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=True, account_ctx=True
    )
    # 27. API-LST-003: Update Listing
    add_endpoint(
        "/listings/{listingId}", "put", "Listings", "Update Listing Details", "updateListing",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "properties": {
                "title": {"type": "string"},
                "description": {"type": "string"},
                "price": {"type": "number"},
                "price_on_inquiry": {"type": "boolean"},
                "attributes": {"type": "object"}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 28. API-LST-004: Toggle Visibility
    add_endpoint(
        "/listings/{listingId}/visibility", "patch", "Listings", "Toggle Listing Publication Status (Hide/Publish)", "toggleListingVisibility",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["publication_status"],
            "properties": {
                "publication_status": {"type": "string", "enum": ["published", "hidden"]}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 29. API-LST-005: Update Availability
    add_endpoint(
        "/listings/{listingId}/availability", "patch", "Listings", "Update Operational Availability (Available/Sold/Reserved)", "updateAvailability",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["availability_status"],
            "properties": {
                "availability_status": {"type": "string", "enum": ["available", "reserved", "sold"]}
            }
        },
        is_auth=True, account_ctx=True
    )
    # 30. API-LST-006: Delete Listing
    add_endpoint(
        "/listings/{listingId}", "delete", "Listings", "Soft-Delete Listing", "deleteListing",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=True, account_ctx=True
    )
    # 31. API-LST-007: Get Public Listing
    add_endpoint(
        "/listings/{listingId}", "get", "Listings", "Get Detailed Public Listing Information", "getPublicListing",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=False
    )
    # 32. API-LST-008: List Merchant Listings
    add_endpoint(
        "/accounts/{accountId}/listings", "get", "Listings", "List Account Listings for Merchant Ad Management Feed", "listMerchantListings",
        params=[
            {"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}},
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"},
            {"name": "publication_status", "in": "query", "required": False, "schema": {"type": "string"}}
        ],
        is_auth=True, account_ctx=True
    )

    # =========================================================================
    # MODULE 7: SEARCH & DISCOVERY (3 Endpoints)
    # =========================================================================
    # 33. API-SRC-001: Unified Search
    add_endpoint(
        "/search", "get", "Search & Explore", "Unified Multi-Category & PostGIS Spatial Search", "searchListings",
        params=[
            {"name": "query", "in": "query", "required": False, "schema": {"type": "string"}},
            {"name": "category_slug", "in": "query", "required": False, "schema": {"type": "string"}},
            {"name": "city_id", "in": "query", "required": False, "schema": {"type": "integer"}},
            {"name": "area_id", "in": "query", "required": False, "schema": {"type": "integer"}},
            {"name": "lat", "in": "query", "required": False, "schema": {"type": "number"}},
            {"name": "lng", "in": "query", "required": False, "schema": {"type": "number"}},
            {"name": "radius_km", "in": "query", "required": False, "schema": {"type": "number", "default": 25.0}},
            {"name": "min_price", "in": "query", "required": False, "schema": {"type": "number"}},
            {"name": "max_price", "in": "query", "required": False, "schema": {"type": "number"}},
            {"name": "sort_by", "in": "query", "required": False, "schema": {"type": "string", "enum": ["latest", "price_asc", "price_desc", "nearest"]}},
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=False
    )
    # 34. API-SRC-002: Home Feed
    add_endpoint(
        "/feed/home", "get", "Search & Explore", "Get Curated Home Screen Feed", "getHomeFeed",
        params=[
            {"name": "city_id", "in": "query", "required": False, "schema": {"type": "integer"}},
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=False
    )
    # 35. API-SRC-003: Reveal External Contact
    add_endpoint(
        "/listings/{listingId}/reveal-contact", "post", "Search & Explore", "Reveal Seller Phone/WhatsApp (Quota Enforced)", "revealContact",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=True
    )

    # =========================================================================
    # MODULE 8: MEDIA & PRESIGNED UPLOADS (2 Endpoints)
    # =========================================================================
    # 36. API-MED-001: Presigned URL
    add_endpoint(
        "/media/presigned-url", "post", "Media", "Request Presigned Cloudflare R2 Upload URL", "getPresignedUrl",
        req_schema={
            "type": "object",
            "required": ["filename", "mime_type", "size_bytes"],
            "properties": {
                "filename": {"type": "string", "example": "villa_exterior.jpg"},
                "mime_type": {"type": "string", "enum": ["image/jpeg", "image/png", "image/webp", "video/mp4"]},
                "size_bytes": {"type": "integer", "maximum": 10485760, "example": 2048000}
            }
        },
        is_auth=True
    )
    # 37. API-MED-002: Confirm Upload
    add_endpoint(
        "/media/confirm-upload", "post", "Media", "Confirm Direct Upload and Enqueue EXIF Scrubbing Worker", "confirmUpload",
        req_schema={
            "type": "object",
            "required": ["key"],
            "properties": {
                "key": {"type": "string", "example": "uploads/2026/11/usr-1/uuid.jpg"}
            }
        },
        is_auth=True
    )

    # =========================================================================
    # MODULE 9: CHAT & MESSAGING (4 Endpoints)
    # =========================================================================
    # 38. API-CHT-001: Start/Fetch Conversation
    add_endpoint(
        "/chat/conversations", "post", "Chat", "Initiate or Retrieve Listing Conversation", "startConversation",
        req_schema={
            "type": "object",
            "required": ["listing_id"],
            "properties": {
                "listing_id": {"type": "string", "format": "uuid"},
                "initial_message": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 39. API-CHT-002: List Conversations
    add_endpoint(
        "/chat/conversations", "get", "Chat", "List Active Chat Conversations", "listConversations",
        params=[
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )
    # 40. API-CHT-003: Conversation Messages
    add_endpoint(
        "/chat/conversations/{conversationId}/messages", "get", "Chat", "Get Message History for Conversation", "getMessages",
        params=[
            {"name": "conversationId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}},
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )
    # 41. API-CHT-004: Send Message HTTP Fallback
    add_endpoint(
        "/chat/conversations/{conversationId}/messages", "post", "Chat", "Send Message via HTTP (WebSocket Fallback)", "sendMessageHttp",
        params=[{"name": "conversationId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["message_type", "content"],
            "properties": {
                "message_type": {"type": "string", "enum": ["text", "image", "location"]},
                "content": {"type": "string"},
                "media_url": {"type": "string", "format": "uri"}
            }
        },
        is_auth=True
    )

    # =========================================================================
    # MODULE 10: FAVORITES & REPORTS (4 Endpoints)
    # =========================================================================
    # 42. API-FAV-001: List Favorites
    add_endpoint(
        "/favorites", "get", "Engagement", "List User's Saved Favorite Listings", "listFavorites",
        params=[
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )
    # 43. API-FAV-002: Add Favorite
    add_endpoint(
        "/favorites/{listingId}", "post", "Engagement", "Bookmark Listing to Favorites", "addFavorite",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=True
    )
    # 44. API-FAV-003: Remove Favorite
    add_endpoint(
        "/favorites/{listingId}", "delete", "Engagement", "Remove Listing from Favorites", "removeFavorite",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        is_auth=True
    )
    # 45. API-REP-001: Submit Report
    add_endpoint(
        "/reports", "post", "Engagement", "Submit Abuse / Fraud / Spam Report", "submitReport",
        req_schema={
            "type": "object",
            "required": ["entity_type", "entity_id", "reason"],
            "properties": {
                "entity_type": {"type": "string", "enum": ["listing", "account", "message"]},
                "entity_id": {"type": "string"},
                "reason": {"type": "string", "enum": ["spam", "fraud", "counterfeit", "inappropriate", "wrong_category", "sold_already"]},
                "details": {"type": "string"}
            }
        },
        is_auth=True
    )

    # =========================================================================
    # MODULE 11: QUOTAS & NOTIFICATIONS (3 Endpoints)
    # =========================================================================
    # 46. API-QTA-001: Quota Usage
    add_endpoint(
        "/quotas/my-usage", "get", "Quotas & Notifications", "Get Current Daily Quota Balance (Resets Midnight Cairo)", "getQuotaUsage",
        is_auth=True
    )
    # 47. API-NOT-001: List Notifications
    add_endpoint(
        "/notifications", "get", "Quotas & Notifications", "List In-App Notifications", "listNotifications",
        params=[
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )
    # 48. API-NOT-002: Mark Read
    add_endpoint(
        "/notifications/read", "patch", "Quotas & Notifications", "Mark Notifications as Read", "markNotificationsRead",
        req_schema={
            "type": "object",
            "properties": {
                "notification_ids": {"type": "array", "items": {"type": "string", "format": "uuid"}},
                "all": {"type": "boolean", "default": False}
            }
        },
        is_auth=True
    )

    # =========================================================================
    # MODULE 12: ADMIN CONTROL CENTER & MODERATION (7 Endpoints)
    # =========================================================================
    # 49. API-ADM-001: Moderation Queue
    add_endpoint(
        "/admin/moderation/listings", "get", "Admin & Moderation", "Get Pending Listing Moderation Queue", "getModerationQueue",
        params=[
            {"name": "category_id", "in": "query", "required": False, "schema": {"type": "integer"}},
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )
    # 50. API-ADM-002: Moderation Decision
    add_endpoint(
        "/admin/moderation/listings/{listingId}/decision", "post", "Admin & Moderation", "Approve or Reject Pending Listing", "moderateListing",
        params=[{"name": "listingId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["decision"],
            "properties": {
                "decision": {"type": "string", "enum": ["approve", "reject"]},
                "rejection_reason": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 51. API-ADM-003: Verification Queue
    add_endpoint(
        "/admin/moderation/verifications", "get", "Admin & Moderation", "Review Pending Account Verification Submissions", "getVerificationQueue",
        params=[
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )
    # 52. API-ADM-004: Verification Decision
    add_endpoint(
        "/admin/moderation/verifications/{verificationId}/decision", "post", "Admin & Moderation", "Approve or Reject Seller Account Verification", "moderateVerification",
        params=[{"name": "verificationId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["decision"],
            "properties": {
                "decision": {"type": "string", "enum": ["approve", "reject"]},
                "notes": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 53. API-ADM-005: Suspend/Restore Account
    add_endpoint(
        "/admin/accounts/{accountId}/status", "post", "Admin & Moderation", "Suspend or Reinstate Business Account", "updateAccountStatus",
        params=[{"name": "accountId", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}],
        req_schema={
            "type": "object",
            "required": ["status", "reason"],
            "properties": {
                "status": {"type": "string", "enum": ["active", "suspended", "banned"]},
                "reason": {"type": "string"}
            }
        },
        is_auth=True
    )
    # 54. API-ADM-006: Platform Settings
    add_endpoint(
        "/admin/platform-settings", "put", "Admin & Moderation", "Update Dynamic Platform Settings & Default Quotas", "updatePlatformSettings",
        req_schema={
            "type": "object",
            "required": ["settings"],
            "properties": {
                "settings": {
                    "type": "object",
                    "properties": {
                        "daily_quota_individual_listings": {"type": "integer"},
                        "daily_quota_individual_reveals": {"type": "integer"},
                        "daily_quota_individual_chats": {"type": "integer"},
                        "daily_quota_business_listings": {"type": "integer"},
                        "daily_quota_business_reveals": {"type": "integer"},
                        "listing_expiry_days_fast_moving": {"type": "integer"},
                        "listing_expiry_days_considered": {"type": "integer"}
                    }
                }
            }
        },
        is_auth=True
    )
    # 55. API-ADM-007: Audit Logs
    add_endpoint(
        "/admin/audit-logs", "get", "Admin & Moderation", "Query Immutable Administrative Audit Logs", "queryAuditLogs",
        params=[
            {"name": "staff_user_id", "in": "query", "required": False, "schema": {"type": "string", "format": "uuid"}},
            {"name": "action", "in": "query", "required": False, "schema": {"type": "string"}},
            {"$ref": "#/components/parameters/CursorParam"},
            {"$ref": "#/components/parameters/LimitParam"}
        ],
        is_auth=True
    )

    return spec

def main():
    spec = generate_openapi_spec()
    
    # Count paths and operations
    total_paths = len(spec["paths"])
    total_operations = sum(len(methods) for methods in spec["paths"].values())
    
    print(f"Generated OpenAPI spec with {total_paths} paths and {total_operations} operations.")
    
    # Save to both target locations
    target_paths = [
        Path("backend_blueprint/openapi/deal_one_openapi.yaml"),
        Path("backend_blueprint/15_OPENAPI/deal_one_openapi.yaml")
    ]
    
    for target in target_paths:
        target.parent.mkdir(parents=True, exist_ok=True)
        with open(target, "w", encoding="utf-8") as f:
            yaml.dump(spec, f, sort_keys=False, allow_unicode=True, indent=2)
        print(f"Successfully wrote {target} ({target.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
