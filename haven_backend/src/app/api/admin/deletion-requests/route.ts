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

// GET /api/admin/deletion-requests — liste les demandes en attente
export async function GET(request: Request) {
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
