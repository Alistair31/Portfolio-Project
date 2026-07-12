import { db } from '@/lib/db'
import { isAdmin } from '@/lib/adminAuth'
import { rateLimit, rateLimitKey } from '@/lib/rateLimit'

const ADMIN_LIMIT = 10
const ADMIN_WINDOW_MS = 15 * 60 * 1000

// PATCH /api/admin/deletion-requests/[id]
// body: { "action": "approve" | "reject" }
export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { allowed, retryAfterSeconds } = rateLimit(rateLimitKey(request, 'admin'), ADMIN_LIMIT, ADMIN_WINDOW_MS)
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de tentatives. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { 'Content-Type': 'application/json', 'Retry-After': String(retryAfterSeconds) } }
    )
  }

  if (!isAdmin(request)) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { id } = await params
  const { action } = await request.json() as { action: string }
  if (action !== 'approve' && action !== 'reject') {
    return new Response(JSON.stringify({ error: 'Action invalide. Utilisez "approve" ou "reject".' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const deletionRequest = await db.accountDeletionRequest.findUnique({
    where: { id },
  })
  if (!deletionRequest || deletionRequest.status !== 'PENDING') {
    return new Response(JSON.stringify({ error: 'Demande introuvable ou déjà traitée.' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  if (action === 'reject') {
    await db.accountDeletionRequest.update({
      where: { id },
      data: { status: 'REJECTED', processedAt: new Date() },
    })
    return new Response(JSON.stringify({ message: 'Demande rejetée.' }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // approve : supprime l'utilisateur (cascade supprime la demande)
  await db.user.delete({ where: { id: deletionRequest.userId } })

  return new Response(JSON.stringify({ message: 'Compte supprimé.' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}
