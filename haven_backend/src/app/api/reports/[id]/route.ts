import { db } from '@/lib/db'
import { z } from 'zod'
import jwt from 'jsonwebtoken'
import { applyAnonymity } from '@/lib/anonymize'

// ---------------------------------------------------------------------------
// Utilitaire partagé : extraire et vérifier le JWT depuis le header
// Retourne { id, role } ou null si le token est absent/invalide
// ---------------------------------------------------------------------------
function extractUser(request: Request): { id: string; role: string } | null {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) return null
  try {
    const token = authHeader.split(' ')[1]
    return jwt.verify(token, process.env.JWT_SECRET!) as { id: string; role: string }
  } catch {
    return null
  }
}

// Rôles autorisés à consulter et modifier les signalements
const STAFF_ROLES = ['TEACHER', 'DIRECTOR_CPE', 'RECTORAT']

// ---------------------------------------------------------------------------
// GET /api/reports/[id]
// Retourne le détail complet d'un signalement.
// Accessible uniquement au staff du même établissement que l'auteur.
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

  if (!STAFF_ROLES.includes(user.role)) {
    return new Response(JSON.stringify({ error: 'Accès refusé' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // params est une Promise en Next.js 15 : on doit l'awaiter
  const { id } = await params

  try {
    // On récupère le schoolCode du staff connecté pour vérifier qu'il appartient
    // au même établissement que l'auteur du signalement
    const staffUser = await db.user.findUnique({
      where: { id: user.id },
      select: { schoolCode: true },
    })

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
        // Historique des actions sur ce signalement (changements de statut + notes)
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
      },
    })

    // Signalement introuvable
    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Vérification inter-établissement : un prof du lycée A ne peut pas voir
    // les signalements du lycée B
    if (report.author.schoolCode !== staffUser?.schoolCode) {
      return new Response(JSON.stringify({ error: 'Accès refusé' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const safeReport = {
      ...report,
      author: applyAnonymity(report.author, report.anonymityLevel),
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
export async function PATCH(
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

  if (!STAFF_ROLES.includes(user.role)) {
    return new Response(JSON.stringify({ error: 'Accès refusé' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const body = await request.json()
  const result = patchSchema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { id } = await params
  const { status, notes } = result.data

  try {
    const staffUser = await db.user.findUnique({
      where: { id: user.id },
      select: { schoolCode: true },
    })

    // Vérifie que le signalement existe et appartient au bon établissement
    const report = await db.report.findUnique({
      where: { id },
      select: {
        status: true,
        author: { select: { schoolCode: true } },
      },
    })

    if (!report) {
      return new Response(JSON.stringify({ error: 'Signalement introuvable' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    if (report.author.schoolCode !== staffUser?.schoolCode) {
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
          // Si notes est absent, on génère un message par défaut lisible
          notes: notes ?? `Statut changé en ${status === 'IN_PROGRESS' ? 'En cours' : 'Clôturé'}`,
        },
      }),
    ])

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
