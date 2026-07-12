import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'

// ---------------------------------------------------------------------------
// GET /api/reports/mine
// Retourne la liste des signalements soumis par l'élève connecté.
// Chaque entrée contient le statut actuel et les infos de base —
// pas la description complète (évite un payload trop lourd pour une liste).
// ---------------------------------------------------------------------------
export async function GET(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Seul un STUDENT peut accéder à ses propres signalements via cette route
  if (user.role !== 'STUDENT') {
    return new Response(JSON.stringify({ error: 'Réservé aux élèves' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const reports = await db.report.findMany({
      where: {
        // Filtre strict sur l'auteur : un élève ne voit QUE ses propres signalements
        authorId: user.id,
      },
      select: {
        id:             true,
        trackingCode:   true,
        type:           true,
        gravity:        true,
        status:         true,       // état actuel du traitement
        anonymityLevel: true,
        targetLevel:    true,
        createdAt:      true,
        updatedAt:      true,
        // Compte le nombre de follow-ups pour afficher un badge "mis à jour"
        _count: {
          select: { followUps: true },
        },
      },
      orderBy: { createdAt: 'desc' }, // plus récent en premier
    })

    return new Response(JSON.stringify(reports), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/reports/mine]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
