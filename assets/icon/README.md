# Instructions pour changer l'icône de l'application

## 📱 Fichiers nécessaires

Pour changer l'icône de l'application DIZONLI, vous devez placer vos images dans ce dossier :

### 1. **app_icon.png** (obligatoire)
- **Taille** : 1024x1024 pixels minimum
- **Format** : PNG avec fond transparent ou couleur unie
- **Usage** : Icône principale de l'application

### 2. **app_icon_foreground.png** (optionnel pour Android Adaptive Icon)
- **Taille** : 1024x1024 pixels
- **Format** : PNG avec fond transparent
- **Usage** : Élément de premier plan de l'icône adaptative Android

## 🚀 Génération automatique des icônes

Une fois vos images placées dans ce dossier, exécutez :

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Cela générera automatiquement toutes les tailles d'icônes nécessaires pour :
- ✅ Android (toutes les densités : mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ iOS (toutes les tailles requises)
- ✅ Icône adaptative Android avec fond personnalisable

## 🎨 Recommandations de design

### Pour le logo DIZONLI :

1. **Style** : Moderne et minimaliste
2. **Couleurs** : Utiliser les couleurs de la marque
   - Vert principal : #4CAF50
   - Bleu secondaire : #2196F3
   - Orange accent : #FF9800

3. **Éléments suggérés** :
   - 👟 Icône de chaussure de sport
   - 📊 Graphique de progression
   - 🏃 Silhouette en mouvement
   - ⭐ Badge/étoile pour les accomplissements

4. **Simplicité** : L'icône doit rester lisible même à petite taille (48x48px)

## 📋 Checklist

- [ ] Placer `app_icon.png` (1024x1024px) dans ce dossier
- [ ] (Optionnel) Placer `app_icon_foreground.png` pour Android
- [ ] Exécuter `flutter pub run flutter_launcher_icons`
- [ ] Vérifier les icônes générées
- [ ] Recompiler l'application : `flutter build apk --release`

## 🔍 Vérification

Les icônes seront générées dans :
- **Android** : `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS** : `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

**Note** : Si vous n'avez pas encore de logo, vous pouvez utiliser un outil en ligne comme :
- Canva (https://www.canva.com)
- Figma (https://www.figma.com)
- Adobe Express (https://www.adobe.com/express)

