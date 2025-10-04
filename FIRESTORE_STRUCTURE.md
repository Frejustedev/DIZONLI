# 🔥 Structure Firestore - DIZONLI

## 📊 Collections et Documents

### 1. **users** (Collection)
Profils des utilisateurs

**Document ID:** User UID (auto-généré par Firebase Auth)

**Structure:**
```javascript
{
  uid: string,              // ID Firebase Auth
  email: string,            // Email de l'utilisateur
  firstName: string,        // Prénom
  lastName: string,         // Nom
  birthDate: timestamp,     // Date de naissance
  age: number,             // Âge calculé
  sex: string,             // "male" | "female" | "other"
  photoURL: string,         // URL photo de profil (optionnel)
  dailyGoal: number,        // Objectif quotidien de pas (défaut: 10000)
  totalSteps: number,       // Total des pas (lifetime)
  totalDistance: number,    // Distance totale (km)
  totalCalories: number,    // Calories totales brûlées
  level: number,            // Niveau gamification (défaut: 1)
  points: number,           // Points accumulés
  badges: [string],         // IDs des badges débloqués
  friends: [string],        // UIDs des amis
  groups: [string],         // IDs des groupes
  createdAt: timestamp,     // Date de création du compte
  lastActive: timestamp,    // Dernière activité
  settings: {
    notifications: boolean,
    publicProfile: boolean,
    shareActivity: boolean
  }
}
```

---

### 2. **steps** (Collection)
Enregistrements quotidiens des pas

**Document ID:** `{userId}_{date}` (ex: `abc123_2025-10-03`)

**Structure:**
```javascript
{
  userId: string,           // UID de l'utilisateur
  date: timestamp,          // Date du jour (minuit)
  steps: number,            // Nombre de pas du jour
  distance: number,         // Distance parcourue (km)
  calories: number,         // Calories brûlées
  hourlyData: [            // Données par heure (optionnel)
    {
      hour: number,        // 0-23
      steps: number
    }
  ],
  goalAchieved: boolean,   // Objectif atteint?
  updatedAt: timestamp     // Dernière mise à jour
}
```

**Index nécessaires:**
- userId (ascending) + date (descending)

---

### 3. **groups** (Collection)
Groupes d'utilisateurs

**Document ID:** Auto-généré

**Structure:**
```javascript
{
  id: string,              // ID du groupe
  name: string,            // Nom du groupe
  description: string,     // Description
  imageUrl: string,        // Image du groupe (optionnel)
  adminId: string,         // UID de l'admin
  members: [              // Liste des membres
    {
      userId: string,
      joinedAt: timestamp,
      role: string        // "admin" | "member"
    }
  ],
  memberCount: number,     // Nombre de membres
  totalSteps: number,      // Total des pas du groupe
  inviteCode: string,      // Code d'invitation unique
  isPublic: boolean,       // Groupe public?
  maxMembers: number,      // Limite de membres (optionnel)
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Index nécessaires:**
- inviteCode (ascending)
- members.userId (ascending)

---

### 4. **challenges** (Collection)
Défis individuels et collectifs

**Document ID:** Auto-généré

**Structure:**
```javascript
{
  id: string,              // ID du défi
  title: string,           // Titre du défi
  description: string,     // Description
  type: string,            // "daily" | "weekly" | "custom" | "group"
  targetSteps: number,     // Objectif de pas
  targetDays: number,      // Nombre de jours (pour défis multi-jours)
  startDate: timestamp,    // Date de début
  endDate: timestamp,      // Date de fin
  creatorId: string,       // UID du créateur
  participants: [         // Liste des participants
    {
      userId: string,
      joinedAt: timestamp,
      currentSteps: number,
      completed: boolean,
      rank: number
    }
  ],
  groupId: string,         // ID du groupe (si défi de groupe)
  isPublic: boolean,       // Défi public?
  reward: {                // Récompense
    type: string,          // "badge" | "points"
    value: number,
    badgeId: string
  },
  status: string,          // "active" | "completed" | "expired"
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Index nécessaires:**
- status (ascending) + endDate (descending)
- participants.userId (ascending)
- groupId (ascending)

---

### 5. **badges** (Collection)
Badges du système

**Document ID:** Badge ID unique

**Structure:**
```javascript
{
  id: string,              // ID unique du badge
  name: string,            // Nom du badge
  description: string,     // Description
  iconUrl: string,         // URL de l'icône
  condition: {             // Condition de déblocage
    type: string,          // "steps_total" | "steps_daily" | "days_streak" | "challenge_win" | "friends_count"
    value: number
  },
  rarity: string,          // "common" | "rare" | "epic" | "legendary"
  points: number,          // Points gagnés
  category: string,        // "achievement" | "milestone" | "social"
  createdAt: timestamp
}
```

**Exemples de badges:**
- Premier Pas (1er jour)
- Marathon (50,000 pas en un jour)
- Régularité (7 jours à 10k pas)
- Leader (1er du classement)
- Social Butterfly (10 amis)

---

### 6. **posts** (Collection)
Publications du fil social

**Document ID:** Auto-généré

**Structure:**
```javascript
{
  id: string,              // ID du post
  userId: string,          // UID de l'auteur
  userName: string,        // Nom de l'auteur (dénormalisé)
  userPhotoURL: string,    // Photo de l'auteur (dénormalisé)
  type: string,            // "achievement" | "badge" | "challenge" | "custom"
  content: string,         // Contenu du post
  imageUrl: string,        // Image (optionnel)
  data: {                  // Données spécifiques selon le type
    badgeId: string,
    challengeId: string,
    steps: number
  },
  likes: [string],         // UIDs des utilisateurs qui ont liké
  likeCount: number,       // Nombre de likes
  comments: [             // Commentaires
    {
      userId: string,
      userName: string,
      text: string,
      createdAt: timestamp
    }
  ],
  commentCount: number,    // Nombre de commentaires
  visibility: string,      // "public" | "friends" | "private"
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Index nécessaires:**
- userId (ascending) + createdAt (descending)
- createdAt (descending) - pour le fil global

---

### 7. **friendships** (Collection)
Relations d'amitié

**Document ID:** `{userId1}_{userId2}` (IDs triés alphabétiquement)

**Structure:**
```javascript
{
  userId1: string,         // UID premier utilisateur
  userId2: string,         // UID deuxième utilisateur
  status: string,          // "pending" | "accepted" | "blocked"
  requesterId: string,     // UID de celui qui a envoyé la demande
  createdAt: timestamp,
  acceptedAt: timestamp
}
```

**Index nécessaires:**
- userId1 (ascending) + status (ascending)
- userId2 (ascending) + status (ascending)

---

### 8. **notifications** (Collection)
Notifications pour les utilisateurs

**Document ID:** Auto-généré

**Structure:**
```javascript
{
  id: string,              // ID de la notification
  userId: string,          // UID du destinataire
  type: string,            // "goal_achieved" | "badge_unlocked" | "challenge_complete" | "friend_request" | "group_invite"
  title: string,           // Titre
  message: string,         // Message
  data: {                  // Données additionnelles
    badgeId: string,
    challengeId: string,
    friendId: string,
    groupId: string
  },
  isRead: boolean,         // Lu?
  createdAt: timestamp
}
```

**Index nécessaires:**
- userId (ascending) + isRead (ascending) + createdAt (descending)

---

## 🔒 Règles de Sécurité Firestore

Créez ces règles dans Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update, delete: if isOwner(userId);
    }
    
    // Steps collection
    match /steps/{stepId} {
      allow read: if isSignedIn();
      allow create, update: if isSignedIn() && 
        isOwner(resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // Groups collection
    match /groups/{groupId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() && 
        (resource.data.adminId == request.auth.uid || 
         request.auth.uid in resource.data.members);
      allow delete: if isSignedIn() && 
        resource.data.adminId == request.auth.uid;
    }
    
    // Challenges collection
    match /challenges/{challengeId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn();
      allow delete: if isSignedIn() && 
        resource.data.creatorId == request.auth.uid;
    }
    
    // Badges collection (read-only for users)
    match /badges/{badgeId} {
      allow read: if isSignedIn();
      allow write: if false; // Only admin/backend can write
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    // Friendships collection
    match /friendships/{friendshipId} {
      allow read: if isSignedIn();
      allow create, update: if isSignedIn() && 
        (request.auth.uid == resource.data.userId1 || 
         request.auth.uid == resource.data.userId2);
      allow delete: if isSignedIn() && 
        (request.auth.uid == resource.data.userId1 || 
         request.auth.uid == resource.data.userId2);
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && 
        isOwner(resource.data.userId);
      allow write: if false; // Only backend can write
    }
  }
}
```

---

## 📝 Prochaines Étapes

1. ✅ **Copier les règles de sécurité** dans Firebase Console
2. ✅ **Créer des badges initiaux** (optionnel - peut être fait par code)
3. ✅ **Tester la création d'utilisateur** depuis l'app
4. ✅ **Implémenter le service Firestore** dans Flutter
5. ✅ **Commencer par le tracking des pas**

---

## 🔧 Services Flutter à créer

Créez ces fichiers dans `lib/services/`:

- `firestore_service.dart` - CRUD Firestore général
- `user_service.dart` - Gestion utilisateurs
- `step_service.dart` - Enregistrement des pas
- `group_service.dart` - Gestion des groupes
- `challenge_service.dart` - Gestion des défis
- `badge_service.dart` - Gestion des badges
- `social_service.dart` - Posts et amis
- `notification_service.dart` - Notifications

---

**Date de création:** 3 octobre 2025  
**Projet:** DIZONLI - Application de suivi de pas gamifiée

