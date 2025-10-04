# 🏃‍♂️ DIZONLI - Application de Suivi de Pas et Défis Sportifs

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
</p>

## 📱 À propos

**DIZONLI** est une application mobile Flutter complète de suivi d'activité physique et de défis sportifs. L'application permet aux utilisateurs de :

- 📊 Suivre leurs pas quotidiens avec des objectifs personnalisables
- 🏆 Participer à des défis avec leurs amis
- 👥 Créer et rejoindre des groupes
- 🏅 Débloquer des badges pour leurs accomplissements
- 📱 Partager leurs progrès sur le fil social
- 📈 Visualiser leurs statistiques et analytics

## ✨ Fonctionnalités principales

### 🎯 Suivi d'activité
- Compteur de pas en temps réel
- Calcul automatique de la distance et des calories
- Graphiques de progression hebdomadaire
- Objectifs quotidiens personnalisables

### 🏆 Système de défis
- Création de défis personnalisés (pas, distance, durée, séries)
- Défis publics et privés
- Portées variées (personnel, groupe, amis, global)
- Suivi de progression en temps réel

### 👥 Groupes et social
- Création de groupes avec code d'invitation
- Fil d'actualité des amis
- Système de likes et commentaires
- Posts automatiques pour les accomplissements

### 🏅 Badges et récompenses
- Collection de badges à débloquer
- Différentes raretés (Commun, Rare, Épique, Légendaire)
- Catégories variées (Exploits, Étapes, Social)
- Notifications de déblocage

### 📊 Analytics
- Statistiques hebdomadaires et mensuelles
- Comparaison de performances
- Distribution d'activité par heure
- Insights personnalisés

## 🛠️ Technologies utilisées

- **Flutter** - Framework UI multiplateforme
- **Firebase Authentication** - Authentification email/password
- **Cloud Firestore** - Base de données NoSQL temps réel
- **Firebase Cloud Messaging** - Notifications push
- **Provider** - Gestion d'état
- **fl_chart** - Graphiques et visualisations
- **health** - Intégration Health Connect / HealthKit

## 📦 Structure du projet

```
lib/
├── core/
│   ├── constants/         # Couleurs, chaînes, routes
│   └── routes/           # Configuration de navigation
├── models/               # Modèles de données
├── providers/            # Gestion d'état (Provider)
├── screens/              # Écrans de l'application
│   ├── auth/            # Authentification
│   ├── dashboard/       # Tableau de bord
│   ├── groups/          # Groupes
│   ├── challenges/      # Défis
│   ├── social/          # Fil social
│   ├── badges/          # Badges
│   └── profile/         # Profil utilisateur
├── services/            # Services (Firebase, API, etc.)
└── widgets/             # Widgets réutilisables
```

## 🚀 Installation

### Prérequis

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode
- Compte Firebase

### Configuration

1. **Cloner le projet**
   ```bash
   git clone https://github.com/Frejustedev/DIZONLI.git
   cd DIZONLI
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configuration Firebase**
   - Créer un projet Firebase sur https://console.firebase.google.com
   - Ajouter une application Android/iOS
   - Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
   - Placer les fichiers dans les répertoires appropriés
   - Générer `firebase_options.dart` :
     ```bash
     flutterfire configure
     ```

4. **Activer les services Firebase**
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Messaging (optionnel)

5. **Configurer les règles Firestore**
   - Copier les règles depuis `FIRESTORE_STRUCTURE.md`
   - Appliquer dans la console Firebase

6. **Lancer l'application**
   ```bash
   flutter run
   ```

## 🔒 Sécurité

⚠️ **Important** : Les fichiers suivants sont ignorés par Git pour des raisons de sécurité :
- `google-services.json`
- `GoogleService-Info.plist`
- `firebase_options.dart`
- `.env` et fichiers d'environnement

Vous devez configurer ces fichiers localement après le clone.

## 📱 Plateformes supportées

- ✅ Android (API 26+)
- ✅ iOS (11.0+)
- ✅ Web (avec limitations pour le compteur de pas)

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Auteurs

- **Frejustedev** - *Développeur principal* - [GitHub](https://github.com/Frejustedev)

## 📞 Contact

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue sur GitHub.

---

<p align="center">
  Fait avec ❤️ en Flutter
</p>