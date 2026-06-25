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
