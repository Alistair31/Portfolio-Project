import { db } from '@/lib/db'
import { z } from 'zod'
import jwt from 'jsonwebtoken'

const schema = z.object({
  type:           z.enum(['PHYSICAL', 'VERBAL', 'SEXUAL', 'CYBER', 'OTHER']),
  gravity:        z.number().int().min(1).max(5),
  description:    z.string().min(10).max(1000),
  targetLevel:    z.enum(['TEACHER', 'DIRECTOR_CPE', 'RECTORAT']),
  anonymityLevel: z.enum(['NONE', 'NAME_HIDDEN', 'NAME_AND_CLASS_HIDDEN', 'FULLY_ANONYMOUS']),
})

function extractUser(request: Request): { id: string; role: string } | null {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) return null
  try {
    const token = authHeader.split(' ')[1]
    return jwt.verify(token, process.env.JWT_SECRET!) as { id: string; role: string }
  } catch {
    return null
  }
}

export async function POST(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  if (user.role !== 'STUDENT') {
    return new Response(JSON.stringify({ error: 'Seuls les élèves peuvent soumettre un signalement' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const body = await request.json()
  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const report = await db.report.create({
      data: {
        ...result.data,
        authorId: user.id,
      },
    })

    return new Response(JSON.stringify({ success: true, id: report.id }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[POST /api/reports]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}

export async function GET(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const allowedRoles = ['TEACHER', 'DIRECTOR_CPE', 'RECTORAT']
  if (!allowedRoles.includes(user.role)) {
    return new Response(JSON.stringify({ error: 'Accès refusé' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const staffUser = await db.user.findUnique({
      where: { id: user.id },
      select: { schoolCode: true },
    })

    const reports = await db.report.findMany({
      where: {
        targetLevel: user.role as 'TEACHER' | 'DIRECTOR_CPE' | 'RECTORAT',
        author: { schoolCode: staffUser?.schoolCode ?? '' },
      },
      select: {
        id:             true,
        type:           true,
        gravity:        true,
        description:    true,
        targetLevel:    true,
        anonymityLevel: true,
        status:         true,
        createdAt:      true,
        author: {
          select: {
            name:      true,
            className: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    })

    return new Response(JSON.stringify(reports), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/reports]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
