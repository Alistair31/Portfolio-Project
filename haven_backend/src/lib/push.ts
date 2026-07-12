import { db } from '@/lib/db'
import { cert, getApps, initializeApp } from 'firebase-admin/app'
import { getMessaging, type Messaging } from 'firebase-admin/messaging'

// Tolérant : si les credentials Firebase ne sont pas fournis (env vars
// absentes), ce module ne fait rien plutôt que de planter le serveur. Ça permet
// de déployer/développer sans projet Firebase et d'activer le push plus tard
// en ajoutant juste les 3 variables d'env (FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL,
// FIREBASE_PRIVATE_KEY — récupérables dans la console Firebase, Paramètres du
// projet > Comptes de service > Générer une nouvelle clé privée).
let messaging: Messaging | null = null
let initAttempted = false

function resolveMessaging(): Messaging | null {
  if (initAttempted) return messaging
  initAttempted = true

  const projectId = process.env.FIREBASE_PROJECT_ID
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL
  // Le \n littéral doit être ré-échappé : la plupart des hébergeurs ne
  // permettent pas de stocker un saut de ligne réel dans une variable d'env.
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n')

  if (!projectId || !clientEmail || !privateKey) {
    console.warn('[push] FIREBASE_* absents — notifications push désactivées (in-app uniquement).')
    return null
  }

  const app = getApps().length
    ? getApps()[0]
    : initializeApp({ credential: cert({ projectId, clientEmail, privateKey }) })
  messaging = getMessaging(app)
  return messaging
}

// Envoie une notification push aux utilisateurs ayant un fcmToken enregistré.
// Best-effort : à appeler avec .catch(), jamais avec await bloquant la réponse HTTP.
export async function sendPushToUsers(userIds: string[], title: string, body: string) {
  const m = resolveMessaging()
  if (!m || userIds.length === 0) return

  const users = await db.user.findMany({
    where: { id: { in: userIds }, fcmToken: { not: null } },
    select: { id: true, fcmToken: true },
  })
  if (users.length === 0) return

  const tokens = users.map((u) => u.fcmToken!).filter(Boolean)
  const response = await m.sendEachForMulticast({
    tokens,
    notification: { title, body },
  })

  // Un token invalide/désinstallé renvoie une erreur par message : on les
  // nettoie pour ne pas re-tenter indéfiniment un envoi voué à échouer.
  const staleTokens = response.responses
    .map((r, i) => (!r.success ? tokens[i] : null))
    .filter((t): t is string => t !== null)

  if (staleTokens.length > 0) {
    await db.user.updateMany({
      where: { fcmToken: { in: staleTokens } },
      data: { fcmToken: null },
    })
  }
}
