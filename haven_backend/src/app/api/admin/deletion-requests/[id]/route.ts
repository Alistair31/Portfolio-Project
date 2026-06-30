import { db } from '@/lib/db'
import { timingSafeEqual } from 'crypto'

function isAdmin(request: Request): boolean {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ') || !process.env.ADMIN_SECRET) return false

  const token = authHeader.split(' ')[1]
  const tokenBuf  = Buffer.from(token)
  const secretBuf = Buffer.from(process.env.ADMIN_SECRET)
  if (tokenBuf.length !== secretBuf.length) return false
  return timingSafeEqual(tokenBuf, secretBuf)
}

// PATCH /api/admin/deletion-requests/[id]
// body: { "action": "approve" | "reject" }
export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
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
