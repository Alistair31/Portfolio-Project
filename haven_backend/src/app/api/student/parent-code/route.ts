import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'

// GET /api/student/parent-code — l'élève récupère son code de liaison parent
export async function GET(request: Request) {
  const user = extractUser(request)
  if (!user || user.role !== 'STUDENT') {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const student = await db.user.findUnique({
    where:  { id: user.id },
    select: { parentCode: true },
  })

  return new Response(JSON.stringify({ parentCode: student?.parentCode ?? null }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}
