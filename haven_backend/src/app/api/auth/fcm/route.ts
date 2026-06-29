import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'
import { z } from 'zod'

const schema = z.object({
  fcmToken: z.string().min(1).max(500),
})

// ---------------------------------------------------------------------------
// PATCH /api/auth/fcm
// Enregistre ou met à jour le token FCM de l'utilisateur connecté.
// Appelé au démarrage de l'app dès que Firebase fournit un token.
// ---------------------------------------------------------------------------
export async function PATCH(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
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
    await db.user.update({
      where: { id: user.id },
      data:  { fcmToken: result.data.fcmToken },
    })

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    console.error('[PATCH /api/auth/fcm]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
