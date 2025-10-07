# 📝 Changelog - DIZONLI

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [0.4.0] - 2025-10-07

### 🎉 Ajouté

#### Système Friends Complet
- **FriendsScreen** - Gestion complète des amis avec 3 tabs
  - Liste des amis avec avatars et statistiques
  - Demandes d'ami reçues avec accept/reject
  - Demandes d'ami envoyées avec annulation
  - Menu contextuel (retirer ami, bloquer)
  - États vides personnalisés
- **AddFriendScreen** - Recherche et ajout d'amis
  - Recherche par nom ou email
  - Statuts dynamiques (Amis, En attente, Ajouter)
  - Filtrage intelligent côté client
  - UI Material Design 3

#### Upload d'Images
- **StorageService** - Service complet de gestion du stockage
  - Upload images (profil, posts, groupes)
  - Suppression images
  - Upload multiple
  - Métadonnées automatiques
- **EditableProfileAvatar** - Avatar de profil éditable
  - Dialogue caméra/galerie
  - Recadrage automatique en carré
  - Loading state pendant upload
  - Suppression avec confirmation
- **CreatePostDialog** - Création de posts avec images
  - Multi-sélection images (max 4)
  - Grille d'aperçu 2x2
  - Suppression individuelle
  - Upload automatique
- **ImagePickerHelper** - Helper sélection/recadrage
  - Support Android/iOS/Web
  - Qualité et dimensions configurables
  - Dialogues élégants

#### Partage & Recherche Groupes
- **Partage natif** de codes d'invitation
  - Message formaté avec émojis
  - Support WhatsApp, SMS, Email, etc.
- **Recherche de groupes publics**
  - Dialogue de recherche élégant
  - Filtrage par nom
  - Résultats avec infos complètes
  - Bouton "Rejoindre" fonctionnel

#### Édition de Groupes
- **EditGroupScreen** - Édition pour administrateurs
  - Form pré-rempli avec données actuelles
  - Validation multi-champs
  - Toggle public/privé
  - Metadata non modifiables (sécurité)
  - Refresh automatique après édition

#### Écran Settings
- **SettingsScreen** - Paramètres complets (7 sections)
  - **Profil** - Avatar + nom + email
  - **Objectifs** - Slider objectif quotidien (5k-20k pas)
  - **Notifications** - Master switch + sous-options
  - **Confidentialité** - Toggle profil public/privé
  - **À propos** - Version + CGU + Privacy + Contact
  - **Compte** - Déconnexion + Suppression
  - Design Material Design 3

#### Utilitaires
- **UserHelper** - Helper pour compatibilité UserModel
  - getPhotoUrl(), getFirstName(), getLastName(), getUid()
  - Gestion propriétés manquantes
- Permissions iOS ajoutées (Camera, Photo Library)

#### Services
- **FriendshipService** - 4 nouvelles méthodes
  - streamFriends() - Stream IDs amis acceptés
  - deleteFriendship() - Suppression amitié
  - hasPendingRequest() - Vérification demande en attente
- **UserService** - 1 nouvelle méthode
  - searchUsersByName() - Recherche users par nom/email
- **UserProvider** - refreshUser() - Rafraîchir données utilisateur
- **SocialProvider** - refreshFeed() - Rafraîchir le feed

#### Sécurité
- **storage.rules** - Règles Firebase Storage complètes
  - Photos profil (lecture publique, écriture owner)
  - Images posts (lecture auth, écriture owner)
  - Images groupes (lecture auth, écriture membres)
  - Validation taille (5MB max)
  - Validation type (images uniquement)
  - Deny by default

#### Documentation
- ANALYSE_CRITIQUE_COMPLETE.md - Analyse 360° du projet
- PLAN_ACTION_IMMEDIAT.md - Plan 14 jours détaillé
- RESUME_EXECUTIF.md - Vue management
- INDEX_ANALYSE.md - Navigation docs
- NETTOYAGE_ET_AMIS_COMPLETE.md - Étapes 1&2
- ETAPE_3_TODOS_COMPLETE.md - Étape 3
- ETAPE_4_UPLOAD_IMAGES_COMPLETE.md - Étape 4
- FIREBASE_STORAGE_SETUP.md - Guide déploiement Storage
- PROGRESSION_AUJOURD_HUI.md - Récap journée
- SESSION_COMPLETE_7_OCTOBRE.md - Récap session
- JOURNEE_7_OCTOBRE_COMPLETE.md - Récap complet
- TODO.md - Liste tâches organisée
- CHANGELOG.md - Ce fichier

### 🔄 Modifié

#### Navigation
- Ajout route `/settings` dans app_routes.dart
- Ajout bouton Settings dans ProfileScreen AppBar
- Ajout navigation FriendsScreen depuis MiniLeaderboard

#### Screens
- **DashboardScreen** - Fusionné v2, TODO notifications résolu
- **ProfileScreen** - Integration EditableProfileAvatar
- **SocialFeedScreen** - Integration CreatePostDialog
- **GroupDetailsScreen** - Partage natif + navigation EditGroupScreen
- **CreateGroupScreen** - Partage natif implémenté
- **GroupsListScreen** - Dialogue recherche complet

### 🗑️ Supprimé

#### Code Dupliqué
- `lib/services/group_service_NEW.dart` - Doublure supprimée
- `lib/screens/dashboard/dashboard_screen.dart` (old) - Version obsolète
- `lib/screens/dashboard/dashboard_screen_v2.dart` - Fusionné puis supprimé

### 🐛 Corrigé

#### Étape 1 - Nettoyage (3 bugs)
- Code dupliqué supprimé (8% → 0%)
- Navigation TODOs résolus
- Structure clarifiée

#### Étape 2 - Friends (9 bugs)
- photoURL getter manquant → UserHelper créé
- firstName/lastName manquants → UserHelper
- streamFriends() manquant dans FriendshipService
- deleteFriendship() manquant
- hasPendingRequest() manquant
- searchUsersByName() manquant dans UserService
- acceptFriendRequest() signature corrigée
- Imports manquants ajoutés
- Navigation corrigée

#### Étape 3 - TODOs (20 bugs)
- widget.group undefined → paramètre ajouté
- await sans async → async ajouté
- Icons.group_search inexistant → Icons.search
- description.isNotEmpty null check
- searchPublicGroups utilisé
- joinGroup → addGroupMember
- inviteCode null coalescing
- 9 erreurs de compilation corrigées
- 11 warnings linter corrigés

#### Étape 4 - Upload (19 bugs)
- API image_cropper obsolète → API simplifiée
- aspectRatioPresets non supporté → retiré
- WebUiSettings non supporté → retiré
- refreshUser() manquant → ajouté
- refreshFeed() manquant → ajouté
- Constructor PostModel corrigé
- imageUrls → imageUrl
- 10 type safety issues corrigés

### 📊 Métriques

- **Code:** +4,042 lignes
- **Fichiers:** +14 créés, +15 modifiés, -3 supprimés
- **Bugs:** 51 corrigés
- **Complétude:** 70% → 82% (+12%)
- **Erreurs:** 33 → 0
- **Duplication:** 8% → 0%

---

## [0.3.0] - 2025-10-06 (État avant session)

### Existant
- Authentification Firebase (login/signup)
- Dashboard avec progress ring
- Suivi des pas (Pedometer/Health)
- Système de groupes
- Système de défis
- Système de badges
- Feed social basique
- Profil utilisateur
- Notifications Firebase
- Leaderboards

---

## [0.2.0] - 2025-10-05

### Structure Initiale
- Architecture Flutter MVVM
- Firebase Backend (Auth, Firestore, Messaging)
- Providers pour state management
- Services layer
- Widgets réutilisables
- Modèles de données

---

## [0.1.0] - 2025-10-01

### Premier Commit
- Setup projet Flutter
- Configuration Firebase
- Structure dossiers de base

---

## 🔮 À Venir (v0.5.0)

### Planifié
- [ ] Notifications push (demandes amis, likes, comments)
- [ ] Compression images automatique
- [ ] Thumbnails (Cloud Functions)
- [ ] Animations transitions
- [ ] Pull-to-refresh partout
- [ ] Infinite scroll feed
- [ ] Tests unitaires (80% coverage)
- [ ] Tests utilisateurs beta

---

## 📝 Notes

- **Format dates:** YYYY-MM-DD
- **Types de changements:**
  - `Ajouté` pour les nouvelles fonctionnalités
  - `Modifié` pour les changements aux fonctionnalités existantes
  - `Déprécié` pour les fonctionnalités bientôt retirées
  - `Supprimé` pour les fonctionnalités retirées
  - `Corrigé` pour les corrections de bugs
  - `Sécurité` pour les vulnérabilités corrigées

---

**Maintenu par:** L'équipe DIZONLI  
**Dernière mise à jour:** 7 Octobre 2025
