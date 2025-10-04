# 🔥 Instructions Configuration Firebase - DIZONLI

## ✅ Ce qui est déjà fait:

- ✅ Flutter installé (3.35.5)
- ✅ FlutterFire CLI installé (1.3.1)
- ✅ Firebase CLI installé (14.18.0)
- ✅ Connecté à Firebase (agbotonfrejuste@gmail.com)
- ✅ Projet Firebase "dizonli (DIZONLI)" existe déjà

---

## 🎯 Configuration Finale

### Étape 1: Lancer la configuration

```bash
flutterfire configure
```

### Étape 2: Sélectionner le projet

Dans la liste, **sélectionnez**:
```
❯ dizonli (DIZONLI)
```

Utilisez les flèches ↑↓ et appuyez sur Entrée.

### Étape 3: Sélectionner les plateformes

Quand demandé, sélectionnez les plateformes:
- ✅ **android** (pour Android)
- ✅ **ios** (pour iOS)
- ✅ **web** (optionnel pour web)
- ❌ **windows** (pas encore supporté par Firebase)

### Étape 4: Confirmation

FlutterFire va automatiquement:
1. Créer `lib/firebase_options.dart`
2. Configurer `android/app/google-services.json`
3. Configurer `ios/Runner/GoogleService-Info.plist`
4. Mettre à jour les configurations

---

## 🔧 Après Configuration

### 1. Activer Authentication dans Firebase Console

1. Allez sur https://console.firebase.google.com/
2. Sélectionnez le projet **dizonli**
3. Cliquez sur **Authentication** dans le menu
4. Cliquez sur **Get Started**
5. Activez **Email/Password**:
   - Cliquez sur "Email/Password"
   - Activez le premier switch
   - Cliquez "Save"

### 2. Créer Firestore Database

1. Dans Firebase Console → **Firestore Database**
2. Cliquez sur **Create database**
3. Choisissez **"Start in test mode"** (pour le développement)
4. Sélectionnez une région proche (ex: europe-west1)
5. Cliquez **Enable**

### 3. Mettre à jour lib/main.dart

Décommentez l'initialisation Firebase dans `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Décommentez ces lignes:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const DizonliApp());
}
```

### 4. Relancer l'application

```bash
# Arrêter l'app actuelle (si elle tourne)
# Puis relancer
flutter run -d windows
```

---

## ✅ Vérification

Après configuration, vous devriez avoir:

```
DIZONLI/
├── lib/
│   └── firebase_options.dart    ← Nouveau fichier créé
├── android/
│   └── app/
│       └── google-services.json ← Configuré
└── ios/
    └── Runner/
        └── GoogleService-Info.plist ← Configuré
```

---

## 🎯 Commande Complète

```bash
# Dans PowerShell, dans C:\Users\agbot\Desktop\DIZONLI
flutterfire configure

# Sélectionner: dizonli (DIZONLI)
# Plateformes: android, ios, web
```

---

## 🚀 Après Configuration

L'authentification fonctionnera! Vous pourrez:
- ✅ Créer des comptes utilisateurs
- ✅ Se connecter avec email/password
- ✅ Sauvegarder les données dans Firestore
- ✅ Synchroniser entre appareils

---

## 📞 Si Problème

Si erreur pendant la configuration:
1. Vérifiez connexion internet
2. Relancez: `flutterfire configure`
3. Ou configurez manuellement (voir documentation)

---

**Note**: La configuration prend ~2 minutes et doit être faite **une seule fois**.

