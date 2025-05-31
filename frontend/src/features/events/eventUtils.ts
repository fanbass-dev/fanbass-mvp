export function slugify(name: string, date: string): string {
  return `${name}-${date}`
    .toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9\-]/g, '')
    .slice(0, 64)
}
