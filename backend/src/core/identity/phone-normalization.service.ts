import { Injectable, BadRequestException } from '@nestjs/common';
import { parsePhoneNumberFromString, CountryCode } from 'libphonenumber-js';

export interface PhoneValidationResult {
  isValid: boolean;
  e164: string | null;
  error?: string;
}

/**
 * Centralized Phone Normalization Service for Deal One.
 *
 * Current V1 Policy:
 * - Strictly supports Egyptian mobile phone numbers (Vodafone: 010, Orange: 012, Etisalat: 011, WE: 015).
 * - Canonical storage format: E.164 (+2010XXXXXXXX, +2011XXXXXXXX, +2012XXXXXXXX, +2015XXXXXXXX). Total 13 characters.
 * - Accepts diverse input representations: local (01012345678), international (+201012345678, 00201012345678), formatted (010-1234-5678, +20 10 1234 5678).
 * - Explicitly rejects Egyptian fixed-line/landline numbers (Cairo 02, Alexandria 03, etc.), short codes, and non-Egyptian numbers in V1.
 */
@Injectable()
export class PhoneNormalizationService {
  private readonly defaultCountry: CountryCode = 'EG';
  private readonly egMobilePrefixRegex = /^\+20(10|11|12|15)\d{8}$/;

  /**
   * Validates and normalizes any user-supplied phone string into canonical E.164 format.
   * Throws BadRequestException on invalid or non-Egyptian numbers.
   */
  normalize(rawPhone: string): string {
    const result = this.validateAndNormalize(rawPhone);
    if (!result.isValid || !result.e164) {
      throw new BadRequestException(
        result.error ||
          'Invalid phone number. Must be a valid Egyptian mobile number (e.g. +201012345678 or 01012345678).',
      );
    }
    return result.e164;
  }

  /**
   * Non-throwing validation and normalization check.
   */
  validateAndNormalize(rawPhone: string): PhoneValidationResult {
    if (!rawPhone || typeof rawPhone !== 'string') {
      return {
        isValid: false,
        e164: null,
        error: 'Phone number must be a non-empty string.',
      };
    }

    const trimmed = rawPhone.trim().replace(/[\s\-_()]/g, '');

    // Convert 0020 prefix to +20
    let preprocessed = trimmed;
    if (preprocessed.startsWith('0020')) {
      preprocessed = `+${preprocessed.substring(2)}`;
    }

    try {
      const parsed = parsePhoneNumberFromString(
        preprocessed,
        this.defaultCountry,
      );

      if (!parsed || !parsed.isValid()) {
        return {
          isValid: false,
          e164: null,
          error:
            'Phone number syntax is invalid or unrecognized by telephony rules.',
        };
      }

      if (parsed.country !== 'EG') {
        return {
          isValid: false,
          e164: null,
          error:
            'Platform currently supports only Egyptian mobile phone numbers (+20).',
        };
      }

      const e164 = parsed.format('E.164');

      // Enforce Egyptian mobile prefix (10, 11, 12, 15) and exact 10 subscriber digits
      if (!this.egMobilePrefixRegex.test(e164)) {
        return {
          isValid: false,
          e164: null,
          error:
            'Fixed-line, premium, and non-mobile Egyptian numbers are not eligible for account registration.',
        };
      }

      return {
        isValid: true,
        e164,
      };
    } catch {
      return {
        isValid: false,
        e164: null,
        error: 'Failed to parse phone number.',
      };
    }
  }

  /**
   * Returns true if phone is a valid Egyptian mobile number.
   */
  isValid(rawPhone: string): boolean {
    return this.validateAndNormalize(rawPhone).isValid;
  }

  /**
   * Formats normalized E.164 for human display in UI (e.g. "+20 10 1234 5678").
   */
  formatDisplay(normalizedPhone: string): string {
    const e164 = this.normalize(normalizedPhone);
    return `${e164.slice(0, 3)} ${e164.slice(3, 5)} ${e164.slice(5, 9)} ${e164.slice(9)}`;
  }
}
