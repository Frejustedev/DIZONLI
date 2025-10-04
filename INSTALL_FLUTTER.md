# 🚀 Guide d'Installation de Flutter pour Windows

Flutter n'est pas encore installé sur votre système. Suivez ce guide pour l'installer.

## 📥 Méthode 1: Installation Rapide (Recommandée)

### Étape 1: Télécharger Flutter SDK

1. Visitez: https://docs.flutter.dev/get-started/install/windows
2. Cliquez sur "Download Flutter SDK"
3. Ou téléchargez directement: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip

### Étape 2: Extraire l'archive

1. Extrayez le fichier ZIP téléchargé
2. Placez le dossier `flutter` dans `C:\src\flutter`
   - **Important**: N'installez PAS dans `C:\Program Files\` (problèmes de permissions)

### Étape 3: Ajouter Flutter au PATH

#### Option A: Interface graphique

1. Recherchez "Variables d'environnement" dans Windows
2. Cliquez sur "Modifier les variables d'environnement système"
3. Cliquez sur "Variables d'environnement"
4. Dans "Variables système", sélectionnez "Path" → "Modifier"
5. Cliquez sur "Nouveau"
6. Ajoutez: `C:\src\flutter\bin`
7. Cliquez sur "OK" pour tout fermer

#### Option B: PowerShell (Admin)

```powershell
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\src\flutter\bin",
    "Machine"
)
```

### Étape 4: Vérifier l'installation

1. **Ouvrez un NOUVEAU PowerShell** (important!)
2. Exécutez:

```bash
flutter --version
```

Vous devriez voir la version de Flutter s'afficher.

### Étape 5: Exécuter Flutter Doctor

```bash
flutter doctor
```

Cette commande vérifie votre environnement et affiche un rapport des outils installés.

---

## 📥 Méthode 2: Installation via Git

Si vous avez Git installé:

```bash
cd C:\src
git clone https://github.com/flutter/flutter.git -b stable
```

Puis suivez les Étapes 3-5 ci-dessus.

---

## 🔧 Installation des Outils Complémentaires

### Android Studio (pour développement Android)

1. Téléchargez: https://developer.android.com/studio
2. Installez Android Studio
3. Lancez Android Studio
4. Allez dans: File → Settings → Plugins
5. Installez les plugins "Flutter" et "Dart"
6. Redémarrez Android Studio

### Configuration Android SDK

```bash
flutter doctor --android-licenses
```

Acceptez toutes les licences (tapez 'y' pour chaque).

### Visual Studio Code (Éditeur léger recommandé)

1. Téléchargez: https://code.visualstudio.com/
2. Installez VS Code
3. Ouvrez VS Code
4. Allez dans Extensions (Ctrl+Shift+X)
5. Installez:
   - Extension "Flutter"
   - Extension "Dart"

---

## ✅ Vérification Complète

Après installation, exécutez:

```bash
flutter doctor -v
```

### Résultat attendu:

```
[✓] Flutter (Channel stable, 3.19.0, on Microsoft Windows...)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85)
[✓] Connected device (1 available)
[✓] Network resources
```

---

## 🎯 Prochaines Étapes

Une fois Flutter installé:

1. Revenez dans le dossier DIZONLI:
```bash
cd C:\Users\agbot\Desktop\DIZONLI
```

2. Installez les dépendances:
```bash
flutter pub get
```

3. Vérifiez les appareils disponibles:
```bash
flutter devices
```

4. Lancez l'application:
```bash
flutter run
```

---

## ❌ Résolution de Problèmes

### Problème: "flutter n'est pas reconnu"

**Solution**: 
1. Vérifiez que `C:\src\flutter\bin` est bien dans le PATH
2. **Fermez et rouvrez** PowerShell/CMD
3. Redémarrez votre ordinateur si nécessaire

### Problème: "Android license status unknown"

**Solution**:
```bash
flutter doctor --android-licenses
```

### Problème: "cmdline-tools component is missing"

**Solution**:
1. Ouvrez Android Studio
2. File → Settings → Appearance & Behavior → System Settings → Android SDK
3. SDK Tools tab
4. Cochez "Android SDK Command-line Tools"
5. Cliquez Apply

### Problème: Erreur de certificat réseau

**Solution**:
```bash
git config --global http.sslVerify false
flutter doctor
```

---

## 📚 Ressources Utiles

- **Documentation officielle**: https://docs.flutter.dev/
- **Codelabs Flutter**: https://docs.flutter.dev/codelabs
- **Flutter YouTube**: https://www.youtube.com/c/flutterdev
- **Communauté**: https://flutter.dev/community

---

## 🆘 Besoin d'Aide?

Si vous rencontrez des problèmes:

1. Consultez: https://docs.flutter.dev/get-started/install/windows/troubleshooting
2. Recherchez votre erreur sur: https://stackoverflow.com/questions/tagged/flutter
3. Demandez sur: https://discord.gg/flutter

---

**Temps estimé d'installation**: 30-60 minutes (selon connexion internet)

Bonne installation! 🚀

