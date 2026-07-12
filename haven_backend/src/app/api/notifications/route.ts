import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'

// ---------------------------------------------------------------------------
// GET /api/notifications
// Retourne les notifications de l'utilisateur connecté, les plus récentes d'abord.
// Inclut le nombre de non-lues dans le champ `unreadCount`.
// ---------------------------------------------------------------------------
export async function GET(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const [notifications, unreadCount] = await db.$transaction([
      db.notification.findMany({
        where: { userId: user.id },
        select: {
          id:      true,
          message: true,
          read:    true,
          sentAt:  true,
          reportId: true,
        },
        orderBy: { sentAt: 'desc' },
      }),
      db.notification.count({
        where: { userId: user.id, read: false },
      }),
    ])

    return new Response(
      JSON.stringify({ notifications, unreadCount }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    console.error('[GET /api/notifications]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}

// ---------------------------------------------------------------------------
// PATCH /api/notifications
// Marque toutes les notifications non-lues de l'utilisateur comme lues.
// Retourne le nombre de notifications mises à jour.
// ---------------------------------------------------------------------------
export async function PATCH(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const { count } = await db.notification.updateMany({
      where: { userId: user.id, read: false },
      data:  { read: true },
    })

    return new Response(
      JSON.stringify({ success: true, count }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    console.error('[PATCH /api/notifications]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
