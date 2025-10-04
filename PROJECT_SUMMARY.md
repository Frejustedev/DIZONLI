# 📊 DIZONLI - Résumé du Projet

## 🎯 Vue d'ensemble

DIZONLI est une **application mobile multiplateforme** (Android & iOS) développée avec **Flutter** qui vise à promouvoir l'activité physique à travers:
- Le suivi des pas individuels
- La dynamique de groupe
- L'organisation de Podothons (marathons de pas)
- La gamification et les récompenses
- Une communauté sociale active

---

## 📁 Structure du Projet

```
DIZONLI/
├── lib/                          # Code source Flutter
│   ├── core/                     # Configurations centrales
│   │   ├── constants/
│   │   │   ├── app_colors.dart   # Palette de couleurs
│   │   │   └── app_strings.dart  # Textes de l'app
│   │   └── routes/
│   │       └── app_routes.dart   # Configuration routes
│   │
│   ├── models/                   # Modèles de données
│   │   ├── user_model.dart       # Utilisateur
│   │   ├── group_model.dart      # Groupe
│   │   ├── step_record_model.dart# Enregistrement pas
│   │   ├── challenge_model.dart  # Défi
│   │   └── badge_model.dart      # Badge
│   │
│   ├── providers/                # Gestion d'état
│   │   ├── user_provider.dart    # État utilisateur
│   │   └── step_provider.dart    # État compteur de pas
│   │
│   ├── services/                 # Services backend
│   │   ├── auth_service.dart     # Authentification
│   │   └── step_counter_service.dart # Comptage de pas
│   │
│   ├── screens/                  # Écrans de l'app
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── groups/
│   │   │   └── groups_screen.dart
│   │   ├── challenges/
│   │   │   └── challenges_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── social/
│   │       └── social_feed_screen.dart
│   │
│   ├── widgets/                  # Composants réutilisables
│   │   ├── step_circle.dart      # Cercle de progression
│   │   └── stat_card.dart        # Carte statistique
│   │
│   └── main.dart                 # Point d'entrée
│
├── backend/                      # API Node.js
│   ├── models/                   # Modèles MongoDB
│   │   ├── User.js
│   │   ├── Group.js
│   │   └── StepRecord.js
│   ├── server.js                 # Serveur Express
│   ├── package.json
│   └── README.md
│
├── android/                      # Configuration Android
├── ios/                          # Configuration iOS
├── pubspec.yaml                  # Dépendances Flutter
├── README.md                     # Documentation principale
├── SETUP_GUIDE.md               # Guide d'installation
└── PROJECT_SUMMARY.md           # Ce fichier
```

---

## 🎨 Design & Interface Utilisateur

### Palette de Couleurs

| Couleur | Hex       | Usage                    |
|---------|-----------|--------------------------|
| Vert    | #4CAF50   | Primaire (santé, énergie)|
| Bleu    | #2196F3   | Secondaire (communauté)  |
| Orange  | #FF9800   | Accent (motivation)      |
| Bronze  | #CD7F32   | Niveau Bronze            |
| Silver  | #C0C0C0   | Niveau Silver            |
| Gold    | #FFD700   | Niveau Gold              |
| Champion| #FF6B35   | Niveau Champion          |

### Écrans Principaux

1. **Login/Signup** - Authentification utilisateur
2. **Dashboard** - Vue principale avec cercle de progression des pas
3. **Groups** - Gestion des groupes (Amis, Communauté, Institutions)
4. **Challenges** - Liste des défis et Podothons
5. **Profile** - Profil utilisateur avec statistiques et badges
6. **Social Feed** - Fil d'actualité communautaire

---

## 🔧 Technologies Utilisées

### Frontend (Mobile)
- **Framework**: Flutter 3.10+
- **Langage**: Dart
- **State Management**: Provider
- **UI**: Material Design 3

### Backend (API)
- **Runtime**: Node.js 14+
- **Framework**: Express.js
- **Base de données**: MongoDB
- **Auth**: Firebase Authentication

### Services Cloud
- **Firebase**: Auth, Firestore, Cloud Messaging
- **Google Fit API**: Synchronisation Android
- **Apple HealthKit**: Synchronisation iOS

### Packages Flutter Principaux

```yaml
dependencies:
  # State & Navigation
  provider: ^6.0.5
  go_router: ^12.0.0
  
  # Step Counter
  pedometer: ^4.0.2
  health: ^10.0.0
  permission_handler: ^11.0.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_messaging: ^14.7.10
  
  # UI & Charts
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.2.7
  cached_network_image: ^3.3.0
  
  # Utils
  http: ^1.1.0
  shared_preferences: ^2.2.2
  intl: ^0.19.0
```

---

## 📱 Fonctionnalités Implémentées

### ✅ Phase 1 - Complétée
- [x] Structure du projet Flutter
- [x] Configuration multiplateforme (Android/iOS)
- [x] Écrans d'authentification (Login/Signup)
- [x] Service d'authentification Firebase
- [x] Service de comptage de pas (Pedometer)
- [x] Dashboard avec cercle de progression
- [x] Cartes statistiques (distance, calories)
- [x] Gestion d'état avec Provider
- [x] Écran de profil utilisateur
- [x] Écran de groupes (3 types)
- [x] Écran de défis et Podothons
- [x] Fil social communautaire
- [x] Navigation entre écrans
- [x] Modèles de données
- [x] Backend Node.js (structure de base)
- [x] Modèles MongoDB
- [x] Documentation complète

### 🔄 À Implémenter (Phases suivantes)
- [ ] Intégration Firebase complète
- [ ] API Backend fonctionnelle
- [ ] Synchronisation Google Fit / HealthKit
- [ ] Système de badges complet
- [ ] Génération de certificats PDF
- [ ] Notifications push
- [ ] Chat/Messages dans groupes
- [ ] Partage sur réseaux sociaux
- [ ] Mode sombre
- [ ] Multilingue (Français/Anglais)
- [ ] Tests unitaires et d'intégration
- [ ] CI/CD Pipeline

---

## 🚀 Comment Démarrer

### Installation Rapide

```bash
# 1. Cloner le projet
git clone https://github.com/votre-repo/dizonli.git
cd dizonli

# 2. Installer les dépendances Flutter
flutter pub get

# 3. Lancer l'application
flutter run
```

### Configuration Firebase (Obligatoire)

1. Créer un projet sur [Firebase Console](https://console.firebase.google.com/)
2. Télécharger `google-services.json` → `android/app/`
3. Télécharger `GoogleService-Info.plist` → `ios/Runner/`
4. Activer Authentication et Firestore

### Lancer le Backend (Optionnel pour MVP)

```bash
cd backend
npm install
cp env.example .env
npm run dev
```

Voir **SETUP_GUIDE.md** pour les instructions détaillées.

---

## 📊 Modèles de Données

### User Model
```dart
{
  id: String,
  email: String,
  name: String,
  age: int,
  gender: String,
  location: String,
  dailyGoal: int,          // Défaut: 10000
  userLevel: String,       // Bronze, Silver, Gold, Champion
  totalSteps: int,
  totalDistance: int,
  totalCalories: int,
  groupIds: List<String>,
  createdAt: DateTime
}
```

### Group Model
```dart
{
  id: String,
  name: String,
  type: GroupType,         // friends, community, institution
  adminId: String,
  memberIds: List<String>,
  totalSteps: int,
  inviteCode: String,
  createdAt: DateTime
}
```

### Challenge Model
```dart
{
  id: String,
  name: String,
  type: ChallengeType,     // individual, group, podothon
  mode: ChallengeMode,     // competitive, fun
  targetSteps: int,
  startDate: DateTime,
  endDate: DateTime,
  participantIds: List<String>
}
```

---

## 🎮 Système de Gamification

### Niveaux Utilisateur

| Niveau    | Icône | Pas Requis    | Couleur  |
|-----------|-------|---------------|----------|
| Bronze    | 🥉    | 0 - 100K      | #CD7F32  |
| Silver    | 🥈    | 100K - 500K   | #C0C0C0  |
| Gold      | 🥇    | 500K - 1M     | #FFD700  |
| Champion  | 👑    | > 1M          | #FF6B35  |

### Types de Badges
- Badges quotidiens (atteindre objectif)
- Badges hebdomadaires
- Badges de défis
- Badges de Podothons
- Badges de communauté

---

## 🔐 Sécurité & Confidentialité

- Authentification sécurisée via Firebase
- Chiffrement des données en transit (HTTPS)
- Permissions minimales (Activity Recognition)
- Données de santé protégées
- Conformité RGPD
- Possibilité d'anonymiser les données dans les classements

---

## 📈 Métriques Clés

### Calculs Automatiques
- **Distance**: `steps × 0.762 mètres`
- **Calories**: `steps × 0.04 calories`
- **Progression**: `(steps_today / daily_goal) × 100%`

### Objectifs Recommandés
- **OMS**: 10 000 pas/jour
- **Minimum**: 5 000 pas/jour
- **Actif**: 15 000+ pas/jour

---

## 🌍 Déploiement

### App Store (iOS)
1. Configurer certificats Apple Developer
2. Build release: `flutter build ios --release`
3. Upload via Xcode ou Transporter
4. Soumettre pour review

### Play Store (Android)
1. Créer compte Google Play Console
2. Build APK/Bundle: `flutter build apk --release`
3. Upload sur Play Console
4. Publier

---

## 📞 Support & Contact

- **Email**: contact@dizonli.app
- **Documentation**: [GitHub Wiki](https://github.com/votre-repo/dizonli/wiki)
- **Issues**: [GitHub Issues](https://github.com/votre-repo/dizonli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/votre-repo/dizonli/discussions)

---

## 🤝 Contribution

Les contributions sont bienvenues! Voir **CONTRIBUTING.md** pour les guidelines.

### Process
1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push et créer une Pull Request

---

## 📄 Licence

MIT License - Voir **LICENSE** pour détails.

---

## 🎯 Roadmap

### Q1 2024 - MVP
- ✅ Structure de base
- ✅ Authentification
- ✅ Podomètre
- ✅ UI principale

### Q2 2024 - Groupes
- 🔄 API Backend complète
- 🔄 Gestion groupes avancée
- 🔄 Classements temps réel

### Q3 2024 - Podothons
- 📅 Création de Podothons
- 📅 Système de certificats
- 📅 Notifications push

### Q4 2024 - Lancement
- 📅 Tests beta
- 📅 Publication stores
- 📅 Campagne marketing

---

**Version**: 1.0.0  
**Dernière mise à jour**: Octobre 2024  
**Statut**: ✅ Phase MVP Complétée

---

🚶‍♂️ **DIZONLI - Marchons ensemble vers une meilleure santé!** 💚

