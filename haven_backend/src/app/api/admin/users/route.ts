import { db } from '@/lib/db'
import { z } from 'zod'
import bcrypt from 'bcryptjs'
import { timingSafeEqual } from 'crypto'

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

// ---------------------------------------------------------------------------
// Vérification du token admin
// Cette route est protégée par un secret statique (ADMIN_SECRET dans .env),
// différent du JWT utilisateur. Elle n'est jamais appelée depuis l'app mobile —
// uniquement par l'administrateur système (curl, Postman, script CI).
// ---------------------------------------------------------------------------
function isAdmin(request: Request): boolean {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ') || !process.env.ADMIN_SECRET) return false

  const token = authHeader.split(' ')[1]
  // Comparaison à temps constant : évite de révéler le secret via le temps de réponse
  const tokenBuf  = Buffer.from(token)
  const secretBuf = Buffer.from(process.env.ADMIN_SECRET)
  if (tokenBuf.length !== secretBuf.length) return false
  return timingSafeEqual(tokenBuf, secretBuf)
}

// ---------------------------------------------------------------------------
// POST /api/admin/users
// Crée un compte staff (TEACHER, DIRECTOR_CPE ou RECTORAT).
// Protégé par ADMIN_SECRET — ne jamais exposer publiquement.
// ---------------------------------------------------------------------------
export async function POST(request: Request) {
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
