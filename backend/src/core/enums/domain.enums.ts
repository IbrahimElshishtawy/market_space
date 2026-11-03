/**
 * Domain Enums for Deal One Backend Architecture
 *
 * Provides strongly-typed enums for compile-time safety and runtime validation
 * across the 28-table Modular Monolith architecture.
 */

export enum UserRole {
  USER = 'USER',
  MODERATOR = 'MODERATOR',
  SUPER_ADMIN = 'SUPER_ADMIN',
}

export enum UserStatus {
  PENDING_VERIFICATION = 'PENDING_VERIFICATION',
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
  DELETED = 'DELETED',
}

export enum AccountType {
  INDIVIDUAL = 'individual',
  COMPANY = 'company',
  FACTORY = 'factory',
  OFFICE = 'office',
  STORE = 'store',
}

export enum AccountMemberRole {
  OWNER = 'owner',
  MANAGER = 'manager',
  LISTER = 'lister',
  RESPONDER = 'responder',
}

export enum VerificationStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

export enum ModerationStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

export enum PublicationStatus {
  UNPUBLISHED = 'unpublished',
  PUBLISHED = 'published',
  HIDDEN = 'hidden',
  ARCHIVED = 'archived',
  EXPIRED = 'expired',
}

export enum AvailabilityStatus {
  AVAILABLE = 'available',
  RESERVED = 'reserved',
  SOLD = 'sold',
  RENTED = 'rented',
  OUT_OF_STOCK = 'out_of_stock',
  DISCONTINUED = 'discontinued',
}

export enum ListingStatus {
  DRAFT = 'draft',
  PENDING_REVIEW = 'pending',
  PUBLISHED = 'published',
  REJECTED = 'rejected',
  PAUSED = 'hidden',
  EXPIRED = 'expired',
  SOLD = 'sold',
  ARCHIVED = 'archived',
}

export enum ListingCondition {
  NEW = 'NEW',
  USED = 'USED',
  NOT_APPLICABLE = 'NOT_APPLICABLE',
}

export enum ListingKind {
  SALE = 'sale',
  RENT = 'rent',
  BUY = 'buy',
  SERVICE = 'service',
  PRODUCT = 'product',
}

export enum ContactChannel {
  IN_APP = 'in_app',
  EXTERNAL = 'external',
}

export enum MediaType {
  IMAGE = 'image',
  VIDEO = 'video',
}

export enum MediaStatus {
  PENDING = 'pending',
  READY = 'ready',
  FAILED = 'failed',
}

export enum PaymentStatus {
  PENDING = 'pending',
  SUCCESS = 'success',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

export enum PromoType {
  BUMP_UP = 'bump_up',
  FEATURED_7_DAYS = 'featured_7_days',
  FEATURED_14_DAYS = 'featured_14_days',
}

export enum ReportReason {
  SCAM = 'scam',
  INAPPROPRIATE = 'inappropriate',
  FALSE_INFO = 'false_info',
  DUPLICATE = 'duplicate',
  PROHIBITED = 'prohibited',
  OTHER = 'other',
}

export enum ReportStatus {
  OPEN = 'open',
  RESOLVED = 'resolved',
  DISMISSED = 'dismissed',
}

export enum ConversationStatus {
  OPEN = 'open',
  CLOSED = 'closed',
  ARCHIVED = 'archived',
}

export enum MessageStatus {
  SENT = 'sent',
  DELIVERED = 'delivered',
  READ = 'read',
}

export enum QuotaType {
  LISTINGS = 'listings',
  MESSAGES = 'messages',
  CONTACT_REVEAL = 'contact_reveal',
}

export enum FieldType {
  TEXT = 'text',
  NUMBER = 'number',
  SELECT = 'select',
  MULTI_SELECT = 'multi_select',
  BOOLEAN = 'boolean',
}
