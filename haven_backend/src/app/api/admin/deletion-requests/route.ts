import { db } from '@/lib/db'
import { isAdmin } from '@/lib/adminAuth'
import { rateLimit, rateLimitKey } from '@/lib/rateLimit'

const ADMIN_LIMIT = 10
const ADMIN_WINDOW_MS = 15 * 60 * 1000

// GET /api/admin/deletion-requests — liste les demandes en attente
export async function GET(request: Request) {
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

  const requests = await db.accountDeletionRequest.findMany({
    where: { status: 'PENDING' },
    include: {
      user: { select: { id: true, name: true, email: true, schoolCode: true, className: true } },
    },
    orderBy: { createdAt: 'asc' },
  })

  return new Response(JSON.stringify(requests), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}
