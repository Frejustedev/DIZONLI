# 🔥 Configuration Firebase Storage - DIZONLI

## 📋 Vue d'Ensemble

Ce guide explique comment configurer Firebase Storage pour l'application DIZONLI.

---

## 🚀 Déploiement des Règles

### 1. Prérequis
```bash
# Installer Firebase CLI si nécessaire
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Initialiser Firebase (si pas déjà fait)
firebase init storage
```

### 2. Déployer les Règles
```bash
# Déployer uniquement les règles Storage
firebase deploy --only storage

# Ou déployer tout
firebase deploy
```

### 3. Vérifier le Déploiement
1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionner votre projet DIZONLI
3. Aller dans **Storage** → **Rules**
4. Vérifier que les règles sont bien déployées

---

## 📁 Structure du Stockage

```
/
├── users/
│   └── {userId}/
│       └── profile/
│           └── profile_{uuid}.jpg
│
├── posts/
│   └── {userId}/
│       └── {postId}/
│           ├── post_{postId}_0_{uuid}.jpg
│           ├── post_{postId}_1_{uuid}.jpg
│           └── ...
│
├── groups/
│   └── {groupId}/
│       └── group_{uuid}.jpg
│
├── challenges/
│   └── {challengeId}/
│       └── {imageId}.jpg
│
├── badges/
│   └── {badgeId}.png
│
└── temp/
    └── {userId}/
        └── temp_{uuid}.jpg
```

---

## 🔒 Règles de Sécurité

### Photos de Profil
- **Lecture:** 🌐 Public (tout le monde)
- **Écriture:** 👤 Propriétaire uniquement
- **Suppression:** 👤 Propriétaire uniquement
- **Taille max:** 5 MB
- **Formats:** Images uniquement

### Images de Posts
- **Lecture:** 🔐 Utilisateurs authentifiés
- **Écriture:** 👤 Propriétaire uniquement
- **Suppression:** 👤 Propriétaire uniquement
- **Taille max:** 5 MB
- **Formats:** Images uniquement
- **Limite:** 4 images par post

### Images de Groupes
- **Lecture:** 🔐 Utilisateurs authentifiés
- **Écriture:** 👥 Membres du groupe
- **Suppression:** 👑 Admins du groupe
- **Taille max:** 5 MB
- **Formats:** Images uniquement

---

## ⚙️ Configuration Côté Client

### 1. Ajouter les Dépendances (✅ Déjà fait)
```yaml
# pubspec.yaml
dependencies:
  firebase_storage: ^12.4.0
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
```

### 2. Services Créés
- ✅ `StorageService` - Gestion upload/suppression
- ✅ `ImagePickerHelper` - Sélection et recadrage
- ✅ `EditableProfileAvatar` - Avatar de profil éditable
- ✅ `CreatePostDialog` - Création de posts avec images

---

## 🧪 Tests à Effectuer

### Test 1: Upload Photo de Profil
1. Ouvrir l'app
2. Aller sur le profil
3. Cliquer sur l'icône caméra
4. Sélectionner une image
5. Recadrer
6. Vérifier l'upload

### Test 2: Upload Images Post
1. Aller sur le fil social
2. Cliquer sur le FAB +
3. Écrire un message
4. Ajouter 1-4 images
5. Publier
6. Vérifier les images dans le post

### Test 3: Suppression Photo de Profil
1. Profil → Icône caméra
2. "Supprimer la photo"
3. Confirmer
4. Vérifier la suppression

### Test 4: Permissions
1. Tenter d'uploader sans connexion → ❌ Échec attendu
2. Tenter d'uploader une vidéo → ❌ Échec attendu
3. Tenter d'uploader un fichier > 5MB → ❌ Échec attendu

---

## 🔧 Troubleshooting

### Erreur: "Permission denied"
**Cause:** Règles trop restrictives ou utilisateur non authentifié

**Solution:**
1. Vérifier que l'utilisateur est connecté
2. Vérifier que les règles sont déployées
3. Vérifier les logs Firebase Console

### Erreur: "File too large"
**Cause:** Fichier > 5MB

**Solution:**
1. Compresser l'image côté client
2. Informer l'utilisateur de la limite
3. Utiliser `flutter_image_compress` pour réduire la taille

### Erreur: "Invalid file type"
**Cause:** Le fichier n'est pas une image

**Solution:**
1. Vérifier le type MIME
2. Filtrer les sélections dans `ImagePicker`
3. Afficher un message d'erreur explicite

---

## 📊 Monitoring

### Métriques à Surveiller
1. **Utilisation du stockage** (GB utilisés)
2. **Nombre d'uploads** (par jour/mois)
3. **Nombre de téléchargements** (bande passante)
4. **Erreurs 403** (permissions refusées)
5. **Taille moyenne des fichiers**

### Alertes à Configurer
- ⚠️ Utilisation > 80% du quota
- ⚠️ Taux d'erreur > 5%
- ⚠️ Temps de réponse > 3s
- ⚠️ Fichiers orphelins (sans référence Firestore)

---

## 🚀 Optimisations Futures

### 1. Compression Automatique
```dart
// Ajouter flutter_image_compress
dependencies:
  flutter_image_compress: ^2.1.0

// Implémenter dans StorageService
Future<File> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 85,
    minWidth: 1920,
    minHeight: 1920,
  );
  return result!;
}
```

### 2. Thumbnails avec Cloud Functions
```javascript
// functions/index.js
exports.generateThumbnail = functions.storage.object().onFinalize(async (object) => {
  // Générer une miniature pour les images de profil et posts
  // Réduire la bande passante pour les listes
});
```

### 3. Nettoyage Automatique
```javascript
// Supprimer les fichiers temporaires > 24h
// Supprimer les images des comptes supprimés
// Archiver les vieilles images
```

### 4. CDN et Caching
- Activer Firebase CDN automatiquement
- Configurer les headers de cache (déjà dans les règles)
- Utiliser des URLs signées pour les ressources privées

---

## 📝 Checklist de Déploiement

- [ ] Règles Storage déployées
- [ ] Tests d'upload effectués
- [ ] Tests de suppression effectués
- [ ] Tests de permissions effectués
- [ ] Monitoring configuré
- [ ] Alertes configurées
- [ ] Documentation équipe mise à jour

---

## 🔗 Ressources

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Image Optimization Best Practices](https://firebase.google.com/docs/storage/best-practices)
- [Storage Pricing](https://firebase.google.com/pricing)

---

## 📞 Support

Pour toute question sur la configuration Storage:
1. Consulter les logs Firebase Console
2. Vérifier les règles de sécurité
3. Tester avec Firebase Emulator
4. Contacter l'équipe DevOps

---

*Dernière mise à jour: 7 Octobre 2025*
