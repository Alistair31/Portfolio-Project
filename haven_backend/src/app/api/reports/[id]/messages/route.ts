import { db } from '@/lib/db'
import { z } from 'zod'
import { requireRole, STAFF_ROLES } from '@/lib/auth'
import { rateLimit, rateLimitKeyForUser } from '@/lib/rateLimit'
import { sendPushToUsers } from '@/lib/push'

// ---------------------------------------------------------------------------
// POST /api/reports/[id]/messages
// Un membre du staff répond librement à l'élève sur un signalement.
// Même contrôle d'accès que GET /api/reports/[id] : même établissement (sauf
// RECTORAT) et le signalement doit être destiné au rôle de l'agent.
// ---------------------------------------------------------------------------
const schema = z.object({
  body: z.string().trim().min(1, 'Message vide.').max(1000, 'Message trop long (1000 caractères max).'),
})

// Cf. rapport_bugs.md S13 — même protection anti-spam que le pendant élève.
const MESSAGE_LIMIT = 20
const MESSAGE_WINDOW_MS = 5 * 60 * 1000

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = requireRole(request, STAFF_ROLES)
  if (user instanceof Response) return user

  const { allowed, retryAfterSeconds } = rateLimit(
    rateLimitKeyForUser(user.id, 'report-message'), MESSAGE_LIMIT, MESSAGE_WINDOW_MS
  )
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de messages envoyés. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { 'Content-Type': 'application/json', 'Retry-After': String(retryAfterSeconds) } }
    )
  }

  const body = await request.json()
  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { id } = await params

  try {
    const staffUser = user.role !== 'RECTORAT'
      ? await db.user.findUnique({ where: { id: user.id }, select: { schoolCode: true } })
      : null

    const report = await db.report.findUnique({
      where: { id },
      select: {
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

    // Cloisonnement par établissement (le RECTORAT voit toutes les écoles).
    if (staffUser && report.author.schoolCode !== staffUser.schoolCode) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Le signalement doit être destiné au rôle de l'agent qui répond.
    if (report.targetLevel !== user.role) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const message = await db.message.create({
      data: {
        reportId:   id,
        senderId:   user.id,
        senderRole: user.role as 'TEACHER' | 'DIRECTOR_CPE' | 'RECTORAT',
        body:       result.data.body,
      },
      select: { id: true, body: true, senderRole: true, createdAt: true },
    })

    // Notifie l'élève auteur. Non-bloquant.
    const notifMessage = 'L\'équipe t\'a répondu sur ton signalement.'
    db.notification.create({
      data: { userId: report.authorId, reportId: id, message: notifMessage },
    })
      .then(() => sendPushToUsers([report.authorId], 'Nouvelle réponse', notifMessage))
      .catch((err) => console.error('[POST /api/reports/:id/messages] notification error', err))

    return new Response(JSON.stringify(message), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[POST /api/reports/:id/messages]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
