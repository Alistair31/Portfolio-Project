import { z } from "zod"
import { db } from "@/lib/db"
import bcrypt from "bcryptjs"
import { rateLimit, rateLimitKey } from "@/lib/rateLimit"
import { signAccessToken, generateRefreshToken } from "@/lib/auth"

const DUMMY_HASH = "$2b$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345"

// 5 tentatives / 15 min / IP : assez large pour un utilisateur qui se trompe,
// assez strict pour ralentir un brute-force sur un mot de passe.
const LOGIN_LIMIT = 5
const LOGIN_WINDOW_MS = 15 * 60 * 1000

export async function POST(request: Request) {
  const { allowed, retryAfterSeconds } = rateLimit(rateLimitKey(request, "login"), LOGIN_LIMIT, LOGIN_WINDOW_MS)
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de tentatives. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { "Content-Type": "application/json", "Retry-After": String(retryAfterSeconds) } }
    )
  }

  const body = await request.json()
  const schema = z.object({
    email: z.string().email().max(100),
    password: z.string().min(6).max(100),
  })

  if (!process.env.JWT_SECRET) throw new Error("JWT_SECRET is not defined")

  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? 'Données invalides.' }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }
  const { email, password } = result.data

  try {
    const user = await db.user.findUnique({ where: { email } })

    // Always run bcrypt to prevent timing-based enumeration
    const isPasswordValid = await bcrypt.compare(password, user?.passwordHash ?? DUMMY_HASH)

    if (!user || !isPasswordValid) {
      return new Response(JSON.stringify({ error: "Invalid email or password" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      })
    }

    const token = signAccessToken({ id: user.id, role: user.role })

    const { token: refreshToken, hash, expiresAt } = generateRefreshToken()
    await db.refreshToken.create({
      data: { userId: user.id, tokenHash: hash, expiresAt },
    })

    return new Response(
      JSON.stringify({ token, refreshToken, user: { id: user.id, name: user.name, role: user.role } }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: "Database error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
}
