# 🔥 Installation de FlutterFire CLI

FlutterFire CLI n'est pas encore disponible car **Flutter n'est pas installé** sur votre système.

## ⚠️ Prérequis

Pour installer FlutterFire CLI, vous devez d'abord:

1. ✅ Installer Flutter
2. ✅ Installer Firebase CLI
3. ✅ Installer FlutterFire CLI

---

## 📋 Étape par Étape

### **Étape 1: Installer Flutter** (OBLIGATOIRE)

Flutter n'est pas encore installé. **Commencez par là!**

📖 **Suivez le guide complet**: `INSTALL_FLUTTER.md`

**Résumé rapide:**

1. Téléchargez Flutter SDK:
   - https://docs.flutter.dev/get-started/install/windows

2. Extrayez dans `C:\src\flutter`

3. Ajoutez au PATH système:
   ```
   C:\src\flutter\bin
   ```

4. Ouvrez un **nouveau** PowerShell et vérifiez:
   ```bash
   flutter --version
   dart --version
   ```

---

### **Étape 2: Installer Node.js et Firebase CLI**

#### A. Installer Node.js (si pas déjà fait)

1. Téléchargez: https://nodejs.org/ (version LTS)
2. Installez avec les options par défaut
3. Vérifiez:
   ```bash
   node --version
   npm --version
   ```

#### B. Installer Firebase CLI

```bash
npm install -g firebase-tools
```

Vérifiez l'installation:
```bash
firebase --version
```

Connectez-vous à Firebase:
```bash
firebase login
```

---

### **Étape 3: Installer FlutterFire CLI**

Une fois Flutter et Firebase CLI installés:

```bash
dart pub global activate flutterfire_cli
```

#### Ajouter FlutterFire au PATH

Le CLI sera installé dans:
```
%LOCALAPPDATA%\Pub\Cache\bin
```

**Ajoutez ce chemin au PATH système:**

1. Recherchez "Variables d'environnement" dans Windows
2. Variables système → Path → Modifier
3. Nouveau → Ajoutez:
   ```
   %LOCALAPPDATA%\Pub\Cache\bin
   ```
   Ou:
   ```
   C:\Users\agbot\AppData\Local\Pub\Cache\bin
   ```

4. Fermez et rouvrez PowerShell

#### Vérifier l'installation

```bash
flutterfire --version
```

---

## 🔧 Configuration Firebase avec FlutterFire CLI

### **Étape 1: Se connecter à Firebase**

```bash
firebase login
```

### **Étape 2: Configurer le projet**

Dans le dossier DIZONLI:

```bash
cd C:\Users\agbot\Desktop\DIZONLI

# Configure Firebase pour votre projet
flutterfire configure
```

Cette commande va:
1. Vous demander de sélectionner un projet Firebase (ou créer un nouveau)
2. Sélectionner les plateformes (Android, iOS)
3. Générer automatiquement `firebase_options.dart`
4. Configurer les fichiers Android et iOS

### **Étape 3: Importer dans votre code**

Le fichier `lib/firebase_options.dart` sera créé automatiquement.

Dans `lib/main.dart`, décommentez:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisez Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const DizonliApp());
}
```

---

## 🎯 Commandes FlutterFire Utiles

### Configuration initiale
```bash
flutterfire configure
```

### Reconfigurer un projet existant
```bash
flutterfire configure --project=your-project-id
```

### Configurer une plateforme spécifique
```bash
flutterfire configure --platforms=android,ios
```

### Voir l'aide
```bash
flutterfire --help
```

---

## ✅ Vérification Complète

Après installation, vérifiez que tout fonctionne:

```bash
# Flutter installé?
flutter --version

# Dart disponible?
dart --version

# Firebase CLI installé?
firebase --version

# FlutterFire CLI installé?
flutterfire --version
```

**Résultat attendu:**
```
Flutter 3.19.0
Dart SDK 3.3.0
Firebase CLI 13.0.0
FlutterFire CLI 0.3.0
```

---

## ❌ Résolution de Problèmes

### Problème: "dart n'est pas reconnu"

**Solution**: Flutter n'est pas installé ou pas dans le PATH
1. Installez Flutter (voir `INSTALL_FLUTTER.md`)
2. Ajoutez `C:\src\flutter\bin` au PATH
3. **Redémarrez PowerShell**

### Problème: "firebase n'est pas reconnu"

**Solution**: Firebase CLI pas installé
```bash
npm install -g firebase-tools
```

### Problème: "flutterfire n'est pas reconnu"

**Solution**: FlutterFire CLI pas dans le PATH
1. Ajoutez `%LOCALAPPDATA%\Pub\Cache\bin` au PATH
2. Fermez et rouvrez PowerShell
3. Vérifiez: `flutterfire --version`

### Problème: "Permission denied" lors de l'installation

**Solution**: Exécutez PowerShell en tant qu'administrateur
```bash
# PowerShell Admin
dart pub global activate flutterfire_cli
```

### Problème: Firebase login échoue

**Solution**: Problème de navigateur
```bash
firebase login --reauth
```

Ou mode interactif:
```bash
firebase login --no-localhost
```

---

## 📦 Packages Firebase à Installer

Après configuration, installez les packages nécessaires:

```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_messaging
flutter pub add firebase_storage
```

Ou ajoutez dans `pubspec.yaml` (déjà fait dans le projet):
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_messaging: ^14.7.10
```

---

## 🔥 Configuration Manuelle (Alternative)

Si FlutterFire CLI ne fonctionne pas, configuration manuelle:

### Android

1. Créez un projet sur https://console.firebase.google.com/
2. Ajoutez une app Android
3. Package name: `com.dizonli.app`
4. Téléchargez `google-services.json`
5. Placez dans `android/app/`

### iOS

1. Ajoutez une app iOS au projet Firebase
2. Bundle ID: `com.dizonli.app`
3. Téléchargez `GoogleService-Info.plist`
4. Placez dans `ios/Runner/`

### Créer firebase_options.dart

Créez `lib/firebase_options.dart` avec les configurations depuis Firebase Console.

---

## 🎯 Ordre d'Installation Recommandé

```
1. Flutter SDK          ← COMMENCEZ ICI
   └→ dart sera inclus

2. Node.js + npm
   └→ Déjà installé sur votre système

3. Firebase CLI
   └→ npm install -g firebase-tools

4. FlutterFire CLI
   └→ dart pub global activate flutterfire_cli

5. Configuration
   └→ flutterfire configure
```

---

## 📚 Ressources Utiles

- **FlutterFire**: https://firebase.flutter.dev/
- **Firebase Console**: https://console.firebase.google.com/
- **Documentation**: https://firebase.flutter.dev/docs/cli
- **GitHub**: https://github.com/invertase/flutterfire_cli

---

## 🚀 Après Installation

Une fois tout installé:

```bash
cd C:\Users\agbot\Desktop\DIZONLI

# 1. Configurer Firebase
flutterfire configure

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'app
flutter run
```

---

## ⏱️ Temps Estimé

- **Flutter installation**: 30-60 minutes
- **Firebase CLI**: 5 minutes
- **FlutterFire CLI**: 2 minutes
- **Configuration**: 10 minutes

**Total**: ~1-2 heures (première installation)

---

## ✨ Statut Actuel

```
[❌] Flutter SDK        - À installer
[❌] Dart               - Inclus avec Flutter
[?] Node.js/npm         - À vérifier
[❌] Firebase CLI       - À installer
[❌] FlutterFire CLI    - À installer
```

---

## 🎯 Prochaine Action

**→ Installez d'abord Flutter en suivant: `INSTALL_FLUTTER.md`**

Puis revenez à ce guide pour installer FlutterFire CLI.

---

Bon courage! 🚀

