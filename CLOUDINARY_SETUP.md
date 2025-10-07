# 🚀 GUIDE SETUP CLOUDINARY

## Configuration en 5 Minutes

### ✅ Étape 1: Créer un Compte Cloudinary (2 min)

1. Aller sur: **https://cloudinary.com/users/register/free**
2. Remplir le formulaire:
   - Email
   - Mot de passe
   - Nom
3. Cliquer **"Create Account"**
4. **PAS DE CARTE BANCAIRE DEMANDÉE** ✅

---

### ✅ Étape 2: Créer un Upload Preset (2 min)

1. Se connecter au dashboard Cloudinary
2. Cliquer sur ⚙️ **Settings** (en haut à droite)
3. Dans le menu de gauche, cliquer **Upload**
4. Faire défiler jusqu'à **Upload presets**
5. Cliquer **Add upload preset**
6. Configurer:
   ```
   Upload preset name: dizonli_app
   Signing Mode: Unsigned ⚠️ IMPORTANT
   Folder: dizonli/
   ```
7. Cliquer **Save**

---

### ✅ Étape 3: Obtenir vos Credentials (30 sec)

1. Retourner au **Dashboard** (logo Cloudinary en haut à gauche)
2. Sur la page d'accueil, vous verrez:
   ```
   Product Environment Credentials
   
   Cloud name:     dzabcdefg          ← COPIER ÇA
   API Key:        123456789012345
   API Secret:     ****************
   ```
3. **Copier votre Cloud Name** (ex: `dzabcdefg`)
4. **Copier votre Upload Preset Name** (ex: `dizonli_app`)

---

### ✅ Étape 4: Configurer dans l'App (30 sec)

1. Ouvrir: `lib/services/cloudinary_service.dart`
2. Trouver les lignes 19-20:
   ```dart
   static const String _cloudName = 'VOTRE_CLOUD_NAME';
   static const String _uploadPreset = 'VOTRE_UPLOAD_PRESET';
   ```
3. Remplacer par VOS valeurs:
   ```dart
   static const String _cloudName = 'dzabcdefg'; // Votre Cloud Name
   static const String _uploadPreset = 'dizonli_app'; // Votre Upload Preset
   ```
4. **Sauvegarder le fichier**

---

### ✅ Étape 5: Installer les Dépendances (1 min)

1. Ouvrir un terminal dans le dossier du projet
2. Exécuter:
   ```bash
   flutter pub get
   ```
3. Attendre que ça finisse (~30 sec)

---

## ✅ C'EST TOUT !

Votre app est maintenant configurée pour utiliser Cloudinary !

---

## 🧪 Tester l'Upload

1. Lancer l'app:
   ```bash
   flutter run
   ```

2. Tester upload photo profil:
   - Aller sur **Profil**
   - Cliquer sur l'**avatar**
   - Sélectionner une photo
   - ✅ Ça devrait marcher !

3. Vérifier sur Cloudinary:
   - Dashboard → **Media Library**
   - Vous devriez voir votre photo dans `dizonli/profiles/`

4. Tester upload images post:
   - Aller sur **Social**
   - Cliquer sur **FAB +**
   - Ajouter images
   - Publier
   - ✅ Ça devrait marcher !

---

## 📊 Vérifier vos Quotas (Optionnel)

1. Dashboard Cloudinary
2. **Settings** → **Usage**
3. Voir:
   ```
   Storage:        0 MB / 25 GB
   Bandwidth:      0 MB / 25 GB
   Transformations: 0 / 25,000
   ```

Vous êtes très loin des limites ! 🎉

---

## ⚙️ Configuration Avancée (Optionnel)

### Sécuriser Upload Preset

Pour production, configurez:

1. **Settings** → **Upload** → Votre preset
2. **Allowed formats**: `jpg, png, jpeg, webp`
3. **Max file size**: `5000000` (5 MB)
4. **Max image width**: `4096`
5. **Max image height**: `4096`
6. **Auto tagging**: `50` (limite tags automatiques)

### Auto-Modération

Cloudinary peut modérer automatiquement les images inappropriées:

1. **Settings** → **Upload** → Votre preset
2. **Moderation**: `Automatic`
3. **Moderation kind**: `aws_rek` (AWS Rekognition)

---

## 🔒 Sécurité

### Données Sensibles

- ⚠️ Ne commitez JAMAIS vos credentials sur Git
- ✅ Pour production, utilisez des variables d'environnement:

```dart
// lib/core/config/cloudinary_config.dart
class CloudinaryConfig {
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'VOTRE_CLOUD_NAME', // Valeur de dev
  );
  
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'VOTRE_UPLOAD_PRESET', // Valeur de dev
  );
}
```

### Build Production

```bash
flutter build apk \
  --dart-define=CLOUDINARY_CLOUD_NAME=dzabcdefg \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=dizonli_app
```

---

## 🐛 Résolution de Problèmes

### Erreur: "Invalid upload preset"

**Solution:**
- Vérifier que Signing Mode = **Unsigned**
- Vérifier l'orthographe du preset name

### Erreur: "Upload failed"

**Solution:**
- Vérifier connexion internet
- Vérifier taille image < 5 MB
- Vérifier format (jpg, png, jpeg)

### Photos n'apparaissent pas

**Solution:**
- Vérifier que l'URL est bien sauvegardée dans Firestore
- Ouvrir l'URL dans navigateur pour vérifier
- Vérifier permissions internet dans AndroidManifest.xml

---

## 📚 Ressources

- **Documentation:** https://cloudinary.com/documentation
- **Dashboard:** https://console.cloudinary.com
- **Support:** https://support.cloudinary.com
- **Status:** https://status.cloudinary.com

---

## 💰 Limites Plan Gratuit

```
✅ 25 GB stockage
✅ 25 GB bande passante/mois
✅ 25,000 transformations/mois
✅ Unlimited images
✅ CDN mondial
✅ Backup automatique
✅ Support communautaire

Suffisant pour:
→ 25,000 photos de profil
→ 100,000+ posts avec images
→ 1,000+ utilisateurs actifs
→ 6-12 mois d'utilisation
```

Si vous dépassez (peu probable):
- Email d'alerte
- Possibilité de migrer vers plan Plus (89$/mois)
- Mais vraiment peu probable pour beta !

---

## ✅ CHECKLIST FINALE

- [ ] Compte Cloudinary créé
- [ ] Upload preset créé (Unsigned)
- [ ] Cloud Name copié
- [ ] Upload Preset name copié
- [ ] Credentials ajoutés dans cloudinary_service.dart
- [ ] `flutter pub get` exécuté
- [ ] App testée (upload photo profil)
- [ ] App testée (upload images post)
- [ ] Photos visibles sur dashboard Cloudinary
- [ ] Photos visibles dans l'app

---

**🎉 SI TOUT EST COCHÉ, VOUS ÊTES PRÊT !**

**Des questions ? Problèmes ? Consultez la section Résolution de Problèmes ou contactez le support Cloudinary.**
