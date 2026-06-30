import { z } from "zod"
import { db } from "@/lib/db"
import { hashRefreshToken } from "@/lib/auth"

const schema = z.object({ refreshToken: z.string().min(1) })

// POST /api/auth/logout
// body: { refreshToken: string }
// Révoque le refresh token côté serveur. L'access token (courte durée de vie)
// continue d'exister jusqu'à expiration naturelle (max 15 min) mais ne pourra
// plus être renouvelé : c'est une déconnexion "best effort", pas instantanée
// sur tous les fronts, ce qui est un compromis acceptable vu la durée de vie
// courte du token d'accès.
export async function POST(request: Request) {
  const body = await request.json().catch(() => null)
  const result = schema.safeParse(body)
  if (!result.success) {
    // Pas de refresh token fourni (ex: session déjà locale uniquement) : on
    // répond simplement 200, il n'y a rien à révoquer côté serveur.
    return new Response(JSON.stringify({ message: "Déconnecté." }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })
  }

  const hash = hashRefreshToken(result.data.refreshToken)
  await db.refreshToken.updateMany({
    where: { tokenHash: hash, revokedAt: null },
    data: { revokedAt: new Date() },
  })

  return new Response(JSON.stringify({ message: "Déconnecté." }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  })
}
