import { ListingStatus } from '@prisma/client';
import { BadRequestException } from '@nestjs/common';

export const VALID_LISTING_TRANSITIONS: Record<ListingStatus, ListingStatus[]> = {
  [ListingStatus.DRAFT]: [ListingStatus.PENDING_REVIEW, ListingStatus.ARCHIVED],
  [ListingStatus.PENDING_REVIEW]: [
    ListingStatus.PUBLISHED,
    ListingStatus.REJECTED,
    ListingStatus.ARCHIVED,
  ],
  [ListingStatus.PUBLISHED]: [
    ListingStatus.PAUSED,
    ListingStatus.EXPIRED,
    ListingStatus.SOLD,
    ListingStatus.ARCHIVED,
  ],
  [ListingStatus.REJECTED]: [ListingStatus.PENDING_REVIEW, ListingStatus.ARCHIVED],
  [ListingStatus.PAUSED]: [ListingStatus.PUBLISHED, ListingStatus.ARCHIVED],
  [ListingStatus.EXPIRED]: [ListingStatus.PUBLISHED, ListingStatus.ARCHIVED],
  [ListingStatus.SOLD]: [ListingStatus.ARCHIVED],
  [ListingStatus.ARCHIVED]: [], // Terminal state
};

export function assertValidListingTransition(
  currentStatus: ListingStatus,
  targetStatus: ListingStatus,
): void {
  const allowed = VALID_LISTING_TRANSITIONS[currentStatus];
  if (!allowed || !allowed.includes(targetStatus)) {
    throw new BadRequestException(
      `Invalid listing status transition from '${currentStatus}' to '${targetStatus}'. Allowed targets: [${(allowed || []).join(', ')}]`,
    );
  }
}
