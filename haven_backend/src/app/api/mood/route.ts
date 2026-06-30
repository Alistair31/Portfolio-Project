import { db } from '@/lib/db'
import { z } from 'zod'
import { extractUser } from '@/lib/auth'

const moodSchema = z.object({
  level: z.number().int().min(1).max(5),
})

// ---------------------------------------------------------------------------
// POST /api/mood
// Enregistre un check-in émotionnel pour l'élève connecté.
// Plusieurs check-ins par jour sont autorisés pour permettre les courbes.
// ---------------------------------------------------------------------------
export async function POST(request: Request) {
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
  const result = moodSchema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const mood = await db.mood.create({
      data: {
        level:  result.data.level,
        userId: user.id,
      },
      select: { id: true, level: true, createdAt: true },
    })

    return new Response(JSON.stringify({ success: true, mood }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[POST /api/mood]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}

// ---------------------------------------------------------------------------
// GET /api/mood
// Retourne les check-ins des 7 derniers jours de l'élève connecté.
// Paramètre optionnel ?days=N pour ajuster la fenêtre (max 90).
// ---------------------------------------------------------------------------
export async function GET(request: Request) {
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

  const { searchParams } = new URL(request.url)
  const daysParam = parseInt(searchParams.get('days') ?? '7', 10)
  const days = Math.min(Math.max(daysParam, 1), 90)

  const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000)

  try {
    const moods = await db.mood.findMany({
      where: {
        userId:    user.id,
        createdAt: { gte: since },
      },
      select: { id: true, level: true, createdAt: true },
      orderBy: { createdAt: 'asc' },
    })

    return new Response(JSON.stringify(moods), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/mood]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
