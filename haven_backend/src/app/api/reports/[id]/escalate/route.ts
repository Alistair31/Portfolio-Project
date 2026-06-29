import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'
import { z } from 'zod'

const schema = z.object({
  notes: z.string().max(500).optional(),
})

const ESCALABLE_ROLES = ['TEACHER', 'DIRECTOR_CPE'] as const

// ---------------------------------------------------------------------------
// POST /api/reports/[id]/escalate
// Transfère un signalement au niveau Rectorat.
// Réservé aux TEACHER et DIRECTOR_CPE — le Rectorat est déjà au sommet.
// Le signalement doit cibler le rôle de l'appelant pour qu'il puisse le transférer.
// ---------------------------------------------------------------------------
export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  if (!ESCALABLE_ROLES.includes(user.role as (typeof ESCALABLE_ROLES)[number])) {
    return new Response(
      JSON.stringify({ error: 'Seuls les professeurs et directeurs peuvent transférer au Rectorat.' }),
      { status: 403, headers: { 'Content-Type': 'application/json' } }
    )
  }

  const body = await request.json().catch(() => ({}))
  const { notes } = schema.parse(body)

  const { id } = await params

  try {
    const [staffUser, report] = await Promise.all([
      db.user.findUnique({ where: { id: user.id }, select: { schoolCode: true } }),
      db.report.findUnique({
        where: { id },
        select: { targetLevel: true, status: true, authorId: true, author: { select: { schoolCode: true } } },
      }),
    ])

    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable.' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Vérification d'appartenance à l'école
    if (report.author.schoolCode !== staffUser?.schoolCode) {
      return new Response(JSON.stringify({ error: 'Accès refusé.' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Le signalement doit cibler le rôle de l'appelant (pas un autre niveau)
    if (report.targetLevel !== user.role) {
      return new Response(
        JSON.stringify({ error: 'Ce signalement ne vous est pas destiné.' }),
        { status: 409, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Déjà au niveau Rectorat
    if (report.targetLevel === 'RECTORAT') {
      return new Response(
        JSON.stringify({ error: 'Ce signalement est déjà au niveau Rectorat.' }),
        { status: 409, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const escalationNote = notes ?? 'Signalement transféré au Rectorat.'

    // Transaction : mise à jour targetLevel + création du FollowUp
    await db.$transaction([
      db.report.update({
        where: { id },
        data:  { targetLevel: 'RECTORAT' },
      }),
      db.followUp.create({
        data: {
          reportId:  id,
          staffId:   user.id,
          newStatus: report.status,
          notes:     escalationNote,
        },
      }),
    ])

    // Notifie le Rectorat (non-bloquant)
    db.user.findMany({
      where: { role: 'RECTORAT', schoolCode: staffUser?.schoolCode ?? '' },
      select: { id: true },
    }).then((rectoratUsers) => {
      if (rectoratUsers.length === 0) return
      return db.notification.createMany({
        data: rectoratUsers.map((r) => ({
          userId:   r.id,
          reportId: id,
          message:  'Un signalement vous a été transféré par un membre du staff.',
        })),
      })
    }).catch((err) => console.error('[POST /api/reports/:id/escalate] notification error', err))

    // Notifie l'élève auteur
    db.notification.create({
      data: {
        userId:   report.authorId,
        reportId: id,
        message:  'Ton signalement a été transmis au Rectorat.',
      },
    }).catch((err) => console.error('[POST /api/reports/:id/escalate] author notification error', err))

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('[POST /api/reports/:id/escalate]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
