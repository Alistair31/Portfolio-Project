import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'

export async function DELETE(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const existing = await db.accountDeletionRequest.findFirst({
    where: { userId: user.id, status: 'PENDING' },
  })
  if (existing) {
    return new Response(
      JSON.stringify({ error: 'Une demande de suppression est déjà en attente.' }),
      { status: 409, headers: { 'Content-Type': 'application/json' } }
    )
  }

  await db.accountDeletionRequest.create({
    data: { userId: user.id },
  })

  return new Response(
    JSON.stringify({ message: 'Demande envoyée. Un administrateur traitera votre demande.' }),
    { status: 202, headers: { 'Content-Type': 'application/json' } }
  )
}
