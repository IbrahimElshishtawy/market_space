import { BadRequestException } from '@nestjs/common';
import { PhoneNormalizationService } from './phone-normalization.service';

describe('PhoneNormalizationService', () => {
  let service: PhoneNormalizationService;

  beforeEach(() => {
    service = new PhoneNormalizationService();
  });

  describe('Valid Egyptian Mobile Numbers', () => {
    const validCases = [
      // Vodafone (010)
      { input: '01012345678', expected: '+201012345678' },
      { input: '+201012345678', expected: '+201012345678' },
      { input: '00201012345678', expected: '+201012345678' },
      { input: '010-1234-5678', expected: '+201012345678' },
      { input: '+20 10 1234 5678', expected: '+201012345678' },
      { input: '  01012345678  ', expected: '+201012345678' },

      // Etisalat (011)
      { input: '01198765432', expected: '+201198765432' },
      { input: '+201198765432', expected: '+201198765432' },
      { input: '00201198765432', expected: '+201198765432' },

      // Orange (012)
      { input: '01234567890', expected: '+201234567890' },
      { input: '+201234567890', expected: '+201234567890' },

      // WE (015)
      { input: '01555555555', expected: '+201555555555' },
      { input: '+201555555555', expected: '+201555555555' },
    ];

    test.each(validCases)(
      'should correctly normalize $input to $expected',
      ({ input, expected }) => {
        expect(service.normalize(input)).toBe(expected);
        expect(service.isValid(input)).toBe(true);
      },
    );
  });

  describe('Invalid and Rejected Numbers', () => {
    const invalidCases = [
      // Landlines (Fixed-line)
      { input: '0223456789', desc: 'Cairo landline (02)' },
      { input: '+20223456789', desc: 'Cairo landline with country code' },
      { input: '0354321098', desc: 'Alexandria landline (03)' },
      { input: '+20354321098', desc: 'Alexandria landline with country code' },

      // Invalid mobile prefixes
      { input: '01312345678', desc: 'Non-existent prefix 013' },
      { input: '01412345678', desc: 'Non-existent prefix 014' },
      { input: '01612345678', desc: 'Non-existent prefix 016' },
      { input: '01712345678', desc: 'Non-existent prefix 017' },

      // Incomplete or extra digits
      { input: '010123456', desc: 'Too short' },
      { input: '010123456789', desc: 'Too long' },

      // Foreign numbers
      { input: '+14155552671', desc: 'US number' },
      { input: '+966501234567', desc: 'Saudi number' },
      { input: '+971501234567', desc: 'UAE number' },

      // Malformed inputs
      { input: '', desc: 'Empty string' },
      { input: 'not-a-number', desc: 'Alphabetic string' },
      { input: '+++01012345678', desc: 'Invalid symbols' },
    ];

    test.each(invalidCases)('should reject $desc ($input)', ({ input }) => {
      expect(() => service.normalize(input)).toThrow(BadRequestException);
      expect(service.isValid(input)).toBe(false);
    });
  });

  describe('formatDisplay', () => {
    it('should format E.164 into readable space-separated chunks', () => {
      expect(service.formatDisplay('+201012345678')).toBe('+20 10 1234 5678');
      expect(service.formatDisplay('01198765432')).toBe('+20 11 9876 5432');
    });
  });
});
