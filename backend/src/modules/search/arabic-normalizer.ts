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

/**
 * Generates expanded search term variants to handle Egyptian marketplace dialects and prefixes.
 * Includes definite article ('ال') stripping/addition, Alef/Taa Marbuta variants, and phonetic tokens.
 */
export function generateArabicSearchVariants(rawTerm: string): string[] {
  if (!rawTerm || !rawTerm.trim()) return [];

  const raw = rawTerm.trim();
  const normalized = normalizeArabicText(raw);
  const variants = new Set<string>();

  variants.add(raw);
  variants.add(normalized);

  // Split into individual words
  const words = normalized.split(' ');
  const strippedWords = words.map((w) =>
    w.startsWith('ال') && w.length > 3 ? w.substring(2) : w,
  );
  const prefixedWords = words.map((w) =>
    !w.startsWith('ال') && w.length > 2 ? `ال${w}` : w,
  );

  const strippedJoined = strippedWords.join(' ');
  const prefixedJoined = prefixedWords.join(' ');

  if (strippedJoined !== normalized) variants.add(strippedJoined);
  if (prefixedJoined !== normalized) variants.add(prefixedJoined);

  // Egyptian dialect phonetic variants: ذ/ز, ث/س
  const phonetic = normalized.replace(/ذ/g, 'ز').replace(/ث/g, 'س');
  if (phonetic !== normalized) variants.add(phonetic);

  return Array.from(variants);
}
