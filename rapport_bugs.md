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

## Audit de sécurité — Vulnérabilités identifiées

### S1. Inscription ouverte sans validation du `schoolCode`

**Fichier :** `haven_backend/src/app/api/auth/register/route.ts`  
**Sévérité :** MEDIUM | **Confiance :** 8/10  
**Description :** N'importe qui peut créer un compte avec n'importe quelle valeur de `schoolCode`. Pas de table `School`, pas de vérification email, pas d'approbation admin.  
**Impact :** Un attaquant externe peut s'inscrire et accéder au système de signalement comme un vrai élève.  
**Correction :** Créer une table `School` avec les codes autorisés, vérifier l'existence du code à l'inscription, ajouter une validation par email.

### S2. Checkbox "Rester connecté" sans effet — token toujours persisté ✅ RÉSOLU

**Fichier :** `haven_app/lib/pages/authentification/login_page.dart:37`  
**Sévérité :** MEDIUM | **Confiance :** 8/10  
**Description :** `_checkbox` est affiché dans l'UI mais jamais lu dans `_handleLogin()`. Le token JWT est sauvegardé inconditionnellement. Aucune fonction logout n'existe.  
**Impact :** Sur un appareil partagé (tablette de classe), l'élève suivant accède automatiquement au compte du précédent malgré la décoché de "Rester connecté".  
**Correction appliquée :**
- `saveToken()` conditionné à `_checkbox` dans `_handleLogin()`
- Widget `LogoutButton` créé (`haven_app/lib/widgets/logout_button.dart`) : supprime le token via `PreferencesService().removeToken()` et redirige vers `LoginPage` en vidant la pile
- Consentement RGPD ajouté à l'inscription : checkbox obligatoire + lien vers `PrivacyPolicyPage`
