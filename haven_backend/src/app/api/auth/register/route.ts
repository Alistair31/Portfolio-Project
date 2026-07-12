import { z } from "zod"
import { db } from "@/lib/db"
import bcrypt from "bcryptjs"
import { rateLimit, rateLimitKey } from "@/lib/rateLimit"

function generateParentCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let code = 'HVN-P-'
  for (let i = 0; i < 6; i++) code += chars[Math.floor(Math.random() * chars.length)]
  return code
}

// 10 créations / heure / IP : limite le spam de comptes sans gêner une classe
// entière qui s'inscrit depuis le même établissement (NAT/Wi-Fi partagé).
const REGISTER_LIMIT = 10
const REGISTER_WINDOW_MS = 60 * 60 * 1000

export async function POST(request: Request) {
  const { allowed, retryAfterSeconds } = rateLimit(rateLimitKey(request, "register"), REGISTER_LIMIT, REGISTER_WINDOW_MS)
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de tentatives. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { "Content-Type": "application/json", "Retry-After": String(retryAfterSeconds) } }
    )
  }

  const body = await request.json()

  const schema = z.object({
    email: z.string().email().max(100),
    password: z.string().min(8).max(100),
    name: z.string().min(2).max(50),
    className: z.string().min(1).max(50),
    schoolCode: z.string().min(1).max(50),
  })

  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  const { email, password, name, className, schoolCode } = result.data

  try {
    const school = await db.school.findUnique({ where: { code: schoolCode } })
    if (!school) {
      return new Response(
        JSON.stringify({ error: "Code établissement invalide." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }

    // Always hash first to prevent timing-based email enumeration
    const hashedPassword = await bcrypt.hash(password, 10)
    const existingUser = await db.user.findUnique({ where: { email } })
    if (!existingUser) {
      let parentCode = generateParentCode()
      while (await db.user.findUnique({ where: { parentCode } })) {
        parentCode = generateParentCode()
      }
      await db.user.create({
        data: { email, passwordHash: hashedPassword, name, className, schoolCode, role: "STUDENT", parentCode },
      })
    }
    return new Response(
      JSON.stringify({ message: "Si cet email n'est pas enregistré, un compte a été créé." }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: "Database error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
}