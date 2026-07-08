# Haven — Contrat d'API interne

> Fichier de coordination entre Gabriel (backend) et Jarod (frontend).
> Versionné (suivi par git) — à tenir à jour à chaque ajout/modification de route.

---

## Base URL

| Environnement | URL |
| --- | --- |
| Émulateur Android | `http://10.0.2.2:3000/api` |
| Appareil physique | `http://<IP_locale>:3000/api` |
| Production | à définir |

Configurable via `--dart-define=BASE_URL=<url>` au build Flutter.

---

## Authentification

Toutes les routes protégées attendent un header :

```http
Authorization: Bearer <accessToken>
```

Les access tokens expirent après **1 heure**. Un `refreshToken` (30 jours, hashé en base) permet d'en obtenir un nouveau via `POST /api/auth/refresh`.

---

## Routes — Authentification

### POST `/api/auth/register`

Créer un compte élève.

**Body :**

```json
{
  "name":       "string",
  "email":      "string",
  "password":   "string",
  "className":  "string",
  "schoolCode": "string (doit exister dans la table School)"
}
```

**Réponse 200 :**

```json
{ "message": "string" }
```

**Réponse 400 :**

```json
{ "error": "string" }
```

---

### POST `/api/auth/login`

Connexion avec email + mot de passe.

**Body :**

```json
{
  "email":    "string",
  "password": "string"
}
```

**Réponse 200 :**

```json
{
  "token":        "string (JWT, 1h)",
  "refreshToken": "string (30j)",
  "user": {
    "id":   "string",
    "name": "string",
    "role": "STUDENT | TEACHER | DIRECTOR_CPE | RECTORAT | PARENT"
  }
}
```

**Réponse 401 :**

```json
{ "error": "string" }
```

---

### POST `/api/auth/refresh`

Échange un refresh token contre un nouveau couple access + refresh.

**Body :**

```json
{ "refreshToken": "string" }
```

**Réponse 200 :**

```json
{
  "token":        "string (JWT, 1h)",
  "refreshToken": "string (nouveau, 30j)"
}
```

**Réponse 401 :** token invalide ou expiré

---

### POST `/api/auth/logout`

Révoque le refresh token côté serveur.

**Body :**

```json
{ "refreshToken": "string" }
```

**Réponse 200 :**

```json
{ "success": true }
```

---

### DELETE `/api/auth/account`

Supprime le compte de l'utilisateur connecté.

**Header requis :** `Authorization: Bearer <token>`

**Réponse 200 :**

```json
{ "success": true }
```

---

### GET `/api/auth/account`

Récupère le code de suivi parent de l'élève connecté.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
{ "parentCode": "string | null" }
```

---

### PATCH `/api/auth/account`

Enregistre un compte parent lié à un élève via code de suivi.

**Body :**

```json
{
  "parentCode": "string",
  "email":      "string",
  "password":   "string"
}
```

**Réponse 200 :**

```json
{ "success": true }
```

---

### POST `/api/auth/register/parent`

Crée un compte parent et le lie à l'élève via son `parentCode`. Rate-limité (5 tentatives / 15 min / IP) — le `parentCode` est un secret qui donne accès aux signalements de l'enfant.

**Body :**

```json
{
  "email":      "string",
  "password":   "string (8 caractères min)",
  "name":       "string",
  "parentCode": "string (format HVN-P-XXXXXX)"
}
```

**Réponse 201 :**

```json
{ "message": "string" }
```

**Réponse 404 :** `parentCode` invalide ou inconnu
**Réponse 429 :** trop de tentatives (`Retry-After` en secondes)

---

### PATCH `/api/auth/fcm`

Enregistre ou met à jour le token FCM (push notifications) de l'utilisateur connecté.

**Header requis :** `Authorization: Bearer <token>`

**Body :**

```json
{ "fcmToken": "string" }
```

**Réponse 200 :**

```json
{ "success": true }
```

---

### GET `/api/student/parent-code`

L'élève récupère son propre code de liaison parent (`parentCode`), à partager avec un parent pour `POST /api/auth/register/parent`.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
{ "parentCode": "string | null" }
```

---

## Routes — Établissements

### GET `/api/schools`

Récupérer la liste des établissements (publique, sans auth).

**Réponse 200 :**

```json
[
  { "code": "CLG-SJL-31", "name": "Collège Saint Joseph La Salle — Toulouse", "type": "COLLEGE" },
  { "code": "LYC-SJL-31", "name": "Lycée Saint Joseph La Salle — Toulouse",   "type": "LYCEE"   }
]
```

**Types possibles :** `COLLEGE` | `LYCEE` | `BTS_CPGE` | `MIXED`

---

## Routes — Signalements (Élève)

### POST `/api/reports`

Soumettre un signalement. Réservé aux `STUDENT`.

**Header requis :** `Authorization: Bearer <token>`

**Body :**

```json
{
  "mode":           "VICTIM | WITNESS",
  "type":           "PHYSICAL | VERBAL | SEXUAL | CYBER | OTHER",
  "gravity":        "number (1 à 5)",
  "description":    "string (10 à 1000 caractères)",
  "targetLevel":    "TEACHER | DIRECTOR_CPE | RECTORAT",
  "anonymityLevel": "NONE | NAME_HIDDEN | NAME_AND_CLASS_HIDDEN | FULLY_ANONYMOUS"
}
```

**Réponse 201 :**

```json
{
  "success":       true,
  "id":            "string",
  "trackingCode":  "string (ex: HVN-AB12-CD34)",
  "integrityHash": "string (SHA-256)"
}
```

**Réponse 401 :** token manquant ou invalide
**Réponse 403 :** rôle non autorisé (non STUDENT)
**Réponse 400 :** validation Zod échouée

---

### GET `/api/reports/mine`

Liste des signalements soumis par l'élève connecté.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
[
  {
    "id":             "string",
    "type":           "PHYSICAL | ...",
    "gravity":        "number",
    "status":         "PENDING | IN_PROGRESS | CLOSED",
    "anonymityLevel": "NONE | ...",
    "targetLevel":    "TEACHER | ...",
    "trackingCode":   "string",
    "createdAt":      "datetime",
    "updatedAt":      "datetime",
    "_count": { "followUps": "number" }
  }
]
```

> `_count.followUps` permet d'afficher un badge "mis à jour" dans l'onglet Suivi.

---

### GET `/api/reports/mine/[id]`

Détail complet d'un signalement de l'élève + timeline des actions staff.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
{
  "id":             "string",
  "type":           "string",
  "gravity":        "number",
  "description":    "string",
  "status":         "string",
  "anonymityLevel": "string",
  "targetLevel":    "string",
  "trackingCode":   "string",
  "createdAt":      "datetime",
  "updatedAt":      "datetime",
  "followUps": [
    {
      "id":        "string",
      "notes":     "string",
      "newStatus": "IN_PROGRESS | CLOSED",
      "createdAt": "datetime",
      "staff": { "role": "TEACHER | DIRECTOR_CPE | RECTORAT" }
    }
  ]
}
```

> Le nom du staff n'est pas exposé — seulement son rôle.

**Réponse 404 :** signalement introuvable
**Réponse 403 :** signalement appartenant à un autre élève

---

### GET `/api/reports/mine/[id]/verify`

Vérifie l'intégrité d'un signalement (hash SHA-256).

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
{ "valid": true }
```

---

### DELETE `/api/reports/mine/[id]`

Annule un signalement dans les 5 minutes suivant sa soumission.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
{ "success": true }
```

**Réponse 409 :** délai de 5 minutes écoulé
**Réponse 403 :** signalement appartenant à un autre élève

---

### POST `/api/reports/mine/[id]/messages`

L'élève envoie un message libre au staff sur son signalement (conversation, distincte des `followUps` de statut).

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Body :**

```json
{ "body": "string (1 à 1000 caractères)" }
```

**Réponse 201 :**

```json
{ "id": "string", "body": "string", "senderRole": "STUDENT", "createdAt": "datetime" }
```

**Réponse 403 :** signalement appartenant à un autre élève

---

## Routes — Signalements (Staff)

### GET `/api/reports`

Récupérer les signalements. Réservé aux rôles staff.
Filtrés par `schoolCode` de l'agent et par `targetLevel` correspondant à son rôle.

**Header requis :** `Authorization: Bearer <token>`

**Query params optionnels :**

- `status` : `PENDING | IN_PROGRESS | CLOSED`
- `type` : `PHYSICAL | VERBAL | SEXUAL | CYBER | OTHER`
- `gravity` : `1`–`5`
- `code` : tracking code partiel

**Réponse 200 :**

```json
[
  {
    "id":             "string",
    "type":           "PHYSICAL | VERBAL | ...",
    "gravity":        "number",
    "description":    "string",
    "targetLevel":    "TEACHER | ...",
    "anonymityLevel": "NONE | NAME_HIDDEN | ...",
    "status":         "PENDING | IN_PROGRESS | CLOSED",
    "createdAt":      "datetime",
    "author": {
      "name":      "string | null (masqué selon anonymityLevel)",
      "className": "string | null"
    }
  }
]
```

> Le masquage de `name`/`className` est appliqué **côté serveur** via `applyAnonymity()`.

**Réponse 401 :** token manquant ou invalide
**Réponse 403 :** rôle non autorisé (STUDENT)

---

### GET `/api/reports/[id]`

Détail complet d'un signalement + historique des actions.

**Header requis :** `Authorization: Bearer <token>`

**Réponse 200 :**

```json
{
  "id":             "string",
  "type":           "PHYSICAL | ...",
  "gravity":        "number",
  "description":    "string",
  "targetLevel":    "TEACHER | ...",
  "anonymityLevel": "NONE | ...",
  "status":         "PENDING | IN_PROGRESS | CLOSED",
  "createdAt":      "datetime",
  "updatedAt":      "datetime",
  "author": {
    "name":       "string | null",
    "className":  "string | null",
    "schoolCode": "string"
  },
  "followUps": [
    {
      "id":        "string",
      "notes":     "string",
      "newStatus": "IN_PROGRESS | CLOSED",
      "createdAt": "datetime",
      "staff": { "name": "string", "role": "string" }
    }
  ]
}
```

**Réponse 404 :** signalement introuvable
**Réponse 403 :** établissement différent ou rôle non autorisé

---

### PATCH `/api/reports/[id]`

Changer le statut d'un signalement. Crée automatiquement un `FollowUp`.
Un signalement `CLOSED` ne peut plus être modifié.

**Header requis :** `Authorization: Bearer <token>`

**Body :**

```json
{
  "status": "IN_PROGRESS | CLOSED",
  "notes":  "string (optionnel, max 500 caractères)"
}
```

**Réponse 200 :**

```json
{ "success": true, "report": { "id": "string", "status": "string", "updatedAt": "datetime" } }
```

**Réponse 409 :** signalement déjà clôturé
**Réponse 403 :** établissement différent ou rôle non autorisé

---

### POST `/api/reports/[id]/escalate`

Transfère un signalement au niveau Rectorat. Réservé à `TEACHER`/`DIRECTOR_CPE` ; le signalement doit cibler le rôle de l'appelant. Le niveau d'origine est conservé (`escalatedFromLevel`) pour rester comptabilisé dans les stats de ce niveau.

**Header requis :** `Authorization: Bearer <token>`

**Body :**

```json
{ "notes": "string (optionnel, max 500 caractères)" }
```

**Réponse 200 :**

```json
{ "success": true }
```

**Réponse 409 :** déjà au niveau Rectorat, ou signalement non destiné à l'appelant

---

### POST `/api/reports/[id]/messages`

Un membre du staff répond librement à l'élève sur un signalement. Même contrôle d'accès que `GET /api/reports/[id]`.

**Header requis :** `Authorization: Bearer <token>`

**Body :**

```json
{ "body": "string (1 à 1000 caractères)" }
```

**Réponse 201 :**

```json
{ "id": "string", "body": "string", "senderRole": "TEACHER | DIRECTOR_CPE | RECTORAT", "createdAt": "datetime" }
```

---

## Routes — Signalements (Parent)

### GET `/api/parent/reports`

Liste des signalements des enfants liés au parent connecté (via `ParentStudentLink`).

**Header requis :** `Authorization: Bearer <token>` (rôle PARENT)

**Réponse 200 :** tableau de signalements (statut + dates, anonymisation appliquée selon `anonymityLevel`)

---

### GET `/api/parent/reports/[id]`

Détail d'un signalement pour le parent.

**Header requis :** `Authorization: Bearer <token>` (rôle PARENT)

**Réponse 200 :** détail du signalement, réservé aux enfants liés à ce parent
**Réponse 403 :** signalement d'un élève non lié à ce parent

---

## Routes — Humeur

### POST `/api/mood`

Enregistrer un check-in émotionnel.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Body :**

```json
{ "score": "number (1 à 5)" }
```

**Réponse 201 :**

```json
{ "success": true }
```

---

### GET `/api/mood`

Historique des check-ins des 7 derniers jours.

**Header requis :** `Authorization: Bearer <token>` (rôle STUDENT)

**Réponse 200 :**

```json
[
  { "score": "number", "createdAt": "datetime" }
]
```

---

## Routes — Notifications

### GET `/api/notifications`

Liste des notifications de l'utilisateur.

**Header requis :** `Authorization: Bearer <token>`

**Réponse 200 :**

```json
[
  {
    "id":        "string",
    "message":   "string",
    "read":      "boolean",
    "createdAt": "datetime"
  }
]
```

---

### PATCH `/api/notifications`

Marque toutes les notifications comme lues.

**Header requis :** `Authorization: Bearer <token>`

**Réponse 200 :**

```json
{ "success": true }
```

---

## Routes — Statistiques

### GET `/api/stats`

Statistiques agrégées. Accès selon le rôle.

**Header requis :** `Authorization: Bearer <token>` (TEACHER, DIRECTOR_CPE, RECTORAT)

**Réponse 200 :**

```json
{
  "total":          "number",
  "resolutionRate": "number (0.0 – 1.0)",
  "byStatus": {
    "PENDING":     "number",
    "IN_PROGRESS": "number",
    "CLOSED":      "number"
  },
  "byType": {
    "PHYSICAL": "number",
    "VERBAL":   "number",
    "SEXUAL":   "number",
    "CYBER":    "number",
    "OTHER":    "number"
  },
  "byGravity": { "1": "number", "2": "number", "3": "number", "4": "number", "5": "number" },
  "bySchool": [
    { "schoolCode": "string", "total": "number", "closed": "number" }
  ]
}
```

> `bySchool` n'est retourné que pour le rôle `RECTORAT`.

---

### GET `/api/stats/timeline`

Historique du nombre de signalements par période, pour graphique.

**Header requis :** `Authorization: Bearer <token>` (TEACHER, DIRECTOR_CPE, RECTORAT)

**Query params :**

- `period` : `week` (7 jours/jour, défaut) | `month` (5 semaines) | `year` (12 mois)

**Réponse 200 :**

```json
[
  { "label": "string (ex: Lun, 6/7, Juil)", "count": "number" }
]
```

---

## Routes — Administration

> Ces 3 routes partagent un même budget de rate limiting (10 tentatives / 15 min / IP) sur `ADMIN_SECRET`.

### POST `/api/admin/users`

Créer un compte staff. Protégé par `ADMIN_SECRET`.
Ne jamais appeler depuis l'app mobile.

**Header requis :** `Authorization: Bearer <ADMIN_SECRET>`

**Body :**

```json
{
  "name":       "string",
  "email":      "string",
  "password":   "string (8 caractères min)",
  "role":       "TEACHER | DIRECTOR_CPE | RECTORAT",
  "schoolCode": "string"
}
```

**Réponse 201 :**

```json
{
  "success": true,
  "user": {
    "id":         "string",
    "name":       "string",
    "email":      "string",
    "role":       "string",
    "schoolCode": "string"
  }
}
```

**Réponse 401 :** ADMIN_SECRET manquant ou incorrect
**Réponse 409 :** email déjà utilisé
**Réponse 400 :** schoolCode invalide ou validation échouée

---

### GET `/api/admin/deletion-requests`

Liste des demandes de suppression de compte en attente.

**Header requis :** `Authorization: Bearer <ADMIN_SECRET>`

**Réponse 200 :** tableau de demandes avec `userId`, `email`, `createdAt`

---

### POST `/api/admin/deletion-requests/[id]`

Approuver ou refuser une demande de suppression.

**Header requis :** `Authorization: Bearer <ADMIN_SECRET>`

**Body :**

```json
{ "action": "APPROVE | REJECT" }
```

**Réponse 200 :**

```json
{ "success": true }
```

---

## Rôles

| Rôle | Accès |
| --- | --- |
| `STUDENT` | Soumettre des signalements, suivre ses dossiers, check-in humeur, compte |
| `TEACHER` | Voir et gérer les signalements de son établissement |
| `DIRECTOR_CPE` | Voir + gérer + escalader les signalements de son établissement |
| `RECTORAT` | Accès global multi-établissements + statistiques académiques |
| `PARENT` | Accès lecture seule aux signalements de son enfant (via code de liaison) |
