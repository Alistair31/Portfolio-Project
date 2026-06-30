import jwt from 'jsonwebtoken'
import crypto from 'crypto'

export function extractUser(request: Request): { id: string; role: string } | null {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) return null
  try {
    const token = authHeader.split(' ')[1]
    return jwt.verify(token, process.env.JWT_SECRET!) as { id: string; role: string }
  } catch {
    return null
  }
}

// Le token d'accès est court-vécu (1h) : s'il fuite, la fenêtre d'exploitation
// est réduite par rapport à l'ancien JWT 7j. Le client le renouvelle via
// /api/auth/refresh sans redemander le mot de passe. 1h plutôt que 15 min car
// l'app Flutter n'a pas encore de rafraîchissement automatique sur 401 (voir
// note dans api_service.dart) — en dessous de ~1h l'utilisateur serait
// déconnecté en pleine session.
const ACCESS_TOKEN_TTL = '1h'
const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000 // 30 jours

export function signAccessToken(payload: { id: string; role: string }): string {
  return jwt.sign(payload, process.env.JWT_SECRET!, { expiresIn: ACCESS_TOKEN_TTL })
}

// Le refresh token brut n'est jamais stocké côté serveur : seul son hash SHA-256
// l'est, comme un mot de passe. Si la base fuite, les tokens en circulation
// restent inutilisables.
export function generateRefreshToken(): { token: string; hash: string; expiresAt: Date } {
  const token = crypto.randomBytes(40).toString('hex')
  const hash = hashRefreshToken(token)
  const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS)
  return { token, hash, expiresAt }
}

export function hashRefreshToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex')
}
