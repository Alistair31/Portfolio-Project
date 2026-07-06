import { db } from '@/lib/db'
import { z } from 'zod'
import { extractUser } from '@/lib/auth'
import { sendPushToUsers } from '@/lib/push'

// ---------------------------------------------------------------------------
// POST /api/reports/mine/[id]/messages
// L'élève auteur envoie un message libre au staff sur SON signalement.
// (Le pendant staff est POST /api/reports/[id]/messages.)
// ---------------------------------------------------------------------------
const schema = z.object({
  body: z.string().trim().min(1, 'Message vide.').max(1000, 'Message trop long (1000 caractères max).'),
})

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

  if (user.role !== 'STUDENT') {
    return new Response(JSON.stringify({ error: 'Réservé aux élèves' }), {
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

  const { id } = await params

  try {
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

    // Un élève ne peut écrire que sur SES propres signalements.
    if (report.authorId !== user.id) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const message = await db.message.create({
      data: {
        reportId:   id,
        senderId:   user.id,
        senderRole: 'STUDENT',
        body:       result.data.body,
      },
      select: { id: true, body: true, senderRole: true, createdAt: true },
    })

    // Notifie le staff ciblé (même rôle, même école). Non-bloquant : l'envoi
    // du message réussit même si les notifications échouent.
    db.user.findMany({
      where: { role: report.targetLevel, schoolCode: report.author.schoolCode },
      select: { id: true },
    }).then(async (staffList) => {
      if (staffList.length === 0) return
      const notifMessage = 'Nouveau message d\'un élève sur un signalement.'
      await db.notification.createMany({
        data: staffList.map((s) => ({ userId: s.id, reportId: id, message: notifMessage })),
      })
      await sendPushToUsers(staffList.map((s) => s.id), 'Nouveau message', notifMessage)
    }).catch((err) => console.error('[POST /api/reports/mine/:id/messages] notification error', err))

    return new Response(JSON.stringify(message), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[POST /api/reports/mine/:id/messages]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
