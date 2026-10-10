/**
 * High-performance Arabic text normalizer for search indexing and querying.
 * Standardizes Arabic letter variants, removes diacritics (tashkeel), and normalizes spacing.
 */
export function normalizeArabicText(input: string): string {
  if (!input) return '';

  return (
    input
      .trim()
      // Remove Arabic Tashkeel / Harakat (diacritics)
      .replace(/[\u064B-\u0652\u0670\u0640]/g, '')
      // Normalize Alef variants (أ, إ, آ, ٱ) -> ا
      .replace(/[أإآٱ]/g, 'ا')
      // Normalize Taa Marbuta (ة) -> ه
      .replace(/ة/g, 'ه')
      // Normalize Alef Maksura (ى) -> ي
      .replace(/ى/g, 'ي')
      // Normalize Persian/Urdu Kaf (ک) -> ك
      .replace(/ک/g, 'ك')
      // Normalize Persian Yeh (ی) -> ي
      .replace(/ی/g, 'ي')
      // Normalize multiple consecutive whitespace to a single space
      .replace(/\s+/g, ' ')
  );
}
