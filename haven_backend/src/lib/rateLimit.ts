// Limiteur en mémoire (process unique). Suffisant pour un déploiement
// mono-instance ; passer à Redis si l'app tourne un jour sur plusieurs instances,
// sinon chaque instance aurait son propre compteur et la limite globale ne tiendrait plus.
const buckets = new Map<string, { count: number; resetAt: number }>()

// Purge paresseuse : évite une fuite mémoire sans nécessiter de setInterval.
function pruneExpired(now: number) {
  if (buckets.size < 1000) return
  for (const [key, bucket] of buckets) {
    if (now > bucket.resetAt) buckets.delete(key)
  }
}

export function rateLimit(
  key: string,
  limit: number,
  windowMs: number
): { allowed: boolean; retryAfterSeconds?: number } {
  const now = Date.now()
  pruneExpired(now)

  const bucket = buckets.get(key)
  if (!bucket || now > bucket.resetAt) {
    buckets.set(key, { count: 1, resetAt: now + windowMs })
    return { allowed: true }
  }

  if (bucket.count >= limit) {
    return { allowed: false, retryAfterSeconds: Math.ceil((bucket.resetAt - now) / 1000) }
  }

  bucket.count++
  return { allowed: true }
}

function getClientIp(request: Request): string {
  // x-forwarded-for peut contenir plusieurs IP (proxy chain) : on prend la première.
  const forwarded = request.headers.get('x-forwarded-for')
  if (forwarded) return forwarded.split(',')[0].trim()
  return request.headers.get('x-real-ip') ?? 'unknown'
}

export function rateLimitKey(request: Request, scope: string): string {
  return `${scope}:${getClientIp(request)}`
}

// Pour les routes déjà authentifiées (signalements, messagerie...), une clé
// par IP est trop grossière (plusieurs élèves derrière le même NAT/wifi
// scolaire partageraient un budget) et n'aide pas contre un compte compromis
// qui spamme depuis sa propre IP. On limite plutôt par utilisateur.
export function rateLimitKeyForUser(userId: string, scope: string): string {
  return `${scope}:user:${userId}`
}
