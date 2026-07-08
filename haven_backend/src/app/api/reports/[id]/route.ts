import { db } from '@/lib/db'
import { z } from 'zod'
import { applyAnonymity } from '@/lib/anonymize'
import { requireRole, STAFF_ROLES } from '@/lib/auth'
import { rateLimit, rateLimitKeyForUser } from '@/lib/rateLimit'
import { sendPushToUsers } from '@/lib/push'

// ---------------------------------------------------------------------------
// GET /api/reports/[id]
// Retourne le détail complet d'un signalement.
// Accessible uniquement au staff du même établissement que l'auteur.
// ---------------------------------------------------------------------------
export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = requireRole(request, STAFF_ROLES)
  if (user instanceof Response) return user

  const { id } = await params

  try {
    const staffUser = user.role !== 'RECTORAT'
      ? await db.user.findUnique({ where: { id: user.id }, select: { schoolCode: true } })
      : null

    const report = await db.report.findUnique({
      where: { id },
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
        updatedAt:      true,
        author: {
          select: {
            name:       true,
            className:  true,
            schoolCode: true,
          },
        },
        followUps: {
          select: {
            id:        true,
            notes:     true,
            newStatus: true,
            createdAt: true,
            staff: {
              select: { name: true, role: true },
            },
          },
          orderBy: { createdAt: 'asc' },
        },
        // Conversation libre élève ↔ staff (distincte des follow-ups de statut).
        messages: {
          select: {
            id:         true,
            body:       true,
            senderRole: true,
            createdAt:  true,
          },
          orderBy: { createdAt: 'asc' },
        },
      },
    })

    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const { schoolCode: authorSchoolCode, ...authorForResponse } = report.author
    if (staffUser && authorSchoolCode !== staffUser.schoolCode) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Le signalement doit être destiné au rôle de l'agent qui le consulte —
    // un TEACHER ne doit pas lire un signalement adressé au DIRECTOR_CPE, etc.
    if (report.targetLevel !== user.role) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const safeReport = {
      ...report,
      author: applyAnonymity(authorForResponse, report.anonymityLevel),
    }

    return new Response(JSON.stringify(safeReport), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/reports/:id]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}

// ---------------------------------------------------------------------------
// Validation du body pour PATCH
// notes est optionnel : le staff peut changer le statut sans ajouter de commentaire
// ---------------------------------------------------------------------------
const patchSchema = z.object({
  status: z.enum(['IN_PROGRESS', 'CLOSED']),
  notes:  z.string().max(500).optional(),
})

// ---------------------------------------------------------------------------
// PATCH /api/reports/[id]
// Change le statut d'un signalement et crée un FollowUp (entrée d'historique).
// Accessible uniquement au staff du même établissement.
// On ne peut pas repasser un signalement en PENDING une fois traité.
// ---------------------------------------------------------------------------
// Le RECTORAT ne modifie jamais directement un statut — il ne fait que recevoir
// des signalements escaladés (voir escalate/route.ts).
const PATCH_ROLES = ['TEACHER', 'DIRECTOR_CPE'] as const

// Cf. rapport_bugs.md S13. Budget plus large que la messagerie : un membre du
// staff peut légitimement traiter beaucoup de signalements dans une session.
const STATUS_LIMIT = 30
const STATUS_WINDOW_MS = 5 * 60 * 1000

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = requireRole(request, PATCH_ROLES)
  if (user instanceof Response) return user

  const { allowed, retryAfterSeconds } = rateLimit(
    rateLimitKeyForUser(user.id, 'report-status'), STATUS_LIMIT, STATUS_WINDOW_MS
  )
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de mises à jour. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { 'Content-Type': 'application/json', 'Retry-After': String(retryAfterSeconds) } }
    )
  }

  const body = await request.json()
  const result = patchSchema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { id } = await params
  const { status, notes } = result.data

  try {
    const staffUser = user.role !== 'RECTORAT'
      ? await db.user.findUnique({ where: { id: user.id }, select: { schoolCode: true } })
      : null

    const report = await db.report.findUnique({
      where: { id },
      select: {
        status:      true,
        authorId:    true,
        targetLevel: true,
        author: { select: { schoolCode: true } },
      },
    })

    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    if (staffUser && report.author.schoolCode !== staffUser.schoolCode) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Le signalement doit être destiné au rôle de l'agent — un TEACHER ne peut pas
    // modifier le statut d'un signalement adressé au DIRECTOR_CPE, et inversement.
    if (report.targetLevel !== user.role) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Un signalement CLOSED est définitif : on ne peut plus le modifier
    if (report.status === 'CLOSED') {
      return new Response(JSON.stringify({ error: 'Ce signalement est déjà clôturé.' }), {
        status: 409,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Transaction : mise à jour du statut + création du FollowUp en une seule opération atomique.
    // Si l'une échoue, l'autre est annulée — on ne se retrouve jamais avec un statut
    // changé sans entrée d'historique, ni l'inverse.
    const statusLabel = status === 'IN_PROGRESS' ? 'En cours' : 'Clôturé'

    const [updatedReport] = await db.$transaction([
      db.report.update({
        where: { id },
        data:  { status },
        select: { id: true, status: true, updatedAt: true },
      }),
      db.followUp.create({
        data: {
          reportId:  id,
          staffId:   user.id,
          newStatus: status,
          notes: notes ?? `Statut changé en ${statusLabel}`,
        },
      }),
      db.notification.create({
        data: {
          userId:   report.authorId,
          reportId: id,
          message:  `Ton signalement a été mis à jour — statut : ${statusLabel}.`,
        },
      }),
    ])

    sendPushToUsers(
      [report.authorId],
      'Signalement mis à jour',
      `Ton signalement a été mis à jour — statut : ${statusLabel}.`
    ).catch((err) => console.error('[PATCH /api/reports/:id] push error', err))

    return new Response(JSON.stringify({ success: true, report: updatedReport }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[PATCH /api/reports/:id]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
