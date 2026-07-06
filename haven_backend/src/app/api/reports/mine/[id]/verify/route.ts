import { timingSafeEqual } from 'crypto'
import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'
import { computeIntegrityHash } from '@/lib/integrity'

// ---------------------------------------------------------------------------
// GET /api/reports/mine/[id]/verify
// Recompute le hash HMAC du signalement et le compare à celui stocké en base.
// Retourne { verified: true } si le contenu n'a pas été altéré, { verified: false } sinon.
// ---------------------------------------------------------------------------
export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = extractUser(request)
  if (!user || user.role !== 'STUDENT') {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { id } = await params

  const report = await db.report.findUnique({
    where:  { id, authorId: user.id },
    select: {
      id:             true,
      type:           true,
      gravity:        true,
      mode:           true,
      anonymityLevel: true,
      description:    true,
      createdAt:      true,
      integrityHash:  true,
    },
  })

  if (!report) {
    return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  if (!report.integrityHash) {
    return new Response(JSON.stringify({ verified: null, reason: 'Aucun hash enregistré pour ce signalement.' }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const recomputed = computeIntegrityHash(report)
  // Comparaison à temps constant : timingSafeEqual exige des buffers de même
  // longueur, d'où la vérification préalable (deux hex HMAC-SHA256 valides
  // font toujours la même taille, mais on se protège d'une valeur corrompue).
  const verified =
    recomputed.length === report.integrityHash.length &&
    timingSafeEqual(Buffer.from(recomputed), Buffer.from(report.integrityHash))

  return new Response(JSON.stringify({ verified }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}
