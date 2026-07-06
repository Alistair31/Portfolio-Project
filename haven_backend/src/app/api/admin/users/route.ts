import { db } from '@/lib/db'
import { z } from 'zod'
import bcrypt from 'bcryptjs'
import { isAdmin } from '@/lib/adminAuth'
import { rateLimit, rateLimitKey } from '@/lib/rateLimit'

// ---------------------------------------------------------------------------
// Validation du body
// Le rôle est restreint au staff : un STUDENT n'a rien à faire ici.
// ---------------------------------------------------------------------------
const schema = z.object({
  name:       z.string().min(2).max(100),
  email:      z.string().email().max(100),
  password:   z.string().min(8).max(100),
  role:       z.enum(['TEACHER', 'DIRECTOR_CPE', 'RECTORAT']),
  schoolCode: z.string().min(1),
})

// Même budget que /auth/login : ADMIN_SECRET est un secret statique unique,
// sans limite il serait brute-forçable en continu.
const ADMIN_LIMIT = 10
const ADMIN_WINDOW_MS = 15 * 60 * 1000

// ---------------------------------------------------------------------------
// POST /api/admin/users
// Crée un compte staff (TEACHER, DIRECTOR_CPE ou RECTORAT).
// Protégé par ADMIN_SECRET — ne jamais exposer publiquement.
// ---------------------------------------------------------------------------
export async function POST(request: Request) {
  const { allowed, retryAfterSeconds } = rateLimit(rateLimitKey(request, 'admin'), ADMIN_LIMIT, ADMIN_WINDOW_MS)
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de tentatives. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { 'Content-Type': 'application/json', 'Retry-After': String(retryAfterSeconds) } }
    )
  }

  // Refus immédiat si le secret est absent ou incorrect
  if (!isAdmin(request)) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
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

  const { name, email, password, role, schoolCode } = result.data

  // Vérifie que l'établissement existe avant de créer l'utilisateur
  const school = await db.school.findUnique({ where: { code: schoolCode } })
  if (!school) {
    return new Response(JSON.stringify({ error: 'Code établissement invalide.' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Vérifie qu'aucun compte n'existe déjà avec cet email
  const existing = await db.user.findUnique({ where: { email } })
  if (existing) {
    return new Response(JSON.stringify({ error: 'Un compte existe déjà avec cet email.' }), {
      status: 409, // 409 Conflict : ressource déjà existante
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Hachage du mot de passe avant stockage
  const passwordHash = await bcrypt.hash(password, 10)

  try {
    const user = await db.user.create({
      data: {
        name,
        email,
        passwordHash,
        role,
        schoolCode,
        className: '', // non applicable pour le staff
      },
      // On ne retourne jamais le passwordHash au client
      select: { id: true, name: true, email: true, role: true, schoolCode: true },
    })

    return new Response(JSON.stringify({ success: true, user }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[POST /api/admin/users]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
