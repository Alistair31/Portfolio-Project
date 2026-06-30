import { db } from '@/lib/db'
import { z } from 'zod'
import { applyAnonymity } from '@/lib/anonymize'
import { generateTrackingCode } from '@/lib/tracking'
import { computeIntegrityHash } from '@/lib/integrity'
import { extractUser } from '@/lib/auth'

const schema = z.object({
  mode:           z.enum(['VICTIM', 'WITNESS']).default('VICTIM'),
  type:           z.enum(['PHYSICAL', 'VERBAL', 'SEXUAL', 'CYBER', 'OTHER']),
  gravity:        z.number().int().min(1).max(5),
  description:    z.string().min(10).max(1000),
  targetLevel:    z.enum(['TEACHER', 'DIRECTOR_CPE', 'RECTORAT']),
  anonymityLevel: z.enum(['NONE', 'NAME_HIDDEN', 'NAME_AND_CLASS_HIDDEN', 'FULLY_ANONYMOUS']),
})

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
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const author = await db.user.findUnique({
      where: { id: user.id },
      select: { schoolCode: true },
    })

    const trackingCode = await generateTrackingCode()

    const report = await db.report.create({
      data: {
        ...result.data,
        authorId: user.id,
        trackingCode,
      },
    })

    const integrityHash = computeIntegrityHash(report)
    await db.report.update({
      where: { id: report.id },
      data:  { integrityHash },
    })

    // Notifie tous les membres du staff ciblés (même rôle, même école)
    // Erreur non-bloquante : la soumission réussit même si les notifs échouent
    db.user.findMany({
      where: { role: result.data.targetLevel, schoolCode: author?.schoolCode ?? '' },
      select: { id: true },
    }).then((staffList) => {
      if (staffList.length === 0) return
      return db.notification.createMany({
        data: staffList.map((s) => ({
          userId:   s.id,
          reportId: report.id,
          message:  `Nouveau signalement reçu — gravité ${report.gravity}/5.`,
        })),
      })
    }).catch((err) => console.error('[POST /api/reports] notification error', err))

    return new Response(JSON.stringify({ success: true, id: report.id, trackingCode: report.trackingCode, integrityHash }), {
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
    // Le Rectorat voit tous les signalements qui lui sont destinés, toutes écoles confondues.
    // Les autres rôles sont limités à leur propre établissement.
    const staffUser = user.role !== 'RECTORAT'
      ? await db.user.findUnique({ where: { id: user.id }, select: { schoolCode: true } })
      : null

    const reports = await db.report.findMany({
      where: {
        targetLevel: user.role as 'TEACHER' | 'DIRECTOR_CPE' | 'RECTORAT',
        ...(staffUser && { author: { schoolCode: staffUser.schoolCode } }),
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
        // description retiré : ce champ (jusqu'à 1000 caractères de contenu sensible)
        // n'est exposé que dans le détail GET /api/reports/[id], pas dans la liste.
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
