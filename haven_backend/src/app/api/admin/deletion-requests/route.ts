import { db } from '@/lib/db'

function isAdmin(request: Request): boolean {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) return false
  return authHeader.split(' ')[1] === process.env.ADMIN_SECRET
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
