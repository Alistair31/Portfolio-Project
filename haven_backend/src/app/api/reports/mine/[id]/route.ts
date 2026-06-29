import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'

// ---------------------------------------------------------------------------
// GET /api/reports/mine/[id]
// Détail complet d'un signalement de l'élève connecté.
// Inclut la timeline des follow-ups (notes du staff + changements de statut).
//
// Note : les notes du staff sont visibles même en mode anonyme pour l'instant —
// décision de garder la transparence côté élève. À revoir si besoin.
// ---------------------------------------------------------------------------
export async function GET(
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

  const { id } = await params

  try {
    const report = await db.report.findUnique({
      where: { id },
      select: {
        id:             true,
        type:           true,
        gravity:        true,
        description:    true,
        status:         true,
        anonymityLevel: true,
        targetLevel:    true,
        createdAt:      true,
        updatedAt:      true,
        // authorId inclus uniquement pour la vérification d'appartenance ci-dessous,
        // il ne sera pas envoyé au client (on le retire avant la réponse)
        authorId:       true,
        // Timeline des actions effectuées par le staff sur ce signalement
        followUps: {
          select: {
            id:        true,
            notes:     true,     // notes du staff — gardées visibles pour l'instant
            newStatus: true,
            createdAt: true,
            // On expose le rôle du staff mais pas son nom (préserve l'anonymat du côté staff)
            staff: {
              select: { role: true },
            },
          },
          orderBy: { createdAt: 'asc' }, // chronologique : du plus vieux au plus récent
        },
      },
    })

    // Signalement introuvable en base
    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Vérification d'appartenance : un élève ne peut voir que SES propres signalements.
    // Même s'il connaît l'id d'un signalement d'un autre élève, il est rejeté.
    if (report.authorId !== user.id) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // On retire authorId de la réponse : l'élève n'a pas besoin de son propre id
    const { authorId: _, ...safeReport } = report

    return new Response(JSON.stringify(safeReport), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/reports/mine/:id]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}

// ---------------------------------------------------------------------------
// DELETE /api/reports/mine/[id]
// Annulation d'un signalement dans les 5 minutes suivant sa création.
// Passé ce délai, le signalement est définitif (obligation de traitement — CDC §7).
// ---------------------------------------------------------------------------
export async function DELETE(
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

  const { id } = await params

  try {
    const report = await db.report.findUnique({
      where: { id },
      select: { authorId: true, createdAt: true },
    })

    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    if (report.authorId !== user.id) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const FIVE_MINUTES = 5 * 60 * 1000
    const elapsed = Date.now() - report.createdAt.getTime()
    if (elapsed > FIVE_MINUTES) {
      return new Response(
        JSON.stringify({ error: 'Le délai d\'annulation de 5 minutes est dépassé.' }),
        { status: 409, headers: { 'Content-Type': 'application/json' } }
      )
    }

    await db.report.delete({ where: { id } })

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[DELETE /api/reports/mine/:id]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
