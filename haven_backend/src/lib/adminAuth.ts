import { timingSafeEqual, createHash } from 'crypto'

// Compare deux chaînes en temps constant SANS fuiter leur longueur relative :
// on les hash d'abord (digest de taille fixe) avant timingSafeEqual, ce qui
// évite le court-circuit "if (a.length !== b.length) return false" qui
// laisserait deviner la longueur du secret via le temps de réponse.
function constantTimeEqual(a: string, b: string): boolean {
  const digestA = createHash('sha256').update(a).digest()
  const digestB = createHash('sha256').update(b).digest()
  return timingSafeEqual(digestA, digestB)
}

// Vérification du token admin.
// Cette route est protégée par un secret statique (ADMIN_SECRET dans .env),
// différent du JWT utilisateur. Elle n'est jamais appelée depuis l'app mobile —
// uniquement par l'administrateur système (curl, Postman, script CI).
export function isAdmin(request: Request): boolean {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ') || !process.env.ADMIN_SECRET) return false

  const token = authHeader.split(' ')[1]
  return constantTimeEqual(token, process.env.ADMIN_SECRET)
}
