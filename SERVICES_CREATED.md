# ✅ Services Firestore Créés - DIZONLI

## 📦 Services Implémentés

### 1. **firestore_service.dart** - Service de base
✅ **Fonctionnalités:**
- CRUD (Create, Read, Update, Delete) générique
- Requêtes avec filtres
- Streams pour écouter les changements en temps réel
- Batch operations (plusieurs opérations en une transaction)
- Gestion d'erreurs centralisée

---

### 2. **user_service.dart** - Gestion des utilisateurs
✅ **Fonctionnalités:**
- Créer un profil utilisateur après inscription
- Récupérer un utilisateur par UID
- Mettre à jour les informations (nom, photo, objectif quotidien)
- Mettre à jour les statistiques totales (pas, distance, calories)
- Gestion des badges (ajout)
- Gestion des amis (ajout/suppression)
- Gestion des groupes (ajout/suppression)
- Paramètres utilisateur (notifications, profil public)
- Recherche d'utilisateurs par email
- Classement global (leaderboard)
- Stream pour écouter les changements

---

### 3. **step_service.dart** - Suivi des pas quotidiens
✅ **Fonctionnalités:**
- Sauvegarder les pas du jour
- Calculs automatiques (distance, calories)
- Marquer l'objectif comme atteint
- Récupérer les pas d'un jour spécifique
- Historique des N derniers jours
- Pas de la semaine/mois
- Calcul du total sur une période
- Moyenne quotidienne
- Vérification objectif atteint
- **Streak** (jours consécutifs avec objectif atteint)
- Stream pour écouter les pas du jour
- Données horaires (optionnel)
- Mise à jour automatique des stats utilisateur

---

### 4. **group_service.dart** - Gestion des groupes
✅ **Fonctionnalités:**
- Créer un groupe
- Génération automatique de code d'invitation
- Rejoindre un groupe par code
- Quitter un groupe
- Expulser un membre (admin)
- Mettre à jour les infos du groupe (admin)
- Mettre à jour les pas du groupe
- Récupérer tous les groupes d'un utilisateur
- Rechercher des groupes publics
- Classement des membres du groupe
- Stream pour écouter les changements
- Supprimer un groupe (admin)
- Gestion des rôles (admin/member)
- Limite de membres (optionnel)

---

## 🔧 Comment Utiliser les Services

### Exemple: Créer un utilisateur après inscription

```dart
import 'package:dizonli_app/services/user_service.dart';
import 'package:dizonli_app/models/user_model.dart';

final userService = UserService();

// Après l'inscription Firebase Auth
final user = UserModel(
  uid: firebaseUser.uid,
  email: email,
  firstName: firstName,
  lastName: lastName,
  birthDate: birthDate,
  age: age,
  sex: sex,
  dailyGoal: 10000,
  // ...autres champs
);

await userService.createUser(user);
```

### Exemple: Sauvegarder les pas du jour

```dart
import 'package:dizonli_app/services/step_service.dart';

final stepService = StepService();

// Sauvegarder les pas
await stepService.saveSteps(
  userId,
  5000, // nombre de pas
  DateTime.now(),
);

// Récupérer les pas d'aujourd'hui
final todaySteps = await stepService.getStepsByDate(userId, DateTime.now());
print('Pas aujourd\'hui: ${todaySteps?.steps}');

// Écouter les changements en temps réel
stepService.watchTodaySteps(userId).listen((record) {
  if (record != null) {
    print('Pas mis à jour: ${record.steps}');
  }
});
```

### Exemple: Créer un groupe

```dart
import 'package:dizonli_app/services/group_service.dart';

final groupService = GroupService();

// Créer un groupe
final groupId = await groupService.createGroup(
  name: 'Mes Amis Marcheurs',
  description: 'Groupe entre amis pour se motiver!',
  adminId: currentUserId,
  isPublic: false,
  maxMembers: 50,
);

print('Groupe créé avec l\'ID: $groupId');

// Rejoindre un groupe avec un code
await groupService.joinGroupByCode(userId, 'ABC123');
```

---

## 🚀 Prochaines Étapes

### 2️⃣ Dashboard fonctionnel avec graphiques
- [ ] Créer le widget pour afficher les pas en temps réel
- [ ] Graphique des pas de la semaine (fl_chart)
- [ ] Cartes de statistiques (distance, calories)
- [ ] Barre de progression de l'objectif
- [ ] Mini classement des amis
- [ ] Intégrer les services créés

### 3️⃣ Système de groupes complet
- [ ] Écran de liste des groupes
- [ ] Écran de création de groupe
- [ ] Écran de détails du groupe
- [ ] Classement du groupe
- [ ] Gestion des membres (admin)
- [ ] Recherche et rejoindre des groupes publics
- [ ] Intégrer le group_service

---

## 📝 Notes Importantes

1. **Règles Firestore:** N'oubliez pas de configurer les règles de sécurité dans Firebase Console (voir `FIRESTORE_STRUCTURE.md`)

2. **Calculs:**
   - Distance: `pas × 0.000762` km (0.762m par pas)
   - Calories: `pas × 0.04` (environ 0.04 calories par pas)

3. **Format des dates:** Les documents de pas utilisent le format `{userId}_{yyyy-MM-dd}`

4. **Mises à jour automatiques:** Le `step_service` met automatiquement à jour les statistiques totales de l'utilisateur

5. **Streams:** Utilisez les streams pour des mises à jour en temps réel dans l'UI

6. **Gestion d'erreurs:** Tous les services lancent des exceptions avec des messages explicites

---

**Date de création:** 3 octobre 2025  
**Statut:** ✅ Services de base complétés  
**Prochaine tâche:** Dashboard avec graphiques

