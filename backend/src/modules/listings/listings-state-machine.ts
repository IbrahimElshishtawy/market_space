import {
  ModerationStatus,
  PublicationStatus,
  AvailabilityStatus,
} from '../../core/enums/domain.enums';
import { BadRequestException } from '@nestjs/common';

/**
 * Deal One — Orthogonal 3-Axis Listing Lifecycle State Machine
 *
 * Implements Pattern C from `27_BACKEND_DESIGN_PATTERNS.md` and ADR-007.
 * Decouples the listing lifecycle into three strictly orthogonal, independent dimensions:
 *
 * 1. Moderation Axis: draft -> pending -> approved | rejected
 * 2. Publication Axis: unpublished -> published -> hidden | archived | expired
 * 3. Availability Axis: available -> reserved | sold | rented | out_of_stock | discontinued
 *
 * Rule: Only a listing with (approved × published × available) is publicly discoverable in buyer feed.
 */

export type ListingLifecycleAxis =
  'moderation' | 'publication' | 'availability';

export const VALID_MODERATION_TRANSITIONS: Record<
  ModerationStatus,
  readonly ModerationStatus[]
> = {
  [ModerationStatus.DRAFT]: [ModerationStatus.PENDING],
  [ModerationStatus.PENDING]: [
    ModerationStatus.APPROVED,
    ModerationStatus.REJECTED,
  ],
  [ModerationStatus.APPROVED]: [
    ModerationStatus.PENDING,
    ModerationStatus.REJECTED,
  ],
  [ModerationStatus.REJECTED]: [ModerationStatus.PENDING],
};

export const VALID_PUBLICATION_TRANSITIONS: Record<
  PublicationStatus,
  readonly PublicationStatus[]
> = {
  [PublicationStatus.UNPUBLISHED]: [
    PublicationStatus.PUBLISHED,
    PublicationStatus.ARCHIVED,
  ],
  [PublicationStatus.PUBLISHED]: [
    PublicationStatus.HIDDEN,
    PublicationStatus.EXPIRED,
    PublicationStatus.ARCHIVED,
  ],
  [PublicationStatus.HIDDEN]: [
    PublicationStatus.PUBLISHED,
    PublicationStatus.ARCHIVED,
  ],
  [PublicationStatus.EXPIRED]: [
    PublicationStatus.PUBLISHED,
    PublicationStatus.ARCHIVED,
  ],
  [PublicationStatus.ARCHIVED]: [], // Terminal state
};

export const VALID_AVAILABILITY_TRANSITIONS: Record<
  AvailabilityStatus,
  readonly AvailabilityStatus[]
> = {
  [AvailabilityStatus.AVAILABLE]: [
    AvailabilityStatus.RESERVED,
    AvailabilityStatus.SOLD,
    AvailabilityStatus.RENTED,
    AvailabilityStatus.OUT_OF_STOCK,
    AvailabilityStatus.DISCONTINUED,
  ],
  [AvailabilityStatus.RESERVED]: [
    AvailabilityStatus.AVAILABLE,
    AvailabilityStatus.SOLD,
    AvailabilityStatus.RENTED,
  ],
  [AvailabilityStatus.SOLD]: [
    AvailabilityStatus.AVAILABLE,
    AvailabilityStatus.DISCONTINUED,
  ],
  [AvailabilityStatus.RENTED]: [
    AvailabilityStatus.AVAILABLE,
    AvailabilityStatus.DISCONTINUED,
  ],
  [AvailabilityStatus.OUT_OF_STOCK]: [
    AvailabilityStatus.AVAILABLE,
    AvailabilityStatus.DISCONTINUED,
  ],
  [AvailabilityStatus.DISCONTINUED]: [AvailabilityStatus.AVAILABLE],
};

export function assertValidModerationTransition(
  current: ModerationStatus,
  target: ModerationStatus,
): void {
  const allowed = VALID_MODERATION_TRANSITIONS[current];
  if (!allowed || !allowed.includes(target)) {
    throw new BadRequestException(
      `Invalid moderation transition from '${current}' to '${target}'. Allowed targets: [${(allowed || []).join(', ')}]`,
    );
  }
}

export function assertValidPublicationTransition(
  current: PublicationStatus,
  target: PublicationStatus,
): void {
  const allowed = VALID_PUBLICATION_TRANSITIONS[current];
  if (!allowed || !allowed.includes(target)) {
    throw new BadRequestException(
      `Invalid publication transition from '${current}' to '${target}'. Allowed targets: [${(allowed || []).join(', ')}]`,
    );
  }
}

export function assertValidAvailabilityTransition(
  current: AvailabilityStatus,
  target: AvailabilityStatus,
): void {
  const allowed = VALID_AVAILABILITY_TRANSITIONS[current];
  if (!allowed || !allowed.includes(target)) {
    throw new BadRequestException(
      `Invalid availability transition from '${current}' to '${target}'. Allowed targets: [${(allowed || []).join(', ')}]`,
    );
  }
}

export function assertValidTransition(
  axis: 'moderation',
  current: ModerationStatus,
  target: ModerationStatus,
): void;
export function assertValidTransition(
  axis: 'publication',
  current: PublicationStatus,
  target: PublicationStatus,
): void;
export function assertValidTransition(
  axis: 'availability',
  current: AvailabilityStatus,
  target: AvailabilityStatus,
): void;
export function assertValidTransition(
  axis: ListingLifecycleAxis,
  current: string,
  target: string,
): void;
export function assertValidTransition(
  axis: ListingLifecycleAxis,
  current: string,
  target: string,
): void {
  switch (axis) {
    case 'moderation':
      return assertValidModerationTransition(
        current as ModerationStatus,
        target as ModerationStatus,
      );
    case 'publication':
      return assertValidPublicationTransition(
        current as PublicationStatus,
        target as PublicationStatus,
      );
    case 'availability':
      return assertValidAvailabilityTransition(
        current as AvailabilityStatus,
        target as AvailabilityStatus,
      );
    default:
      throw new BadRequestException(`Unknown lifecycle axis: '${axis}'`);
  }
}

/**
 * Checks whether a listing is eligible for public buyer search and feed indexation.
 * Strictly enforces that all 3 dimensions must be:
 * (moderation = approved) AND (publication = published) AND (availability = available).
 */
export function isListingPubliclyVisible(listing: {
  moderationStatus: string;
  publicationStatus: string;
  availabilityStatus: string;
}): boolean {
  return (
    listing.moderationStatus === ModerationStatus.APPROVED &&
    listing.publicationStatus === PublicationStatus.PUBLISHED &&
    listing.availabilityStatus === AvailabilityStatus.AVAILABLE
  );
}

/**
 * Validates whether a listing can be published based on its moderation and availability status.
 */
export function assertCanPublish(listing: {
  moderationStatus: string;
  availabilityStatus: string;
}): boolean {
  if (listing.moderationStatus !== ModerationStatus.APPROVED) {
    throw new BadRequestException(
      `Cannot publish listing with moderationStatus '${listing.moderationStatus}'. Moderation status must be '${ModerationStatus.APPROVED}'.`,
    );
  }
  if (
    listing.availabilityStatus === AvailabilityStatus.SOLD ||
    listing.availabilityStatus === AvailabilityStatus.DISCONTINUED
  ) {
    throw new BadRequestException(
      `Cannot publish listing with availabilityStatus '${listing.availabilityStatus}'. Item is not available.`,
    );
  }
  return true;
}

/**
 * @deprecated Legacy 1D transition helper kept for temporary compatibility.
 * Delegates to assertValidPublicationTransition.
 */
export function assertValidListingTransition(
  currentStatus: PublicationStatus,
  targetStatus: PublicationStatus,
): void {
  assertValidPublicationTransition(currentStatus, targetStatus);
}
