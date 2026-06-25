import { db } from '@/lib/db'
import { z } from 'zod'
import jwt from 'jsonwebtoken'
import { applyAnonymity } from '@/lib/anonymize'
import { generateTrackingCode } from '@/lib/tracking'

const schema = z.object({
  mode:           z.enum(['VICTIM', 'WITNESS']).default('VICTIM'),
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
    const trackingCode = await generateTrackingCode()

    const report = await db.report.create({
      data: {
        ...result.data,
        authorId: user.id,
        trackingCode,
      },
    })

    return new Response(JSON.stringify({ success: true, id: report.id, trackingCode: report.trackingCode }), {
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

const VALID_STATUSES  = ['PENDING', 'IN_PROGRESS', 'CLOSED'] as const
const VALID_TYPES     = ['PHYSICAL', 'VERBAL', 'SEXUAL', 'CYBER', 'OTHER'] as const

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

  // Lecture des query params optionnels
  const { searchParams } = new URL(request.url)
  const statusParam  = searchParams.get('status')
  const typeParam    = searchParams.get('type')
  const gravityParam = searchParams.get('gravity')
  const codeParam    = searchParams.get('code')

  // Validation souple : valeur inconnue = ignorée (pas d'erreur 400)
  const statusFilter  = VALID_STATUSES.includes(statusParam as never)  ? statusParam  as typeof VALID_STATUSES[number]  : undefined
  const typeFilter    = VALID_TYPES.includes(typeParam as never)        ? typeParam    as typeof VALID_TYPES[number]     : undefined
  const gravityFilter = gravityParam ? parseInt(gravityParam, 10) : undefined
  const codeFilter    = codeParam?.trim() || undefined

  try {
    const staffUser = await db.user.findUnique({
      where: { id: user.id },
      select: { schoolCode: true },
    })

    const reports = await db.report.findMany({
      where: {
        targetLevel:  user.role as 'TEACHER' | 'DIRECTOR_CPE' | 'RECTORAT',
        author:       { schoolCode: staffUser?.schoolCode ?? '' },
        // Filtres optionnels — undefined = Prisma ignore le champ
        ...(statusFilter  && { status:       statusFilter }),
        ...(typeFilter    && { type:         typeFilter }),
        ...(gravityFilter && { gravity:      gravityFilter }),
        ...(codeFilter    && { trackingCode: codeFilter }),
      },
      select: {
        id:             true,
        trackingCode:   true,
        mode:           true,
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

    const safeReports = reports.map((r) => ({
      ...r,
      author: applyAnonymity(r.author, r.anonymityLevel),
    }))

    return new Response(JSON.stringify(safeReports), {
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
