import { db } from './db'

const CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

function randomSegment(length: number): string {
  let result = ''
  for (let i = 0; i < length; i++) {
    result += CHARS[Math.floor(Math.random() * CHARS.length)]
  }
  return result
}

// Génère un code unique de type HVN-XXXX-XXXX.
// Vérifie l'unicité en base avant de retourner — les collisions sont
// extrêmement rares (~1 milliard de combinaisons) mais on les gère proprement.
export async function generateTrackingCode(): Promise<string> {
  for (let attempt = 0; attempt < 10; attempt++) {
    const code = `HVN-${randomSegment(4)}-${randomSegment(4)}`
    const existing = await db.report.findUnique({ where: { trackingCode: code } })
    if (!existing) return code
  }
  throw new Error('Impossible de générer un code de suivi unique')
}
