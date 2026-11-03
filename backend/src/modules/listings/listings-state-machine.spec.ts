import { BadRequestException } from '@nestjs/common';
import {
  ModerationStatus,
  PublicationStatus,
  AvailabilityStatus,
} from '../../core/enums/domain.enums';
import {
  assertValidModerationTransition,
  assertValidPublicationTransition,
  assertValidAvailabilityTransition,
  assertValidTransition,
  isListingPubliclyVisible,
  assertCanPublish,
  assertValidListingTransition,
} from './listings-state-machine';

describe('Listing Lifecycle State Machine (Pattern C - ADR-007)', () => {
  describe('1. Moderation Axis Transitions', () => {
    it('should allow valid moderation transitions', () => {
      // DRAFT -> PENDING
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.DRAFT,
          ModerationStatus.PENDING,
        ),
      ).not.toThrow();

      // PENDING -> APPROVED
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.PENDING,
          ModerationStatus.APPROVED,
        ),
      ).not.toThrow();

      // PENDING -> REJECTED
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.PENDING,
          ModerationStatus.REJECTED,
        ),
      ).not.toThrow();

      // REJECTED -> PENDING (resubmission)
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.REJECTED,
          ModerationStatus.PENDING,
        ),
      ).not.toThrow();

      // APPROVED -> PENDING (staff re-review or seller edit)
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.APPROVED,
          ModerationStatus.PENDING,
        ),
      ).not.toThrow();
    });

    it('should reject invalid moderation transitions with BadRequestException', () => {
      // Cannot skip review: DRAFT -> APPROVED
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.DRAFT,
          ModerationStatus.APPROVED,
        ),
      ).toThrow(BadRequestException);

      // Cannot directly reject draft: DRAFT -> REJECTED
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.DRAFT,
          ModerationStatus.REJECTED,
        ),
      ).toThrow(BadRequestException);

      // Cannot directly approve rejected without review: REJECTED -> APPROVED
      expect(() =>
        assertValidModerationTransition(
          ModerationStatus.REJECTED,
          ModerationStatus.APPROVED,
        ),
      ).toThrow(BadRequestException);
    });
  });

  describe('2. Publication Axis Transitions', () => {
    it('should allow valid publication transitions', () => {
      // UNPUBLISHED -> PUBLISHED
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.UNPUBLISHED,
          PublicationStatus.PUBLISHED,
        ),
      ).not.toThrow();

      // PUBLISHED -> HIDDEN (pause)
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.PUBLISHED,
          PublicationStatus.HIDDEN,
        ),
      ).not.toThrow();

      // HIDDEN -> PUBLISHED (resume)
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.HIDDEN,
          PublicationStatus.PUBLISHED,
        ),
      ).not.toThrow();

      // PUBLISHED -> EXPIRED (TTL expiry)
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.PUBLISHED,
          PublicationStatus.EXPIRED,
        ),
      ).not.toThrow();

      // EXPIRED -> PUBLISHED (renew)
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.EXPIRED,
          PublicationStatus.PUBLISHED,
        ),
      ).not.toThrow();

      // Any active state -> ARCHIVED
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.PUBLISHED,
          PublicationStatus.ARCHIVED,
        ),
      ).not.toThrow();
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.HIDDEN,
          PublicationStatus.ARCHIVED,
        ),
      ).not.toThrow();
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.EXPIRED,
          PublicationStatus.ARCHIVED,
        ),
      ).not.toThrow();
    });

    it('should reject invalid publication transitions with BadRequestException', () => {
      // ARCHIVED is terminal: ARCHIVED -> PUBLISHED is prohibited
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.ARCHIVED,
          PublicationStatus.PUBLISHED,
        ),
      ).toThrow(BadRequestException);

      // Cannot pause an unpublished ad: UNPUBLISHED -> HIDDEN
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.UNPUBLISHED,
          PublicationStatus.HIDDEN,
        ),
      ).toThrow(BadRequestException);

      // Cannot expire an unpublished ad: UNPUBLISHED -> EXPIRED
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.UNPUBLISHED,
          PublicationStatus.EXPIRED,
        ),
      ).toThrow(BadRequestException);
    });
  });

  describe('3. Availability Axis Transitions', () => {
    it('should allow valid availability transitions', () => {
      // AVAILABLE -> RESERVED
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.AVAILABLE,
          AvailabilityStatus.RESERVED,
        ),
      ).not.toThrow();

      // AVAILABLE -> SOLD
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.AVAILABLE,
          AvailabilityStatus.SOLD,
        ),
      ).not.toThrow();

      // AVAILABLE -> RENTED
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.AVAILABLE,
          AvailabilityStatus.RENTED,
        ),
      ).not.toThrow();

      // AVAILABLE -> OUT_OF_STOCK
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.AVAILABLE,
          AvailabilityStatus.OUT_OF_STOCK,
        ),
      ).not.toThrow();

      // RESERVED -> AVAILABLE (release reservation)
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.RESERVED,
          AvailabilityStatus.AVAILABLE,
        ),
      ).not.toThrow();

      // SOLD -> AVAILABLE (relabeled or canceled order)
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.SOLD,
          AvailabilityStatus.AVAILABLE,
        ),
      ).not.toThrow();
    });

    it('should reject invalid availability transitions', () => {
      // RESERVED -> OUT_OF_STOCK directly without release
      expect(() =>
        assertValidAvailabilityTransition(
          AvailabilityStatus.RESERVED,
          AvailabilityStatus.OUT_OF_STOCK,
        ),
      ).toThrow(BadRequestException);
    });
  });

  describe('4. Unified Transition Dispatcher (assertValidTransition)', () => {
    it('should correctly validate across axes using axis tag', () => {
      expect(() =>
        assertValidTransition(
          'moderation',
          ModerationStatus.DRAFT,
          ModerationStatus.PENDING,
        ),
      ).not.toThrow();

      expect(() =>
        assertValidTransition(
          'publication',
          PublicationStatus.PUBLISHED,
          PublicationStatus.HIDDEN,
        ),
      ).not.toThrow();

      expect(() =>
        assertValidTransition(
          'availability',
          AvailabilityStatus.AVAILABLE,
          AvailabilityStatus.SOLD,
        ),
      ).not.toThrow();
    });

    it('should throw on invalid axis name', () => {
      expect(() => assertValidTransition('unknown' as any, 'a', 'b')).toThrow(
        BadRequestException,
      );
    });
  });

  describe('5. Multi-Dimensional Public Visibility Rule (isListingPubliclyVisible)', () => {
    it('should return true ONLY when approved × published × available', () => {
      const publicListing = {
        moderationStatus: ModerationStatus.APPROVED,
        publicationStatus: PublicationStatus.PUBLISHED,
        availabilityStatus: AvailabilityStatus.AVAILABLE,
      };
      expect(isListingPubliclyVisible(publicListing)).toBe(true);
    });

    it('should return false if moderation is not approved', () => {
      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.PENDING,
          publicationStatus: PublicationStatus.PUBLISHED,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toBe(false);

      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.DRAFT,
          publicationStatus: PublicationStatus.PUBLISHED,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toBe(false);

      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.REJECTED,
          publicationStatus: PublicationStatus.PUBLISHED,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toBe(false);
    });

    it('should return false if publication status is not published', () => {
      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.APPROVED,
          publicationStatus: PublicationStatus.HIDDEN,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toBe(false);

      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.APPROVED,
          publicationStatus: PublicationStatus.EXPIRED,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toBe(false);

      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.APPROVED,
          publicationStatus: PublicationStatus.ARCHIVED,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toBe(false);
    });

    it('should return false if availability status is not available', () => {
      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.APPROVED,
          publicationStatus: PublicationStatus.PUBLISHED,
          availabilityStatus: AvailabilityStatus.SOLD,
        }),
      ).toBe(false);

      expect(
        isListingPubliclyVisible({
          moderationStatus: ModerationStatus.APPROVED,
          publicationStatus: PublicationStatus.PUBLISHED,
          availabilityStatus: AvailabilityStatus.RESERVED,
        }),
      ).toBe(false);
    });
  });

  describe('6. assertCanPublish', () => {
    it('should allow publishing when approved and available', () => {
      expect(() =>
        assertCanPublish({
          moderationStatus: ModerationStatus.APPROVED,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).not.toThrow();
    });

    it('should throw if moderationStatus is not approved', () => {
      expect(() =>
        assertCanPublish({
          moderationStatus: ModerationStatus.PENDING,
          availabilityStatus: AvailabilityStatus.AVAILABLE,
        }),
      ).toThrow(BadRequestException);
    });

    it('should throw if availabilityStatus is sold or discontinued', () => {
      expect(() =>
        assertCanPublish({
          moderationStatus: ModerationStatus.APPROVED,
          availabilityStatus: AvailabilityStatus.SOLD,
        }),
      ).toThrow(BadRequestException);
    });
  });

  describe('7. Compatibility helper (assertValidListingTransition)', () => {
    it('should route to publication transition validator', () => {
      expect(() =>
        assertValidListingTransition(
          PublicationStatus.PUBLISHED,
          PublicationStatus.HIDDEN,
        ),
      ).not.toThrow();

      expect(() =>
        assertValidListingTransition(
          PublicationStatus.ARCHIVED,
          PublicationStatus.PUBLISHED,
        ),
      ).toThrow(BadRequestException);
    });
  });
});
