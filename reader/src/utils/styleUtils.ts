/**
 * Converts snake_case keys of an object to camelCase.
 * Useful for mapping Codex manifest styles to React style objects.
 */
export function snakeToCamel(obj: Record<string, any> | undefined): Record<string, any> {
  if (!obj) return {};

  const result: Record<string, any> = {};

  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const camelKey = key.replace(/(_\w)/g, (m) => m[1].toUpperCase());
      result[camelKey] = obj[key];
    }
  }

  return result;
}
