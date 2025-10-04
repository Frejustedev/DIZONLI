# 🚀 Guide d'Installation et Configuration - DIZONLI

Ce guide vous accompagne étape par étape pour installer, configurer et lancer l'application DIZONLI.

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Installation Flutter](#installation-flutter)
3. [Configuration Firebase](#configuration-firebase)
4. [Configuration du Projet](#configuration-du-projet)
5. [Configuration Android](#configuration-android)
6. [Configuration iOS](#configuration-ios)
7. [Backend Setup](#backend-setup)
8. [Lancement de l'Application](#lancement-de-lapplication)
9. [Résolution des Problèmes](#résolution-des-problèmes)

---

## 1. Prérequis

### Système d'exploitation
- Windows 10/11, macOS 10.14+, ou Linux
- Au moins 8 GB RAM
- 10 GB d'espace disque disponible

### Logiciels requis

#### Pour tous les systèmes
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/) ou Android Studio
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.10.0)

#### Pour Android
- [Android Studio](https://developer.android.com/studio)
- Android SDK (API 21+)
- Java JDK 11+

#### Pour iOS (Mac uniquement)
- [Xcode](https://developer.apple.com/xcode/) 14+
- CocoaPods: `sudo gem install cocoapods`

#### Pour le Backend
- [Node.js](https://nodejs.org/) (>= 14.0.0)
- [MongoDB](https://www.mongodb.com/try/download/community) (>= 4.4)

---

## 2. Installation Flutter

### Windows

1. Téléchargez le SDK Flutter depuis [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extrayez l'archive dans `C:\src\flutter`
3. Ajoutez `C:\src\flutter\bin` au PATH système
4. Vérifiez l'installation:
```bash
flutter doctor
```

### macOS

```bash
# Télécharger Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Ajouter au PATH
export PATH="$PATH:~/development/flutter/bin"

# Vérifier
flutter doctor
```

### Linux

```bash
# Télécharger Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Ajouter au PATH dans ~/.bashrc ou ~/.zshrc
export PATH="$PATH:$HOME/development/flutter/bin"

# Vérifier
flutter doctor
```

### Installation des extensions VS Code

1. Ouvrez VS Code
2. Allez dans Extensions (Ctrl+Shift+X)
3. Installez:
   - Flutter
   - Dart
   - Flutter Widget Snippets (optionnel)

---

## 3. Configuration Firebase

### Étape 1: Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Nommez votre projet: `dizonli` ou `dizonli-dev`
4. Suivez les étapes de création

### Étape 2: Activer l'authentification

1. Dans Firebase Console → Authentication
2. Cliquez sur "Commencer"
3. Activez les méthodes:
   - Email/Mot de passe
   - Google (optionnel)
   - Facebook (optionnel)

### Étape 3: Créer Firestore Database

1. Dans Firebase Console → Firestore Database
2. Cliquez sur "Créer une base de données"
3. Choisissez "Commencer en mode test" (à sécuriser plus tard)
4. Sélectionnez une région proche de vos utilisateurs

### Étape 4: Configuration Android

1. Dans Firebase Console → Paramètres du projet
2. Cliquez sur l'icône Android
3. Package name: `com.dizonli.app`
4. Téléchargez `google-services.json`
5. Placez-le dans `android/app/`

### Étape 5: Configuration iOS

1. Dans Firebase Console → Paramètres du projet
2. Cliquez sur l'icône iOS
3. Bundle ID: `com.dizonli.app`
4. Téléchargez `GoogleService-Info.plist`
5. Placez-le dans `ios/Runner/`

---

## 4. Configuration du Projet

### Cloner le projet

```bash
git clone https://github.com/votre-repo/dizonli.git
cd dizonli
```

### Installer les dépendances

```bash
flutter pub get
```

### Vérifier la configuration

```bash
flutter doctor -v
```

Résolvez tous les problèmes signalés par `flutter doctor`.

---

## 5. Configuration Android

### AndroidManifest.xml

Le fichier `android/app/src/main/AndroidManifest.xml` doit contenir:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

### build.gradle

Dans `android/app/build.gradle`, vérifiez:

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.3.1')
}
```

Dans `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

### Google Fit API (optionnel)

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Activez l'API Fitness
3. Créez des identifiants OAuth 2.0

---

## 6. Configuration iOS

### Info.plist

Vérifiez que `ios/Runner/Info.plist` contient les permissions nécessaires (déjà ajouté).

### Podfile

Dans `ios/Podfile`:

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

### Installation des Pods

```bash
cd ios
pod install
cd ..
```

### Apple HealthKit

1. Ouvrez `ios/Runner.xcworkspace` dans Xcode
2. Sélectionnez Runner → Signing & Capabilities
3. Ajoutez "HealthKit"
4. Cochez les permissions nécessaires

---

## 7. Backend Setup

### Installation

```bash
cd backend
npm install
```

### Configuration

```bash
cp env.example .env
```

Éditez `.env`:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/dizonli
JWT_SECRET=votre_secret_jwt_securise
```

### Lancer MongoDB

```bash
# Windows (si installé comme service)
net start MongoDB

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

### Démarrer le serveur

```bash
npm run dev
```

Le serveur démarre sur `http://localhost:5000`

---

## 8. Lancement de l'Application

### Vérifier les appareils disponibles

```bash
flutter devices
```

### Lancer sur Android

```bash
# Émulateur
flutter run

# Appareil physique (activez le mode développeur)
flutter run
```

### Lancer sur iOS (Mac uniquement)

```bash
# Simulateur
flutter run

# Appareil physique
flutter run --release
```

### Mode Debug vs Release

```bash
# Debug (avec hot reload)
flutter run

# Release (optimisé)
flutter run --release
```

---

## 9. Résolution des Problèmes

### Problème: Flutter doctor signale des erreurs

**Solution**: Suivez les instructions de `flutter doctor` pour chaque problème.

```bash
flutter doctor --verbose
```

### Problème: Erreur de dépendances

**Solution**: Nettoyez et réinstallez

```bash
flutter clean
flutter pub get
```

### Problème: Android build failed

**Solution**: 
1. Vérifiez que `google-services.json` est bien placé
2. Nettoyez le build:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problème: iOS build failed

**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Problème: Permission denied (pedometer)

**Solution Android**:
1. Vérifiez AndroidManifest.xml
2. Sur Android 10+, demandez explicitement la permission ACTIVITY_RECOGNITION

**Solution iOS**:
1. Vérifiez Info.plist
2. Assurez-vous que HealthKit est activé dans Xcode

### Problème: Firebase ne se connecte pas

**Solution**:
1. Vérifiez que les fichiers de configuration sont aux bons emplacements
2. Vérifiez les package names / bundle IDs
3. Nettoyez et rebuilder:
```bash
flutter clean
flutter pub get
flutter run
```

### Problème: Backend ne démarre pas

**Solution**:
1. Vérifiez que MongoDB est lancé:
```bash
# Windows
net start MongoDB

# Mac/Linux
sudo systemctl status mongod
```
2. Vérifiez les variables d'environnement dans `.env`
3. Réinstallez les dépendances:
```bash
cd backend
rm -rf node_modules
npm install
```

---

## 📞 Support

Pour des problèmes spécifiques:

1. Consultez la [documentation Flutter](https://flutter.dev/docs)
2. Consultez la [documentation Firebase](https://firebase.google.com/docs)
3. Ouvrez une issue sur GitHub
4. Contactez l'équipe: contact@dizonli.app

---

## ✅ Checklist de Vérification

Avant de commencer le développement:

- [ ] Flutter installé et `flutter doctor` OK
- [ ] Android Studio / Xcode configuré
- [ ] Firebase projet créé
- [ ] Fichiers de configuration Firebase placés
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Backend configuré (optionnel)
- [ ] MongoDB lancé (optionnel)
- [ ] Application lancée avec succès

---

**Félicitations! Vous êtes prêt à développer avec DIZONLI! 🎉**

