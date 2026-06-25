export type AnonymityLevel = 'NONE' | 'NAME_HIDDEN' | 'NAME_AND_CLASS_HIDDEN' | 'FULLY_ANONYMOUS'

export function applyAnonymity(
  author: { name: string; className: string; schoolCode?: string },
  level: AnonymityLevel
): { name: string | null; className: string | null; schoolCode?: string | null } {
  switch (level) {
    case 'NONE':
      return author
    case 'NAME_HIDDEN':
      return { ...author, name: null }
    case 'NAME_AND_CLASS_HIDDEN':
      return { ...author, name: null, className: null }
    case 'FULLY_ANONYMOUS':
      return {
        name: null,
        className: null,
        ...(author.schoolCode !== undefined ? { schoolCode: null } : {}),
      }
  }
}
