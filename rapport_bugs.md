# Rapport des bugs et erreurs corrigés — Haven

## 1. Mauvaise méthode HTTP dans l'API Service
**Fichier :** `haven_app/lib/services/api_service.dart`  
**Erreur :** Les requêtes `login` et `register` utilisaient `GET` au lieu de `POST`.  
**Impact :** Le serveur répondait `405 Method Not Allowed`.  
**Correction :** Remplacement de `http.get` par `http.post` avec un body JSON et le header `Content-Type: application/json`.

---

## 2. URL incorrecte des endpoints
**Fichier :** `haven_app/lib/services/api_service.dart`  
**Erreur :** Les routes étaient appelées `/api/login` et `/api/register` au lieu de `/api/auth/login` et `/api/auth/register`.  
**Impact :** Le serveur retournait une page HTML 404, provoquant un `FormatException: Unexpected character` lors du `jsonDecode`.  
**Correction :** Ajout de `/auth/` dans les chemins des deux endpoints.

---

## 3. `localhost` inaccessible depuis l'émulateur Android
**Fichier :** `haven_app/lib/services/api_service.dart`  
**Erreur :** `baseUrl` pointait vers `http://localhost:3000/api`. Sur un émulateur Android, `localhost` désigne l'émulateur lui-même, pas la machine hôte.  
**Impact :** `ClientException` — connexion refusée.  
**Correction :** Remplacement de `localhost` par `10.0.2.2`, l'adresse de la machine hôte depuis l'émulateur Android. La valeur est maintenant configurable via `String.fromEnvironment('BASE_URL')`.

---

## 4. Version mismatch Prisma CLI vs Prisma Client
**Fichier :** `haven_backend/package.json`  
**Erreur :** `prisma` (CLI) était en version `^6.19.3` tandis que `@prisma/client` était en `^7.8.0`. La mise à jour vers Prisma 7 a introduit des breaking changes (`url` dans le datasource non supporté).  
**Impact :** `Module not found: Can't resolve '@prisma/client/runtime/library'` — le backend ne démarrait pas.  
**Correction :** Rétrogradation de `@prisma/client` et `@prisma/adapter-pg` vers la version `6.x` pour correspondre au CLI. Régénération du client Prisma avec `npx prisma generate`.

---

## 5. Variable `_checkbox` non déclarée après la merge
**Fichier :** `haven_app/lib/pages/authentification/login_page.dart`  
**Erreur :** La merge avec la branche du 2ème développeur a introduit un widget `Checkbox` utilisant `_checkbox` sans que la variable soit déclarée dans le state.  
**Impact :** Erreur de compilation — l'app ne démarrait pas.  
**Correction :** Ajout de `bool _checkbox = false;` dans `_LoginPageState`.

---

## 6. Import inutilisé après la merge
**Fichier :** `haven_app/lib/pages/authentification/login_page.dart`  
**Erreur :** La merge a supprimé le `SecondaryButton` ("Continuer anonymement") mais a laissé son import `secondary_button.dart`.  
**Impact :** Warning de compilation.  
**Correction :** Suppression de l'import inutilisé.

---

## 7. Mauvais nom de classe pour l'onboarding
**Fichier :** `haven_app/lib/pages/authentification/login_page.dart`  
**Erreur :** Navigation vers `OnboardingPage()` alors que la classe s'appelle `OnboardingFlow`.  
**Impact :** Erreur de compilation — classe introuvable.  
**Correction :** Remplacement de `OnboardingPage` par `OnboardingFlow`.

---

## 8. `MissingPluginException` après ajout de `shared_preferences`
**Contexte :** Premier lancement après ajout du package `shared_preferences`.  
**Erreur :** `MissingPluginException` au moment de l'appel à `SharedPreferences.getInstance()`.  
**Impact :** Crash au login.  
**Correction :** `flutter clean` + `flutter pub get` + `flutter run` pour forcer la recompilation du code natif du plugin.

---

## 9. Android Build Tools 35 corrompus
**Erreur :** `Installed Build Tools revision 35.0.0 is corrupted. Remove and install again using the SDK Manager.`  
**Impact :** Build Android impossible.  
**Correction :** Désinstallation puis réinstallation de Build Tools 35 via le SDK Manager d'Android Studio.  
**Prévention :** Désactiver l'antivirus (Windows Defender) pendant les installations SDK. Épingler une version stable (`34.0.0`) dans `android/app/build.gradle`.

---

## 10. Swipe arrière depuis l'onboarding vers le SplashScreen
**Fichier :** `haven_app/lib/pages/onboarding/onboarding_page.dart`  
**Erreur :** Le geste retour système depuis `OnboardingFlow` remontait jusqu'au `SplashScreen` (toujours présent dans la pile de navigation), provoquant un blocage de l'animation.  
**Impact :** L'app se figeait.  
**Correction :** Wrapping du `Scaffold` dans un `PopScope(canPop: false)` pour bloquer le geste retour pendant l'onboarding.

---

## 12. Bouton retour depuis `LoginPage` et `HomePage` affichait le `SplashScreen`
**Fichier :** `haven_app/lib/pages/splashscreen/splashscreen.dart`  
**Erreur :** La navigation de `SplashScreen` vers `HavenScreen` utilisait `Navigation.pushReplacement` (classe inexistante dans Flutter) au lieu de `Navigator.pushReplacement`. Le `SplashScreen` restait donc dans la pile de navigation.  
**Impact :** Appuyer sur le bouton retour depuis `LoginPage` ou `HomePage` ramenait au `SplashScreen` en plein milieu de son animation, figeant l'app.  
**Correction :** Remplacement de `Navigation.pushReplacement` par `Navigator.pushReplacement` ligne 36.

---

## 11. Syntaxe pubspec.yaml incorrecte

**Fichier :** `haven_app/pubspec.yaml`  
**Erreur :** Duplication de la clé `flutter:` et ajout de `shared_preferences` comme valeur au lieu d'une dépendance.  
**Impact :** `flutter pub get` échouait.  
**Correction :** Ajout de `shared_preferences: ^2.5.3` au bon niveau dans la section `dependencies`.

---

## 13. `home_page.dart` inexistant — app non compilable

**Fichiers :** `login_page.dart`, `HavenStart.dart`, `onboarding_page.dart`  
**Erreur :** Les trois fichiers importaient `pages/home/home_page.dart` qui n'existait pas sur le disque.  
**Impact :** Erreur de compilation — l'app ne démarrait pas du tout.  
**Correction :** Création de `home_page.dart` avec `StatefulWidget`, `HavenBottomBar` (3 onglets : Accueil, Suivi, Compte) et un FAB central.

---

## 14. `_selectedGrade` jamais inclus dans le `className` envoyé à l'API

**Fichier :** `haven_app/lib/pages/authentification/register_page.dart`  
**Erreur :** La variable du dropdown (`_selectedGrade`) n'était jamais combinée avec le champ section. L'API recevait uniquement la lettre de section (ex : "A") au lieu du nom complet (ex : "6e A").  
**Impact :** Données de classe incorrectes en base.  
**Correction :** Construction de `className` par concaténation : `'${_selectedGrade!} $classSection'.trim()`. La validation vérifie maintenant que les deux champs sont remplis.

---

## 15. `mounted` manquant après `await` dans `_handleLogin`

**Fichier :** `haven_app/lib/pages/authentification/login_page.dart`  
**Erreur :** Après les appels `await ApiService().login()`, `await PreferencesService().saveToken()` et `await PreferencesService().hasSeenOnboarding()`, le code utilisait `Navigator.of(context)` sans vérifier que le widget était toujours monté.  
**Impact :** Crash potentiel si le widget est détruit pendant une requête réseau.  
**Correction :** Ajout de `if (!mounted) return;` après chaque `await`.

---

## 16. Crash `Null check operator` lors de la suppression de compte

**Fichier :** `haven_app/lib/widgets/delete_button.dart`  
**Erreur :** `token!` plantait si l'utilisateur s'était connecté sans cocher "Rester connecté" — `PreferencesService().getToken()` retournait `null` car le token n'était pas persisté sur disque.  
**Impact :** L'app freezait à la confirmation de suppression.  
**Correction :** Remplacement de `token!` par une vérification null avec `SnackBar` d'erreur. Résolution définitive via `SessionService` (voir #17).

---

## 17. Token de session inaccessible sans "Rester connecté"

**Fichiers :** `login_page.dart`, `delete_button.dart`, `logout_button.dart`  
**Erreur :** Le token JWT n'était sauvegardé dans `SharedPreferences` que si la checkbox "Rester connecté" était cochée. Les widgets nécessitant le token (`DeleteAccountButton`) ne pouvaient pas y accéder en session non persistante.  
**Impact :** Suppression de compte impossible sans "Rester connecté".  
**Correction :** Création de `SessionService` (variable statique en RAM) : le token est toujours stocké en mémoire pour la durée de la session, indépendamment de la checkbox. `SharedPreferences` reste utilisé uniquement pour la persistance entre sessions.

---

## 18. `mounted` utilisé dans un `StatelessWidget`

**Fichier :** `haven_app/lib/widgets/delete_button.dart`  
**Erreur :** `if (!mounted) return;` dans une classe qui étend `StatelessWidget`. La propriété `mounted` n'existe que dans un `State` (StatefulWidget).  
**Impact :** Erreur de compilation.  
**Correction :** Suppression de la ligne — le `Navigator` capturé avant le `await` est suffisant.

---

## 19. Chemin d'import incorrect dans `logout_button.dart`

**Fichier :** `haven_app/lib/widgets/logout_button.dart`  
**Erreur :** `import '../../theme/app_colors.dart'` remontait deux niveaux depuis `lib/widgets/`, pointant hors du dossier `lib/`.  
**Impact :** Erreur de compilation — fichier introuvable.  
**Correction :** Remplacement par `import '../theme/app_colors.dart'`.

---

## 20. `DropdownButtonFormField.value` déprécié

**Fichier :** `haven_app/lib/pages/authentification/register_page.dart`  
**Erreur :** Utilisation du paramètre `value:` sur un `DropdownButtonFormField`, déprécié depuis Flutter 3.33.  
**Impact :** Warning de compilation.  
**Correction :** Remplacement par `initialValue:` — fonctionne identiquement car le widget se reconstruit à chaque `setState`.

---

## Audit de sécurité — Vulnérabilités identifiées

### S1. Inscription ouverte sans validation du `schoolCode` ✅ RÉSOLU

**Fichier :** `haven_backend/src/app/api/auth/register/route.ts`  
**Sévérité :** MEDIUM | **Confiance :** 8/10  
**Description :** N'importe qui pouvait créer un compte avec n'importe quelle valeur de `schoolCode`. Pas de table `School`, pas de vérification, pas d'approbation admin.  
**Impact :** Un attaquant externe pouvait s'inscrire et accéder au système de signalement comme un vrai élève.  
**Correction appliquée :**

- Table `School` créée en base (code unique, nom, migration `add_school_table`)
- Route `GET /api/schools` publique pour alimenter le dropdown Flutter
- Validation dans `POST /api/auth/register` : `db.school.findUnique({ where: { code: schoolCode } })` — retourne 400 si inconnu
- Dropdown Établissement ajouté dans `register_page.dart` — l'élève ne peut sélectionner qu'un code existant

### S3. Anonymat des signalements non appliqué côté serveur ✅ RÉSOLU

**Fichiers :** `haven_backend/src/app/api/reports/route.ts`, `haven_backend/src/app/api/reports/[id]/route.ts`
**Sévérité :** HIGH | **Confiance :** 9/10
**Description :** Les routes staff (`GET /api/reports` et `GET /api/reports/[id]`) retournaient systématiquement `author.name`, `author.className` et `author.schoolCode` dans la réponse JSON, quelle que soit la valeur de `anonymityLevel` choisie par l'élève au moment du signalement. Le champ `anonymityLevel` était présent dans la réponse mais jamais consulté avant l'envoi des données d'identité.
**Impact :** Un membre du staff authentifié recevait l'identité complète de l'élève même si celui-ci avait sélectionné `FULLY_ANONYMOUS`. L'élève croyait être protégé — il ne l'était pas. Dans le contexte d'une application de signalement de harcèlement pour mineurs, cette faille exposait directement les victimes à des représailles.
**Correction appliquée :**

- Création de `haven_backend/src/lib/anonymize.ts` : fonction partagée `applyAnonymity(author, level)` qui masque `name`, `className` et `schoolCode` selon le niveau (`NAME_HIDDEN` → masque le nom, `NAME_AND_CLASS_HIDDEN` → masque nom et classe, `FULLY_ANONYMOUS` → masque tout)
- `reports/route.ts` : map post-requête appliquant `applyAnonymity` sur chaque signalement avant sérialisation
- `reports/[id]/route.ts` : application de `applyAnonymity` après la vérification inter-établissement, avant le `JSON.stringify`

---

### S4. Fuite d'erreur interne dans `GET /api/schools` ✅ RÉSOLU

**Fichier :** `haven_backend/src/app/api/schools/route.ts`
**Sévérité :** MEDIUM | **Confiance :** 9/10
**Description :** Le handler d'erreur de cette route retournait `{ error: 'Database error', detail: String(error) }`. Contrairement à toutes les autres routes du projet (qui retournent uniquement un message générique), ce `String(error)` exposait le texte brut de l'erreur Prisma/postgres dans la réponse HTTP. Les erreurs de connexion Prisma (`PrismaPg`/`node-postgres`) incluent typiquement le host, le port et des fragments de la `DATABASE_URL` — laquelle contient une clé secrète. Ce endpoint est accessible sans authentification.
**Impact :** Un attaquant provoquant une erreur 500 (panne transitoire DB, burst de requêtes) recevait en clair des informations sur l'infrastructure database, potentiellement incluant la chaîne de connexion.
**Correction appliquée :** Suppression du champ `detail` ; le handler retourne maintenant `{ error: 'Database error' }` avec `status: 500`, aligné sur le pattern des autres routes. L'erreur complète reste loggée côté serveur via `console.error`.

---

### S2. Checkbox "Rester connecté" sans effet — token toujours persisté ✅ RÉSOLU

**Fichier :** `haven_app/lib/pages/authentification/login_page.dart:37`  
**Sévérité :** MEDIUM | **Confiance :** 8/10  
**Description :** `_checkbox` est affiché dans l'UI mais jamais lu dans `_handleLogin()`. Le token JWT est sauvegardé inconditionnellement. Aucune fonction logout n'existe.  
**Impact :** Sur un appareil partagé (tablette de classe), l'élève suivant accède automatiquement au compte du précédent malgré la décoché de "Rester connecté".  
**Correction appliquée :**
- `saveToken()` conditionné à `_checkbox` dans `_handleLogin()`
- Widget `LogoutButton` créé (`haven_app/lib/widgets/logout_button.dart`) : supprime le token via `PreferencesService().removeToken()` et redirige vers `LoginPage` en vidant la pile
- Consentement RGPD ajouté à l'inscription : checkbox obligatoire + lien vers `PrivacyPolicyPage`

---

### Bug #21 — `HavenStart` auto-login cassé ✅ RÉSOLU

**Fichier :** `haven_app/lib/pages/splashscreen/HavenStart.dart`
**Sévérité :** CRITICAL | **Confiance :** 10/10
**Description :** `_goToLogin()` chargeait le token depuis `SharedPreferences` via `PreferencesService().getToken()` mais ne le transmettait jamais à `SessionService`. Le rôle et le nom n'étaient pas stockés en préférences au moment du login, donc non restituables au redémarrage. La méthode routait systématiquement vers `StudentHomePage` quel que soit le rôle de l'utilisateur.
**Impact :** "Rester connecté" était visuellement présent mais totalement non fonctionnel — l'app redémarrait toujours sur la page de login. Un staff loggé en `TEACHER` ou `DIRECTOR_CPE` était renvoyé sur la vue student.
**Correction appliquée :**

- `preferences.dart` : ajout de `saveRole`, `getRole`, `removeRole`, `saveName`, `getName`, `removeName`
- `login_page.dart` : appel de `saveRole()` et `saveName()` dans `_handleLogin()` quand `_checkbox` est coché
- `HavenStart.dart` : réécriture de `_goToLogin()` en méthode `async` — charge token + rôle + nom, peuple `SessionService`, route par rôle via `switch`
- `logout_button.dart` + `account_page.dart` : ajout de `removeRole()` et `removeName()` au logout pour purger complètement les préférences

---

### Bug #22 — `submitReport()` ne retournait pas `trackingCode` ✅ RÉSOLU

**Fichier :** `haven_app/lib/services/api_service.dart`
**Sévérité :** HIGH | **Confiance :** 10/10
**Description :** Le backend `POST /api/reports` retourne `{ success, id, trackingCode, integrityHash }`. La méthode `submitReport()` n'extrayait que `id` et `integrityHash` dans son `Map<String, String>` de retour — le champ `trackingCode` était silencieusement ignoré.
**Impact :** Le dialog de confirmation post-soumission affichait un tracking code vide, rendant le suivi de dossier impossible pour l'élève côté Flutter. Les données étaient correctement enregistrées en base mais inaccessibles dans l'UI.
**Correction appliquée :** Ajout de `'trackingCode': data['trackingCode'] as String` dans le `Map<String, String>` retourné par `submitReport()`.

---

### Bug #23 — `lookupTrackingCode()` — méthode morte sans endpoint backend ✅ RÉSOLU

**Fichier :** `haven_app/lib/services/api_service.dart`
**Sévérité :** LOW | **Confiance :** 10/10
**Description :** `lookupTrackingCode(String code)` appelait `GET /api/reports/track?code=...` — une route qui n'existe pas côté backend et n'a jamais existé. La méthode n'était appelée nulle part dans l'app Flutter.
**Impact :** Aucun impact utilisateur direct. Risque de maintenance : confusion sur l'API disponible, potentiel appel accidentel futur retournant un 404.
**Correction appliquée :** Suppression complète de la méthode `lookupTrackingCode` de `api_service.dart`.

---

### Bug #24 — Bouton d'annulation visible après expiration de la fenêtre de 5 minutes ✅ RÉSOLU

**Fichier :** `haven_app/lib/pages/student/report_detail_page.dart`
**Sévérité :** MEDIUM | **Confiance :** 9/10
**Description :** `_canCancel` est un getter recalculé uniquement lors d'un rebuild (déclenché par `setState` dans `_load`, `_cancel` ou `_checkIntegrity`). Aucune minuterie ne forçait de rebuild à l'instant précis où les 5 minutes s'écoulaient : le bouton "Annuler le signalement" restait affiché indéfiniment tant que l'élève ne provoquait pas un rebuild par une autre interaction.
**Impact :** Un élève laissant la page ouverte au-delà du délai (ou y revenant plus tard sans qu'un rebuild ait eu lieu) voyait toujours le bouton d'annulation actif. Un appui déclenchait un appel `DELETE /api/reports/mine/[id]` rejeté côté serveur (`409 — Le délai d'annulation de 5 minutes est dépassé.`), une erreur confuse puisque l'UI n'avait rien signalé.
**Correction appliquée :** Ajout d'un `Timer` (`_cancelExpiry`) programmé dans `_scheduleCancelExpiry()` pour se déclencher exactement à l'expiration de la fenêtre de 5 minutes et forcer un `setState` qui recalcule `_canCancel`, masquant automatiquement le bouton. Le timer est annulé dans `dispose()` pour éviter tout `setState` après démontage du widget.

---

### Bug #25 — « Parler à l'équipe » : réponse élève non fonctionnelle ✅ RÉSOLU

**Fichiers :**

- `haven_backend/prisma/schema.prisma` (+ migration `add_message_model`)
- `haven_backend/src/app/api/reports/mine/[id]/messages/route.ts` (nouveau)
- `haven_backend/src/app/api/reports/[id]/messages/route.ts` (nouveau)
- `haven_backend/src/app/api/reports/mine/[id]/route.ts`, `haven_backend/src/app/api/reports/[id]/route.ts` (GET détail)
- `haven_app/lib/services/api_service.dart`
- `haven_app/lib/pages/student/exchange_page.dart`
- `haven_app/lib/pages/staff/staff_report_detail_page.dart`

**Sévérité :** HIGH | **Confiance :** 10/10
**Description :** Le flux élève → « Mes signalements » → détail → « Parler à l'équipe » ouvrait `ExchangePage`, dont la zone de saisie était purement décorative : le bouton d'envoi affichait seulement un `SnackBar` « Fonctionnalité de réponse bientôt disponible. » et vidait le champ, sans aucun appel réseau. Aucun endpoint de message élève n'existait, et le schéma Prisma ne disposait que de `FollowUp` (action de statut du staff, avec `staffId` et `newStatus` obligatoires) — impossible d'y stocker un message d'élève. La messagerie annoncée était donc entièrement non implémentée.
**Impact :** Un élève en difficulté (potentiellement victime de harcèlement) croyait pouvoir dialoguer avec l'adulte de confiance de son établissement, mais ses messages n'étaient jamais envoyés ni enregistrés. Fonctionnalité centrale du produit inopérante et trompeuse.
**Correction appliquée :** Implémentation d'une messagerie bidirectionnelle complète.

- **Modèle `Message`** ajouté (`body`, `senderRole`, `reportId`, `senderId`, `createdAt`, index `[reportId, createdAt]`, cascade sur `Report` et `User`) + migration `add_message_model`. Distinct de `FollowUp` : conversation libre dans les deux sens.
- **`POST /api/reports/mine/[id]/messages`** (élève) : vérifie l'appartenance du signalement, crée le message (`senderRole = STUDENT`), notifie le staff ciblé (même rôle, même école) + push, non-bloquant.
- **`POST /api/reports/[id]/messages`** (staff) : même contrôle d'accès que le GET staff (école + `targetLevel === role`), crée le message avec le rôle de l'agent, notifie l'élève auteur + push.
- **GET détail élève et staff** : ajout de `messages` (id, body, senderRole, createdAt) — seul le rôle de l'expéditeur est exposé, jamais le nom du staff (anonymat préservé, cohérent avec `followUps`).
- **`ExchangePage` (élève)** : bouton d'envoi câblé sur `sendReportMessage`, fusion chronologique description + follow-ups + messages, auto-scroll, état d'envoi.
- **`StaffReportDetailPage` (staff)** : nouvelle section « Conversation avec l'élève » (bulles élève/staff) + zone de réponse (`sendStaffReportMessage`).

**Effet de bord découvert pendant l'implémentation :** cette branche avait retiré `url = env("DATABASE_URL")` du bloc `datasource` de `schema.prisma` en pensant Prisma 7 déjà en place, ce qui cassait `prisma generate`/`migrate` pour quiconque avait le CLI 6.19.3 réellement installé (cf. S12 ci-dessous) — la ligne a été restaurée lors de la fusion avec la branche `Gabriel`.

---

## Audit de sécurité — Deuxième passe (2026-07-03)

### S5. Brute force du `parentCode` → accès aux signalements d'un élève ✅ RÉSOLU

**Fichier :** `haven_backend/src/app/api/auth/register/parent/route.ts`
**Sévérité :** HIGH | **Confiance :** 9/10
**Description :** Contrairement à `login` et `register`, cette route n'appelait aucun `rateLimit`. Le `parentCode` (6 caractères, ~1 milliard de combinaisons possibles, généré par `Math.random()`) est la seule protection avant de lier un compte parent à un élève et de donner accès à ses signalements via `GET /api/parent/reports`.
**Impact :** Un attaquant pouvait scripter des tentatives à volonté sur des emails jetables ; toute réussite donnait accès aux signalements de harcèlement d'un mineur — contournement direct de la confidentialité, cœur de la promesse de l'application.
**Correction appliquée :** Ajout du même throttling que `/auth/login` (`rateLimit`/`rateLimitKey`, 5 tentatives / 15 min / IP, scope `register-parent`), avec réponse `429` et en-tête `Retry-After`.

---

### S6. Absence de rate limiting sur les routes admin (`ADMIN_SECRET`) + fuite de longueur du secret ✅ RÉSOLU

**Fichiers :** `haven_backend/src/app/api/admin/users/route.ts`, `admin/deletion-requests/route.ts`, `admin/deletion-requests/[id]/route.ts`
**Sévérité :** MEDIUM | **Confiance :** 8/10
**Description :** Aucune de ces trois routes n'était protégée par `rateLimit`, permettant un nombre illimité de tentatives par seconde sur `ADMIN_SECRET` (le bearer token qui autorise la création de comptes staff et la suppression de comptes arbitraires). De plus, `isAdmin()` retournait `false` immédiatement si `token.length !== secretBuf.length`, avant l'appel à `timingSafeEqual` — ce court-circuit fuit la longueur exacte du secret par le temps de réponse, affaiblissant la garantie "temps constant" visée par le commentaire du code.
**Impact :** Aujourd'hui limité (le secret en `.env` est long et aléatoire), mais aucune défense en profondeur si le secret est un jour plus faible ou changé.
**Correction appliquée :**

- Ajout du throttling (`rateLimit`, 10 tentatives / 15 min / IP, scope partagé `admin` entre les trois routes) avant toute vérification du secret.
- Extraction de `isAdmin()` dans un module partagé `haven_backend/src/lib/adminAuth.ts`, avec une comparaison qui hash d'abord les deux valeurs (digest SHA-256 de taille fixe) avant `timingSafeEqual`, éliminant la branche de longueur qui fuitait de l'information.

---

### S7. Validation non gérée dans `POST /api/reports/[id]/escalate` ✅ RÉSOLU

**Fichier :** `haven_backend/src/app/api/reports/[id]/escalate/route.ts`
**Sévérité :** MEDIUM | **Confiance :** 8/10
**Description :** La route utilisait `schema.parse(body)` (qui lève une exception) au lieu de `schema.safeParse`, et l'appel était situé avant le bloc `try/catch` du handler — contrairement à toutes les autres routes du projet. Une valeur de `notes` invalide (ex. un nombre au lieu d'une chaîne) provoquait une exception `ZodError` non interceptée par le `catch` de la fonction, renvoyant une 500 générique de Next.js au lieu du contrat d'erreur `{ error: '...' }` habituel.
**Impact :** Incohérence avec le reste de l'API et surface de plantage non gérée pour une entrée mal formée.
**Correction appliquée :** Remplacement par `schema.safeParse(body)` avec retour explicite d'une erreur `400`, aligné sur le pattern utilisé partout ailleurs.

---

### S8. Comparaison non constante dans la vérification d'intégrité ✅ RÉSOLU

**Fichier :** `haven_backend/src/app/api/reports/mine/[id]/verify/route.ts`
**Sévérité :** LOW | **Confiance :** 7/10
**Description :** `recomputed === report.integrityHash` utilisait une comparaison de chaînes standard au lieu de `timingSafeEqual`, alors que le pattern à temps constant est déjà utilisé ailleurs dans le code pour des comparaisons sensibles.
**Impact :** Minime — forger un hash nécessite déjà de connaître `REPORT_INTEGRITY_SECRET` (HMAC-SHA256) — mais incohérent avec le reste du projet.
**Correction appliquée :** Remplacement par `timingSafeEqual` sur les buffers des deux hex, avec une vérification préalable de longueur égale (requise par `timingSafeEqual`, qui lève une exception sur des buffers de tailles différentes).

---

### S9. Token JWT et refresh token stockés en clair dans `SharedPreferences` ✅ RÉSOLU

**Fichier :** `haven_app/lib/services/preferences.dart`
**Sévérité :** MEDIUM | **Confiance :** 8/10
**Description :** `saveToken()` et `saveRefreshToken()` utilisaient `SharedPreferences`, qui stocke les données en clair (XML/JSON non chiffré) dans le stockage privé de l'application, au lieu d'un stockage chiffré dédié aux identifiants de session.
**Impact :** Sur un appareil compromis (root) ou via une extraction physique du stockage, les tokens de session étaient directement lisibles en clair.
**Correction appliquée :** Migration de `saveToken`/`getToken`/`removeToken` et `saveRefreshToken`/`getRefreshToken`/`removeRefreshToken` vers `flutter_secure_storage` (Keystore Android / Keychain iOS). Ajout de la dépendance `flutter_secure_storage: ^9.2.4` dans `pubspec.yaml`.

---

### S10. `android:allowBackup` non désactivé (valeur par défaut `true`) ✅ RÉSOLU

**Fichier :** `haven_app/android/app/src/main/AndroidManifest.xml`
**Sévérité :** LOW | **Confiance :** 7/10
**Description :** L'attribut `android:allowBackup` n'était pas défini, donc Android applique sa valeur par défaut (`true`), autorisant potentiellement l'extraction des données de l'application (y compris les préférences) via `adb backup` sur un appareil avec le débogage USB activé.
**Impact :** Combiné à S9 (avant correction), un accès physique à un appareil en mode debug aurait permis d'extraire les tokens de session.
**Correction appliquée :** Ajout de `android:allowBackup="false"` et `android:fullBackupContent="false"` sur l'élément `<application>`.

---

### S11. APK release signé avec la clé de débogage ⚠️ PARTIELLEMENT RÉSOLU

**Fichier :** `haven_app/android/app/build.gradle.kts`
**Sévérité :** MEDIUM | **Confiance :** 9/10
**Description :** Le bloc `buildTypes { release { ... } }` utilisait `signingConfigs.getByName("debug")` sans condition — un TODO du template Flutter signalait déjà cette limitation. Un build "release" signé avec la clé debug ne garantit pas l'authenticité des mises à jour et serait de toute façon refusé par les stores.
**Impact :** Non exploitable tant que l'app n'est pas distribuée, mais bloquant avant toute publication.
**Correction appliquée :** Le build script charge désormais un `key.properties` (non commité, cf. `.gitignore` et `key.properties.example` ajoutés) s'il existe, et configure une vraie `signingConfig("release")` à partir de celui-ci ; à défaut, il retombe sur la clé debug pour ne pas casser `flutter run --release` en développement.
**Action restante (ne peut pas être automatisée) :** générer un keystore de production avec `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`, puis créer `haven_app/android/key.properties` à partir de `key.properties.example` avec le mot de passe choisi. Ce mot de passe ne doit être connu que de l'équipe et ne doit jamais être commité.

---

### S12. Version Prisma incohérente entre branches après une fusion ✅ RÉSOLU

**Fichier :** `haven_backend/prisma/schema.prisma`
**Sévérité :** MEDIUM | **Confiance :** 9/10
**Description :** La branche `Jarod` avait retiré `url = env("DATABASE_URL")` du bloc `datasource`, en anticipant Prisma 7 (qui n'accepte plus `url` à cet endroit). Mais ce projet reste sur **Prisma CLI 6.19.3** (rétrogradé exprès au bug #4), qui exige encore ce `url` pour que `prisma generate`/`migrate` fonctionnent. Après la fusion avec `Gabriel`, `prisma generate` et `prisma migrate status` échouaient tous les deux avec `P1012 — Argument "url" is missing`.
**Impact :** Le client Prisma n'a pas pu être régénéré avec le nouveau champ `escalatedFromLevel` ni le modèle `Message`, et les migrations correspondantes n'ont pas pu être appliquées à la base — cassant la page de statistiques (`stats/route.ts`, `stats/timeline/route.ts`) qui référence `escalatedFromLevel`.
**Correction appliquée :** Restauration de `url = env("DATABASE_URL")` dans le bloc `datasource` (le runtime continue d'utiliser l'adaptateur `PrismaPg` indépendamment de cette valeur — aucun changement de comportement applicatif). `npx prisma generate` régénéré, puis `npx prisma migrate deploy` appliqué sur la base distante (`db.prisma.io`) pour les 2 migrations en attente (`add_message_model`, `add_escalated_from_level`), sans reset — `migrate status` confirme "Database schema is up to date".

---

## 26. `Install Android SDK Platform 34 (revision 3) failed` — échec transitoire de build Gradle

**Contexte :** Après l'ajout de `flutter_secure_storage` (S9), `flutter run` échouait sur `:flutter_secure_storage:generateDebugRFile` avec `Failed to install the following SDK components: platforms;android-34`.
**Erreur :** Le même symptôme que le bug #9 (Build Tools 35 corrompus) : le composant SDK s'était en fait déjà téléchargé intégralement sur le disque (`android.jar`, `package.xml` présents et cohérents dans `platforms/android-34`), mais l'étape de vérification post-téléchargement de Gradle a échoué — cause probable : un antivirus (Windows Defender) verrouillant brièvement un fichier pendant le scan.
**Impact :** Build Android bloqué à la première tentative après l'ajout d'une nouvelle dépendance native.
**Correction :** `flutter clean` + `flutter pub get` + `flutter build apk --debug` — le build est passé du premier coup, confirmant que les fichiers SDK étaient déjà valides et que l'échec initial était ponctuel.
**Prévention :** Comme pour le bug #9, ajouter le dossier du SDK Android (`%LOCALAPPDATA%\Android\sdk`) aux exclusions de l'antivirus pour éviter que ce faux échec ne se reproduise à chaque nouvelle installation de composant SDK.

---

## 27. Un staff (RECTORAT/TEACHER/DIRECTOR_CPE) se connectant pour la première fois sur un appareil atterrit sur une interface élève vide

**Fichiers :** `haven_app/lib/pages/onboarding/onboarding_page.dart`, `haven_app/lib/pages/splashscreen/haven_start.dart`
**Erreur :** `hasSeenOnboarding()` est un flag stocké **par appareil**, pas par compte. Au premier login d'un rôle quelconque sur un nouvel appareil, `login_page.dart` affiche `OnboardingFlow` (`_handleLogin()`, branche `!onboardWait`) sans lui transmettre le rôle. À la fin de l'onboarding, `_finish()` redirigeait inconditionnellement vers `StudentHomePage()`, quel que soit le rôle réel de l'utilisateur connecté.
**Impact :** Un membre du staff (RECTORAT, TEACHER ou DIRECTOR_CPE) se connectant pour la première fois sur un appareil voyait l'onboarding puis atterrissait sur l'interface élève — vide ou cassée, puisque les appels API de cette page sont scopés à un compte STUDENT et échouent (403) pour un autre rôle.
**Correction appliquée :** Extraction d'une fonction partagée `homeForRole(String role)` (`haven_app/lib/services/role_router.dart`), reprenant le `switch` déjà utilisé dans `HavenStart._goToLogin()` (bug #21). `onboarding_page.dart` lit maintenant le rôle via `SessionService().getRole()` (déjà peuplé par `login_page.dart` avant l'affichage de l'onboarding) et route via `homeForRole()` au lieu de `StudentHomePage()` en dur. `HavenStart.dart` a été aligné sur la même fonction pour éliminer la duplication du switch entre les deux fichiers.
**Tests :** `test/role_router_test.dart` — couvre les 5 rôles et le cas d'un rôle inconnu/vide (fallback vers `LoginPage`).

---

## 28. Messagerie élève ↔ staff : nouveaux messages invisibles sans renvoyer un message ou recharger

**Fichiers :** `haven_app/lib/pages/student/exchange_page.dart`, `haven_app/lib/pages/staff/staff_report_detail_page.dart`
**Erreur :** Le fil de conversation n'était rechargé qu'à l'ouverture de la page (`initState`) et après l'envoi d'un message par l'utilisateur courant (`await _load()` dans `_send()`/`_sendMessage()`). Sans WebSocket/SSE côté backend, rien ne déclenchait de rafraîchissement quand c'était l'*autre* partie qui écrivait.
**Impact :** Un élève ou un membre du staff ne voyait pas les nouveaux messages de l'autre partie tant qu'il n'envoyait pas lui-même un message ou ne rechargeait pas la page.
**Correction appliquée :** Ajout d'un `Timer.periodic` (4s) dans les deux pages, démarré dans `initState()` et annulé dans `dispose()`, qui rafraîchit silencieusement les données (pas de spinner, pas d'interruption de la saisie). Sur `ExchangePage`, le défilement automatique ne se déclenche que si le nombre de messages a réellement augmenté. Le polling est mis en pause pendant un envoi ou une mise à jour de statut en cours pour éviter les appels concurrents inutiles.
**Limite connue :** reste du polling, pas du temps réel — acceptable à l'échelle actuelle de l'app, mais à revoir si le volume de messages augmente.

---

## Audit de sécurité — Troisième passe (2026-07-08)

### S13. Aucun rate limiting sur les routes de signalement et de messagerie ✅ RÉSOLU

**Fichiers :** `haven_backend/src/app/api/reports/route.ts` (POST), `reports/[id]/route.ts` (PATCH), `reports/[id]/escalate/route.ts`, `reports/[id]/messages/route.ts`, `reports/mine/[id]/messages/route.ts`
**Sévérité :** HIGH | **Confiance :** 8/10
**Description :** Aucune route sous `api/reports/**` n'appelait `rateLimit`, contrairement à `login`, `register` et aux routes `admin/*`. Ces routes sont authentifiées, donc pas brute-forçables au sens classique, mais rien n'empêchait un compte légitime (élève ou staff) de les appeler en boucle.
**Impact :** Le plus grave concernait la messagerie — chaque message déclenche une notification push (`sendPushToUsers`, elle-même sans limite). Un compte élève ou staff compromis pouvait donc harceler l'autre partie via son propre canal de signalement, ou épuiser le quota Firebase Cloud Messaging. `POST /api/reports` sans limite permettait aussi de noyer la file de triage du staff sous de faux signalements. Particulièrement problématique dans une application dont la raison d'être est de protéger contre le harcèlement.
**Correction appliquée :** Ajout de `rateLimitKeyForUser(userId, scope)` dans `lib/rateLimit.ts` — une variante de `rateLimitKey` qui limite par utilisateur plutôt que par IP (plus pertinent pour des routes déjà authentifiées, où plusieurs élèves peuvent partager une IP scolaire). Appliqué sur les 5 routes :

- Messagerie (élève → staff et staff → élève) : 20 messages / 5 min / utilisateur
- Création de signalement : 10 / 15 min / utilisateur
- Changement de statut : 30 / 5 min / utilisateur (budget plus large — usage normal du staff en session de triage)
- Escalade : 15 / 5 min / utilisateur

Chaque dépassement retourne `429` avec un en-tête `Retry-After`, sur le même modèle que les routes déjà protégées.
