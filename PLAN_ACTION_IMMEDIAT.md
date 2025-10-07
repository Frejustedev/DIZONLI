# ✅ PLAN D'ACTION IMMÉDIAT - DIZONLI

**Date:** 7 Octobre 2025  
**Objectif:** Rendre l'application production-ready en 2-3 semaines  
**Approche:** Fixes critiques → Tests → Améliorations

---

## 🚨 JOUR 1-2 : NETTOYAGE CRITIQUE (URGENT)

### Task 1.1: Supprimer le Code Dupliqué ⏱️ 2h

**Fichiers à supprimer:**
```bash
❌ lib/services/group_service_NEW.dart
❌ lib/screens/dashboard/dashboard_screen.dart
```

**Fichiers à renommer:**
```bash
✅ lib/screens/dashboard/dashboard_screen_v2.dart
   → lib/screens/dashboard/dashboard_screen.dart
```

**Vérifications après:**
```bash
✅ Rechercher toutes les importations qui référencent les anciens fichiers
✅ flutter pub run build_runner build (si code généré)
✅ flutter analyze (vérifier aucune erreur)
✅ flutter run (tester que l'app démarre)
```

**Commandes:**
```bash
# Chercher les références
grep -r "dashboard_screen_v2" lib/
grep -r "group_service_NEW" lib/

# Après correction
flutter clean
flutter pub get
flutter analyze
```

---

### Task 1.2: Créer Écran Friends Complet ⏱️ 6h

**Fichiers à créer:**

#### 1. `lib/screens/friends/friends_screen.dart`
```dart
// Affichage liste amis + demandes en attente
// 2 tabs: Amis (accepted) | Demandes (pending)
// Features:
// - Liste amis avec avatar, nom, total steps
// - Badge pour demandes en attente (badge rouge)
// - Bouton "Ajouter un ami"
// - Swipe to delete pour retirer un ami
// - Pull to refresh
```

**Contenu suggéré:**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/friendship_service.dart';
import '../../services/user_service.dart';
import '../../models/friendship_model.dart';
import '../../models/user_model.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);
  
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendshipService _friendshipService = FriendshipService();
  final UserService _userService = UserService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: Implémenter l'UI complète
    // Tabs: Amis | Demandes
    // Liste avec StreamBuilder
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Amis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Amis', icon: Icon(Icons.people)),
            Tab(text: 'Demandes', icon: Icon(Icons.person_add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildRequestsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFriendScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
    );
  }
  
  Widget _buildFriendsList() {
    // TODO: StreamBuilder pour liste amis
    return Center(child: Text('Liste amis'));
  }
  
  Widget _buildRequestsList() {
    // TODO: StreamBuilder pour demandes
    return Center(child: Text('Demandes'));
  }
}
```

#### 2. `lib/screens/friends/add_friend_screen.dart`
```dart
// Recherche d'utilisateurs par email/nom
// Features:
// - TextField de recherche
// - Liste résultats avec statut amitié
// - Bouton "Ajouter" / "Demande envoyée" / "Déjà ami"
// - Debounce sur la recherche (500ms)
```

#### 3. Mise à jour `lib/widgets/mini_leaderboard.dart`
```dart
// Ligne 54: Remplacer
// TODO: Navigate to add friends
// Par:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FriendsScreen(),
  ),
);

// Ligne 94: Remplacer
// TODO: Navigate to full leaderboard
// Par:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FriendsScreen(),
  ),
);
```

**Test après implémentation:**
```
✅ Ouvrir dashboard
✅ Voir mini leaderboard
✅ Cliquer "Ajouter des amis" → Ouvre FriendsScreen
✅ Cliquer "Voir tout" → Ouvre FriendsScreen
✅ Dans FriendsScreen, tester recherche
✅ Envoyer demande d'ami
✅ Accepter/Refuser demande
```

---

### Task 1.3: Créer Écran Paramètres ⏱️ 4h

**Fichier:** `lib/screens/settings/settings_screen.dart`

**Features requises:**
```dart
// Sections:
// 1. Profil
//    - Modifier photo
//    - Modifier nom
//    - Modifier email
// 
// 2. Objectifs
//    - Objectif quotidien (slider 5000-20000)
//    - Poids (pour calories)
//    - Taille (pour distance)
//
// 3. Notifications
//    - Activer/Désactiver notifications
//    - Notifications de badge
//    - Notifications d'amis
//    - Notifications de défis
//
// 4. Apparence
//    - Mode sombre (TODO future)
//    - Langue (FR/EN)
//
// 5. Confidentialité
//    - Profil public/privé
//    - Qui peut m'ajouter
//
// 6. À propos
//    - Version app
//    - CGU (navigate to terms)
//    - Politique confidentialité
//    - Nous contacter
//
// 7. Compte
//    - Déconnexion (rouge)
//    - Supprimer compte (rouge, confirmation)
```

**Intégration:**
```dart
// Dans lib/screens/profile/profile_screen.dart
// Ajouter bouton paramètres dans AppBar:
actions: [
  IconButton(
    icon: const Icon(Icons.settings),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    ),
  ),
],
```

---

## 🔴 JOUR 3-4 : RÉSOLUTION DES TODOS CRITIQUES

### Task 2.1: Implémenter Partage Groupe ⏱️ 2h

**Fichier:** `lib/screens/groups/create_group_screen.dart`

```dart
// Ligne 388: Remplacer
// TODO: Implement share functionality

// Par:
Future<void> _shareInviteCode(String code, String groupName) async {
  try {
    await Share.share(
      'Rejoins mon groupe "$groupName" sur DIZONLI!\n\n'
      'Code d\'invitation: $code\n\n'
      'Télécharge l\'app DIZONLI pour nous rejoindre!',
      subject: 'Invitation groupe DIZONLI',
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors du partage: $e')),
    );
  }
}

// Appeler dans le bouton:
onPressed: () => _shareInviteCode(
  widget.group.inviteCode,
  widget.group.name,
),
```

### Task 2.2: Implémenter Recherche Groupes ⏱️ 3h

**Fichier:** `lib/screens/groups/groups_list_screen.dart`

```dart
// Ligne 302: Remplacer
// TODO: Implement group search

// Créer méthode:
Future<void> _showSearchDialog() async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rechercher un groupe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Nom du groupe',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              // TODO: Debounce search
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 16),
          // StreamBuilder pour résultats
          StreamBuilder<List<GroupModel>>(
            stream: _groupService.searchPublicGroups(_searchQuery),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final group = snapshot.data![index];
                  return ListTile(
                    title: Text(group.name),
                    subtitle: Text('${group.memberIds.length} membres'),
                    trailing: ElevatedButton(
                      onPressed: () => _joinGroup(group.id),
                      child: const Text('Rejoindre'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}
```

### Task 2.3: Implémenter Édition Groupe ⏱️ 3h

**Créer:** `lib/screens/groups/edit_group_screen.dart`

```dart
// Similar à create_group_screen.dart
// Mais pré-rempli avec données existantes
// Permet modification nom, description, isPrivate
// Seulement pour admin

// Features:
// - Form pré-rempli
// - Validation
// - Update Firestore
// - Retour avec snackbar succès
```

**Mise à jour:** `lib/screens/groups/group_details_screen.dart`

```dart
// Ligne 595: Remplacer
// TODO: Navigate to edit group screen

// Par:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EditGroupScreen(group: widget.group),
  ),
);
```

### Task 2.4: Navigation Notifications ⏱️ 1h

**Fichier:** `lib/screens/dashboard/dashboard_screen_v2.dart`

```dart
// Ligne 113: Remplacer
// TODO: Navigate to notifications

// Par:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const NotificationsScreen(),
  ),
);
```

---

## 🟡 JOUR 5-7 : PERMISSIONS & UPLOAD IMAGES

### Task 3.1: Configurer Permissions Health ⏱️ 4h

#### Android: `android/app/src/main/AndroidManifest.xml`
```xml
<manifest>
  <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
  
  <!-- Pour Health Connect (Android 14+) -->
  <uses-permission android:name="android.permission.health.READ_STEPS"/>
  <uses-permission android:name="android.permission.health.WRITE_STEPS"/>
  
  <application>
    <!-- Health Connect integration -->
    <activity android:name="com.google.android.libraries.healthdata.permission.ui.PermissionsActivity"/>
  </application>
</manifest>
```

#### iOS: `ios/Runner/Info.plist`
```xml
<dict>
  <!-- HealthKit -->
  <key>NSHealthShareUsageDescription</key>
  <string>DIZONLI a besoin d'accéder à vos données de pas pour suivre votre activité physique</string>
  
  <key>NSHealthUpdateUsageDescription</key>
  <string>DIZONLI souhaite sauvegarder vos pas dans HealthKit</string>
  
  <key>UIBackgroundModes</key>
  <array>
    <string>processing</string>
  </array>
</dict>
```

#### Réactiver: `lib/providers/step_provider.dart`
```dart
// Ligne 36: Supprimer le commentaire TODO et activer:
try {
  final healthSyncService = HealthSyncService();
  final initialized = await healthSyncService.initialize();
  
  if (initialized) {
    await healthSyncService.syncSteps(userId);
    _healthSyncEnabled = true;
    debugPrint('✅ Health sync activé');
  }
} catch (e) {
  debugPrint('⚠️ Health sync non disponible: $e');
  // Fallback sur capteur local
}
```

### Task 3.2: Implémenter Upload Images ⏱️ 6h

#### 1. Ajouter dépendances dans `pubspec.yaml`
```yaml
dependencies:
  image_picker: ^1.0.4
  firebase_storage: ^11.5.6
  image_cropper: ^5.0.0
  cached_network_image: ^3.3.0
```

#### 2. Créer service: `lib/services/storage_service.dart`
```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  /// Upload image et retourne l'URL
  Future<String?> uploadImage({
    required String userId,
    required String folder, // 'profiles', 'posts', 'groups'
    File? imageFile,
  }) async {
    try {
      // Pick image si pas fourni
      if (imageFile == null) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (pickedFile == null) return null;
        imageFile = File(pickedFile.path);
      }
      
      // Créer référence unique
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$folder/$userId/$fileName');
      
      // Upload
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Récupérer URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erreur upload image: $e');
      return null;
    }
  }
  
  /// Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('❌ Erreur suppression image: $e');
    }
  }
}
```

#### 3. Intégrer dans profil: `lib/screens/profile/profile_screen.dart`
```dart
// Ajouter bouton "Modifier photo" sur l'avatar:
Stack(
  children: [
    CircleAvatar(
      radius: 50,
      backgroundImage: user.photoURL.isNotEmpty
          ? NetworkImage(user.photoURL)
          : null,
      child: user.photoURL.isEmpty
          ? Text(user.firstName[0])
          : null,
    ),
    Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: _uploadProfilePhoto,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
        ),
      ),
    ),
  ],
)

// Méthode:
Future<void> _uploadProfilePhoto() async {
  final storageService = StorageService();
  final userService = UserService();
  
  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(child: CircularProgressIndicator()),
  );
  
  try {
    final photoUrl = await storageService.uploadImage(
      userId: user.uid,
      folder: 'profiles',
    );
    
    if (photoUrl != null) {
      await userService.updateUser(user.uid, {'photoURL': photoUrl});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo mise à jour!')),
      );
    }
  } finally {
    Navigator.pop(context); // Close loading
  }
}
```

#### 4. Configurer Firebase Storage Rules
```javascript
// Firebase Console → Storage → Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profiles
    match /profiles/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024 // 5MB max
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Posts images
    match /posts/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024; // 10MB max
    }
  }
}
```

---

## 🧪 JOUR 8-10 : TESTS DE BASE

### Task 4.1: Setup Tests ⏱️ 2h

**Mettre à jour:** `pubspec.yaml`
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
  fake_cloud_firestore: ^2.4.1
  firebase_auth_mocks: ^0.13.0
```

**Créer:** `test/helpers/test_helpers.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Setup Firebase Mock
Future<void> setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
}

// Mock users
UserModel createMockUser({
  String uid = 'test-user-123',
  String email = 'test@test.com',
}) {
  return UserModel(
    uid: uid,
    email: email,
    firstName: 'Test',
    lastName: 'User',
    dailyGoal: 10000,
    totalSteps: 50000,
    // ...
  );
}
```

### Task 4.2: Tests Unitaires Services ⏱️ 6h

**Créer:** `test/services/user_service_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:dizonli_app/services/user_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('UserService Tests', () {
    late UserService userService;
    late FakeFirebaseFirestore firestore;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
      userService = UserService(firestore: firestore);
    });
    
    test('createUser should create user in Firestore', () async {
      final user = createMockUser();
      
      await userService.createUser(user);
      
      final doc = await firestore.collection('users').doc(user.uid).get();
      expect(doc.exists, true);
      expect(doc.data()!['email'], user.email);
    });
    
    test('getUser should return user from Firestore', () async {
      // Arrange
      final user = createMockUser();
      await firestore.collection('users').doc(user.uid).set(user.toJson());
      
      // Act
      final retrieved = await userService.getUser(user.uid);
      
      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.uid, user.uid);
      expect(retrieved.email, user.email);
    });
    
    test('updateUser should update user data', () async {
      final user = createMockUser();
      await firestore.collection('users').doc(user.uid).set(user.toJson());
      
      await userService.updateUser(user.uid, {'dailyGoal': 15000});
      
      final doc = await firestore.collection('users').doc(user.uid).get();
      expect(doc.data()!['dailyGoal'], 15000);
    });
    
    // Plus de tests...
  });
}
```

**Créer aussi:**
- `test/services/step_service_test.dart`
- `test/services/group_service_test.dart`
- `test/services/auth_service_test.dart`

### Task 4.3: Tests Widgets ⏱️ 4h

**Créer:** `test/widgets/step_circle_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dizonli_app/widgets/step_circle.dart';

void main() {
  testWidgets('StepCircle displays correct step count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepCircle(
            steps: 5000,
            goal: 10000,
            size: 200,
          ),
        ),
      ),
    );
    
    expect(find.text('5,000'), findsOneWidget);
    expect(find.text('10,000'), findsOneWidget);
  });
  
  testWidgets('StepCircle shows 100% when goal reached', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepCircle(
            steps: 10000,
            goal: 10000,
            size: 200,
          ),
        ),
      ),
    );
    
    expect(find.text('100%'), findsOneWidget);
  });
}
```

### Task 4.4: Lancer les Tests ⏱️ 1h

```bash
# Tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Voir le rapport de couverture
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Objectif: >40% de couverture
```

---

## 🔧 JOUR 11-12 : GESTION D'ERREURS ROBUSTE

### Task 5.1: Créer Error Handler ⏱️ 3h

**Créer:** `lib/core/error/exceptions.dart`
```dart
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'Problème de connexion internet');
}

class AuthException extends AppException {
  AuthException(String message) : super(message);
}

class FirestoreException extends AppException {
  FirestoreException(String message) : super(message);
}

class PermissionException extends AppException {
  PermissionException([String? message])
      : super(message ?? 'Permissions requises non accordées');
}
```

**Créer:** `lib/core/error/error_handler.dart`
```dart
import 'package:flutter/material.dart';
import 'exceptions.dart';

class ErrorHandler {
  static void handle(dynamic error, {
    BuildContext? context,
    VoidCallback? onRetry,
  }) {
    String message = 'Une erreur est survenue';
    
    if (error is AppException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }
    
    debugPrint('❌ Error: $message');
    
    if (context != null) {
      _showErrorSnackBar(context, message, onRetry);
    }
  }
  
  static void _showErrorSnackBar(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
```

### Task 5.2: Ajouter Retry Logic ⏱️ 2h

**Créer:** `lib/core/utils/retry_helper.dart`
```dart
Future<T> retryOperation<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  int attempt = 0;
  
  while (attempt < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      
      debugPrint('⚠️ Tentative $attempt échouée, retry dans ${delay.inSeconds}s');
      await Future.delayed(delay);
    }
  }
  
  throw Exception('Max attempts reached');
}
```

**Utiliser dans services:**
```dart
// Exemple: lib/services/user_service.dart
Future<UserModel?> getUser(String uid) async {
  return retryOperation(
    operation: () async {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    },
    maxAttempts: 3,
  );
}
```

### Task 5.3: Remplacer debugPrint ⏱️ 2h

**Ajouter:** `pubspec.yaml`
```yaml
dependencies:
  logger: ^2.0.2
```

**Créer:** `lib/core/logger/app_logger.dart`
```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );
  
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  static void debug(String message) => _logger.d(message);
}
```

**Remplacer partout:**
```dart
// Avant:
debugPrint('✅ Pas sauvegardés: $steps');

// Après:
AppLogger.info('Pas sauvegardés: $steps');
```

**Commande recherche/remplacement:**
```bash
# Chercher tous les debugPrint
grep -r "debugPrint" lib/ | wc -l

# TODO: Remplacer manuellement ou script
```

---

## ✅ JOUR 13-14 : TESTS UTILISATEURS & POLISH

### Task 6.1: Tests Manuels Complets ⏱️ 4h

**Créer checklist:** `TESTING_CHECKLIST.md`
```markdown
# Checklist Tests Manuels DIZONLI

## Authentification
- [ ] Inscription nouvel utilisateur
- [ ] Validation email invalide
- [ ] Validation mot de passe faible
- [ ] Connexion utilisateur existant
- [ ] Déconnexion
- [ ] Reset password

## Dashboard
- [ ] Affichage pas du jour
- [ ] Cercle de progression animé
- [ ] Graphique hebdomadaire
- [ ] Pull to refresh
- [ ] Navigation bottom bar

## Groupes
- [ ] Créer groupe public
- [ ] Créer groupe privé
- [ ] Rejoindre par code
- [ ] Partager code invitation
- [ ] Voir classement groupe
- [ ] Quitter groupe
- [ ] Admin: Retirer membre
- [ ] Recherche groupes publics

## Défis
- [ ] Créer défi individuel
- [ ] Créer défi groupe
- [ ] S'inscrire à défi
- [ ] Voir progression
- [ ] Se désinscrire

## Amis
- [ ] Chercher utilisateur
- [ ] Envoyer demande ami
- [ ] Accepter demande
- [ ] Refuser demande
- [ ] Voir liste amis
- [ ] Supprimer ami

## Social
- [ ] Publier post
- [ ] Liker post
- [ ] Commenter
- [ ] Filtrer Public/Amis

## Profil
- [ ] Upload photo
- [ ] Modifier infos
- [ ] Voir badges
- [ ] Voir stats

## Notifications
- [ ] Badge rouge sur icône
- [ ] Liste notifications
- [ ] Marquer comme lu
- [ ] Navigation depuis notif

## Performance
- [ ] App démarre <3s
- [ ] Navigation fluide
- [ ] Pas de crashes
- [ ] Memory leaks check
```

### Task 6.2: Tests Beta Utilisateurs ⏱️ 3 jours

**Préparer:**
1. Build release APK
```bash
flutter build apk --release
```

2. Créer formulaire feedback Google Forms
3. Recruter 10-20 beta testeurs
4. Distribuer via Firebase App Distribution

**Questions feedback:**
- Facilité d'utilisation (1-5)
- Features manquantes
- Bugs rencontrés
- Suggestions

### Task 6.3: Itérations ⏱️ Variable

**Prioriser bugs trouvés:**
- 🔴 Critiques (crashes, data loss)
- 🟡 Majeurs (features cassées)
- 🟢 Mineurs (UI glitches)

---

## 📋 CHECKLIST FINALE AVANT PRODUCTION

### Code Quality
- [ ] Aucun TODO critique non résolu
- [ ] Code dupliqué supprimé
- [ ] >40% test coverage
- [ ] flutter analyze = 0 erreurs
- [ ] Code formaté (dart format)

### Features
- [ ] Écran friends complet
- [ ] Écran settings complet
- [ ] Upload images fonctionnel
- [ ] Permissions Health configurées
- [ ] Partage fonctionnel
- [ ] Recherche groupes fonctionnelle

### Security
- [ ] Firestore rules production-ready
- [ ] Storage rules configurées
- [ ] Auth rules validées
- [ ] Pas de secrets en dur

### Performance
- [ ] App startup <3s
- [ ] Smooth scrolling (60fps)
- [ ] Images optimisées
- [ ] Memory usage <100MB

### Legal
- [ ] CGU rédigées
- [ ] Politique confidentialité
- [ ] RGPD compliant
- [ ] Mentions légales

### Stores
- [ ] Screenshots (5+ par plateforme)
- [ ] Description app (FR + EN)
- [ ] Keywords SEO
- [ ] Privacy policy URL
- [ ] Support email
- [ ] Icon haute résolution

---

## 🚀 LANCEMENT

### Pre-Launch (Jour -7)
- [ ] Tests finaux complets
- [ ] Backup Firestore
- [ ] Monitoring configuré (Crashlytics)
- [ ] Analytics configuré
- [ ] Support email setup

### Launch Day
- [ ] Submit iOS App Store
- [ ] Submit Google Play Store
- [ ] Communiqué presse
- [ ] Posts réseaux sociaux
- [ ] Email beta testeurs

### Post-Launch (Semaine 1)
- [ ] Monitor crashes/errors
- [ ] Répondre reviews
- [ ] Fix bugs critiques
- [ ] Analyser analytics
- [ ] Plan itération V1.1

---

**Estimation totale:** 2-3 semaines (80-120h de travail)  
**Résultat:** Application production-ready solide et testée  
**Prochain milestone:** Launch! 🎉
