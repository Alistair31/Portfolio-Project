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

**Effet de bord nécessaire :** le bloc `datasource` de `schema.prisma` contenait encore `url = env("DATABASE_URL")`, non supporté par le Prisma **7.8.0** réellement installé (l'URL est fournie par `prisma.config.ts`). Ligne retirée pour permettre `prisma generate`. À noter : `package.json`/`package-lock.json` épinglent encore Prisma `6.19.3` alors que node_modules et le client généré committé sont en `7.8.0` — incohérence de versions à réconcilier séparément.

**Étape manuelle restante :** appliquer la migration à la base (`prisma migrate deploy`) — non exécutée automatiquement car la base est hébergée (`db.prisma.io`).

---

### Bug #26 — Navbar cassée depuis l'Espace Safe ✅ RÉSOLU

**Fichier :** `haven_app/lib/pages/student/safe_space_page.dart`
**Sévérité :** MEDIUM | **Confiance :** 10/10
**Description :** Depuis l'Espace Safe, la barre de navigation basse était inopérante. Son handler `_onTabTap` ne gérait que les index 0 et 2 par un simple `Navigator.maybePop()`, et le `onCenterTap` faisait lui aussi `maybePop()` :
- **Suivi** (index 1) : aucune action, l'onglet ne répondait pas.
- **Compte** (index 2) : ramenait à l'Accueil au lieu d'ouvrir la page Compte.
- **« + »** (bouton central) : ramenait à l'Accueil au lieu d'ouvrir le flux de signalement.

Seul **Accueil** (index 0) fonctionnait (retour à la home via `maybePop`).
**Impact :** Un élève dans l'Espace Safe (page de décompression, contexte sensible) se retrouvait piégé : impossible d'atteindre Suivi, Compte ou de lancer un signalement sans repasser par l'accueil.
**Correction appliquée :** Réécriture de `_onTabTap` sur le même modèle que `SuiviPage` — Accueil → `maybePop()`, Suivi → `push(SuiviPage)`, Compte → `push(AccountPage)` — et ajout de `_openReportFlow()` (`push(ReportTargetPage)`) câblé sur `onCenterTap`. Imports `suivi_page.dart`, `account_page.dart` et `report/report_target_page.dart` ajoutés.

---

### Bug #27 — Transfert au Rectorat sort le signalement des stats du niveau/école d'origine ✅ RÉSOLU

**Fichiers :**
- `haven_backend/prisma/schema.prisma` (+ migration `add_escalated_from_level`)
- `haven_backend/src/app/api/reports/[id]/escalate/route.ts`
- `haven_backend/src/app/api/stats/route.ts`
- `haven_backend/src/app/api/stats/timeline/route.ts`

**Sévérité :** HIGH | **Confiance :** 9/10
**Description :** L'escalade (`POST /api/reports/[id]/escalate`) faisait passer `targetLevel` à `RECTORAT`. Or les deux routes de statistiques du staff non-Rectorat filtrent sur `targetLevel = user.role` (`stats/route.ts` via Prisma `where`, `stats/timeline/route.ts` via `AND r."targetLevel" = ${user.role}` en SQL brut). Dès qu'un professeur transférait un signalement au Rectorat, ce dernier ne matchait plus le filtre `TEACHER` (idem `DIRECTOR_CPE`) : il disparaissait de la liste active du prof **et** de ses statistiques — total, taux de résolution, répartitions et courbe d'évolution. L'école d'origine (portée par `author.schoolCode`, inchangé) voyait donc son décompte sous-évalué.
**Impact :** Statistiques faussées à chaque transfert. Un lycée pouvait masquer/perdre des incidents réels de ses indicateurs simplement en escaladant, ce qui compromet le pilotage pHARe et la fiabilité des chiffres remontés.
**Correction appliquée :**

- Champ `escalatedFromLevel Role?` ajouté au modèle `Report` (null = jamais escaladé), migration `add_escalated_from_level`.
- La route d'escalade renseigne `escalatedFromLevel = targetLevel` d'origine tout en passant `targetLevel` à `RECTORAT` (le routage/l'accès Rectorat restent inchangés).
- `stats/route.ts` : le filtre niveau devient `OR: [{ targetLevel: role }, { escalatedFromLevel: role }]` (école toujours contrainte par `author.schoolCode`).
- `stats/timeline/route.ts` : `AND (r."targetLevel" = ${role} OR r."escalatedFromLevel" = ${role})`.

Résultat : un signalement transféré reste comptabilisé dans les stats du niveau et de l'école d'origine, sans double comptage (le Rectorat agrège déjà `where: {}`).

**Note de périmètre :** volontairement, le signalement transféré **quitte la liste de travail active** du prof (il relève désormais du Rectorat) — seule l'attribution statistique est corrigée. Si l'on souhaite aussi le garder visible (en lecture seule, badge « Transféré ») côté prof, c'est un ajustement séparé à demander.

**Étape manuelle restante :** appliquer la migration (`prisma migrate deploy`) — comme #25, non exécutée automatiquement (base hébergée).

---

### Amélioration #28 — Aperçu statistique sur la page d'accueil staff ✅ FAIT

**Fichier :** `haven_app/lib/pages/staff/staff_home_page.dart`
**Type :** Ergonomie / remplissage de page
**Contexte :** La home staff n'affichait que la liste des suivis ; les statistiques n'étaient accessibles que via une page séparée. Sans signalement, la page paraissait très vide (grand `SliverFillRemaining` centré sur « Aucun signalement »).
**Amélioration appliquée :**

- Ajout d'un chargement des stats (`getStats`) sur la home, indépendant du filtre de statut de la liste et non bloquant (si l'appel échoue, l'aperçu est simplement masqué).
- Nouveau widget `_MiniStats` (+ `_StatPill`) : carte compacte « Aperçu » sous la liste des suivis, avec total, taux de résolution, et 3 pastilles En attente / En cours / Clôturés (couleurs cohérentes avec les badges de statut). Lien « Voir tout → » vers la page Statistiques complète.
- État vide compact (`SliverToBoxAdapter` au lieu du `SliverFillRemaining` plein écran) : l'aperçu s'affiche juste en dessous et remplit la page même sans signalement. Message adapté selon qu'un filtre est actif (« Aucun signalement. » / « Aucun signalement pour ce filtre. »).
- `RefreshIndicator` (pull-to-refresh) et le retour depuis le détail rafraîchissent désormais liste **et** stats (`_refresh`).

Aucun changement backend : réutilisation de l'endpoint `GET /api/stats` existant.
