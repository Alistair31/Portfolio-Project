import { z } from "zod"
import { db } from "@/lib/db"
import { signAccessToken, generateRefreshToken, hashRefreshToken } from "@/lib/auth"
import { rateLimit, rateLimitKey } from "@/lib/rateLimit"

const schema = z.object({ refreshToken: z.string().min(1) })

// 20 / 5 min / IP : largement assez pour un client légitime (un refresh toutes
// les ~15 min), assez strict pour empêcher un brute-force sur les tokens.
const REFRESH_LIMIT = 20
const REFRESH_WINDOW_MS = 5 * 60 * 1000

// POST /api/auth/refresh
// body: { refreshToken: string }
// Échange un refresh token valide contre un nouveau couple access+refresh.
// Rotation : l'ancien refresh token est révoqué dès qu'il est utilisé, donc un
// vol de token détecté côté serveur (réutilisation d'un token révoqué) peut
// servir de signal d'alerte plus tard si besoin.
export async function POST(request: Request) {
  const { allowed, retryAfterSeconds } = rateLimit(rateLimitKey(request, "refresh"), REFRESH_LIMIT, REFRESH_WINDOW_MS)
  if (!allowed) {
    return new Response(
      JSON.stringify({ error: `Trop de tentatives. Réessaie dans ${retryAfterSeconds}s.` }),
      { status: 429, headers: { "Content-Type": "application/json", "Retry-After": String(retryAfterSeconds) } }
    )
  }

  const body = await request.json()
  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues[0]?.message ?? "Données invalides." }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  const hash = hashRefreshToken(result.data.refreshToken)
  const stored = await db.refreshToken.findUnique({ where: { tokenHash: hash }, include: { user: true } })

  if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
    return new Response(JSON.stringify({ error: "Session expirée, reconnecte-toi." }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    })
  }

  const accessToken = signAccessToken({ id: stored.user.id, role: stored.user.role })
  const { token: newRefreshToken, hash: newHash, expiresAt } = generateRefreshToken()

  await db.$transaction([
    db.refreshToken.update({ where: { id: stored.id }, data: { revokedAt: new Date() } }),
    db.refreshToken.create({ data: { userId: stored.user.id, tokenHash: newHash, expiresAt } }),
  ])

  return new Response(
    JSON.stringify({ token: accessToken, refreshToken: newRefreshToken }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
