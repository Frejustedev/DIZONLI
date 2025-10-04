# 🚧 Phase 6 : Système Social et Fil d'Actualité - EN COURS

## 📋 Résumé de la Phase 6

Le système social est en cours d'implémentation avec les posts, commentaires, likes et gestion des amis.

---

## ✅ Ce qui a été complété

### 1. **Modèles de Données**

#### PostModel (`post_model.dart`)
- ✅ Types de posts : achievement, badge, challenge, custom
- ✅ Visibilité : public, friends, private
- ✅ Likes et compteur
- ✅ Commentaires intégrés
- ✅ Métadonnées (userId, userName, photoURL, timestamps)

#### FriendshipModel (`friendship_model.dart`)
- ✅ Statuts : pending, accepted, blocked
- ✅ Tracking de l'expéditeur de la demande
- ✅ Génération automatique d'ID (userId1_userId2 triés)

#### Comment (intégré dans PostModel)
- ✅ Commentaires avec auteur et timestamp
- ✅ Stockés directement dans le post

### 2. **Services Backend**

#### SocialService (`social_service.dart`)
- ✅ Création de posts
- ✅ Stream de posts publics
- ✅ Stream de posts d'un utilisateur
- ✅ Stream de posts des amis
- ✅ Like/Unlike
- ✅ Ajout de commentaires
- ✅ Suppression et mise à jour de posts
- ✅ Création automatique de posts pour achievements

#### FriendshipService (`friendship_service.dart`)
- ✅ Envoi de demandes d'ami
- ✅ Acceptation/Refus de demandes
- ✅ Suppression d'amis
- ✅ Blocage d'utilisateurs
- ✅ Stream des demandes en attente
- ✅ Stream des demandes envoyées
- ✅ Recherche d'utilisateurs par nom
- ✅ Vérification du statut d'amitié
- ✅ Récupération des profils d'amis

---

## 🔄 En cours de développement

### 3. **Provider Social** (`social_provider.dart`)
- ⏳ Gestion d'état pour les posts
- ⏳ Gestion d'état pour les amis
- ⏳ Cache local des posts
- ⏳ Gestion des notifications sociales

### 4. **Widgets**

#### PostCard (`post_card.dart`)
- ⏳ Affichage d'un post
- ⏳ Bouton like avec animation
- ⏳ Affichage des commentaires
- ⏳ Menu d'options (éditer, supprimer)
- ⏳ Gestion des différents types de posts

#### CommentWidget (`comment_widget.dart`)
- ⏳ Affichage d'un commentaire
- ⏳ Avatar de l'auteur
- ⏳ Timestamp formaté

#### CreatePostWidget (`create_post_widget.dart`)
- ⏳ Formulaire de création de post
- ⏳ Choix de visibilité
- ⏳ Upload d'image (optionnel)

### 5. **Écrans**

#### SocialFeedScreen (mise à jour)
- ⏳ Fil d'actualité avec onglets (Tous / Amis)
- ⏳ Infinite scroll
- ⏳ Pull to refresh
- ⏳ Bouton de création de post

#### FriendsScreen
- ⏳ Liste des amis
- ⏳ Demandes en attente
- ⏳ Recherche d'amis
- ⏳ Suggestions d'amis

#### UserProfileScreen
- ⏳ Profil public d'un autre utilisateur
- ⏳ Bouton d'ajout/suppression d'ami
- ⏳ Posts de l'utilisateur

---

## 📊 Structure Firestore Utilisée

### Collection `posts`
```javascript
{
  id: string,
  userId: string,
  userName: string,
  userPhotoURL: string,
  type: "achievement" | "badge" | "challenge" | "custom",
  content: string,
  imageUrl: string (optionnel),
  data: {
    steps: number,
    badgeId: string,
    challengeId: string
  },
  likes: [userId],
  likeCount: number,
  comments: [
    {
      userId: string,
      userName: string,
      text: string,
      createdAt: timestamp
    }
  ],
  commentCount: number,
  visibility: "public" | "friends" | "private",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Collection `friendships`
```javascript
{
  id: "userId1_userId2", // IDs triés
  userId1: string,
  userId2: string,
  status: "pending" | "accepted" | "blocked",
  requesterId: string,
  createdAt: timestamp,
  acceptedAt: timestamp (optionnel)
}
```

---

## 🎯 Fonctionnalités Clés

### Posts
- ✅ Création de posts texte avec visibilité
- ✅ Like/Unlike
- ✅ Ajout de commentaires
- ✅ Posts automatiques pour achievements
- ✅ Suppression/Modification par l'auteur
- ✅ Filtrage par visibilité

### Amis
- ✅ Système de demandes d'ami
- ✅ Acceptation/Refus
- ✅ Suppression d'amis
- ✅ Blocage d'utilisateurs
- ✅ Recherche d'utilisateurs
- ✅ Notifications de demandes (à implémenter dans UI)

---

## 🚀 Utilisation des Services

### Créer un Post
```dart
final socialService = SocialService();

await socialService.createPost(
  userId: currentUser.id,
  userName: currentUser.name,
  userPhotoURL: currentUser.photoUrl,
  type: PostType.custom,
  content: 'Mon premier post !',
  visibility: PostVisibility.public,
);
```

### Envoyer une Demande d'Ami
```dart
final friendshipService = FriendshipService();

await friendshipService.sendFriendRequest(
  myUserId,
  targetUserId,
);
```

### Liker un Post
```dart
await socialService.toggleLike(postId, userId);
```

### Ajouter un Commentaire
```dart
await socialService.addComment(
  postId: postId,
  userId: userId,
  userName: userName,
  text: 'Super post !',
);
```

---

## 📝 Prochaines Étapes

1. ⏳ Créer le `SocialProvider` pour gérer l'état
2. ⏳ Créer le widget `PostCard`
3. ⏳ Mettre à jour `SocialFeedScreen`
4. ⏳ Créer `FriendsScreen`
5. ⏳ Ajouter les notifications de demandes d'ami
6. ⏳ Implémenter l'upload d'images pour les posts
7. ⏳ Créer un écran de profil public
8. ⏳ Tester le système complet

---

## 🔧 Fichiers Créés

### Modèles
```
✅ lib/models/post_model.dart
✅ lib/models/friendship_model.dart
```

### Services
```
✅ lib/services/social_service.dart
✅ lib/services/friendship_service.dart
```

### À Créer
```
⏳ lib/providers/social_provider.dart
⏳ lib/widgets/post_card.dart
⏳ lib/widgets/comment_widget.dart
⏳ lib/widgets/create_post_widget.dart
⏳ lib/screens/friends/friends_screen.dart
⏳ lib/screens/profile/user_profile_screen.dart
```

---

## ⚠️ Notes Importantes

- Les posts sont stockés dans Firestore collection `posts`
- Les amitiés utilisent un ID composite trié : `userId1_userId2`
- Les commentaires sont stockés dans un array dans le post (pas de sous-collection)
- Le système de visibilité permet 3 niveaux : public, friends, private
- Les demandes d'ami sont des friendships avec status "pending"
- Le blocage est géré comme une friendship avec status "blocked"

---

## 🎨 Design à Prévoir

- **PostCard** : Card avec avatar, nom, contenu, likes, commentaires
- **FriendsList** : Liste avec avatars, nom, statut en ligne (optionnel)
- **FriendRequest** : Card avec avatar, nom, boutons Accepter/Refuser
- **CommentSection** : Liste de commentaires sous le post
- **CreatePostDialog** : Modal avec textarea et options de visibilité

---

**Date de début** : 3 octobre 2025  
**Projet** : DIZONLI - Application de suivi de pas gamifiée  
**Phase** : 6/? - Système Social et Fil d'Actualité

🚧 **Phase 6 en cours de développement...**

Les services backend sont prêts, il reste à créer l'interface utilisateur !

