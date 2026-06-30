import { z } from 'zod'
import { db } from '@/lib/db'
import bcrypt from 'bcryptjs'

const schema = z.object({
  email:      z.string().email().max(100),
  password:   z.string().min(8).max(100),
  name:       z.string().min(2).max(50),
  parentCode: z.string().regex(/^HVN-P-[A-Z0-9]{6}$/, 'Code parent invalide.'),
})

// POST /api/auth/register/parent
// Crée un compte parent et le lie à l'élève via son parentCode.
export async function POST(request: Request) {
  const body = await request.json()
  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { email, password, name, parentCode } = result.data

  try {
    const student = await db.user.findUnique({
      where: { parentCode },
      select: { id: true, role: true },
    })

    if (!student || student.role !== 'STUDENT') {
      return new Response(JSON.stringify({ error: 'Code parent invalide ou inconnu.' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const existing = await db.user.findUnique({ where: { email } })
    if (existing) {
      return new Response(JSON.stringify({ error: 'Un compte existe déjà avec cet email.' }), {
        status: 409,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const passwordHash = await bcrypt.hash(password, 10)

    const parent = await db.user.create({
      data: {
        email,
        passwordHash,
        name,
        role:      'PARENT',
        className: '',
        schoolCode: '',
      },
      select: { id: true },
    })

    await db.parentStudentLink.create({
      data: { parentId: parent.id, studentId: student.id },
    })

    return new Response(JSON.stringify({ message: 'Compte parent créé.' }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[POST /api/auth/register/parent]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
