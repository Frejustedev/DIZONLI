# 🔥 Guide de Configuration des Index Firestore - DIZONLI

## ⚠️ Problème

L'application affiche l'erreur suivante :
```
[cloud_firestore/failed-precondition] The query requires an index. 
You can create it here: https://console.firebase.google.com/...
```

## 📚 Pourquoi des index sont nécessaires ?

Firestore nécessite des **index composites** pour les requêtes qui :
- Combinent plusieurs `where()` avec `orderBy()`
- Utilisent plusieurs champs de tri
- Filtrent sur un champ et trient sur un autre

## 🚀 Solution Rapide (Automatique)

### Méthode 1 : Cliquer sur le lien dans l'erreur ✨

1. Quand l'erreur apparaît dans la console, **cliquez sur le lien fourni**
2. Vous serez redirigé vers Firebase Console
3. L'index sera **pré-rempli automatiquement**
4. Cliquez sur **"Créer l'index"**
5. Attendez quelques minutes que l'index soit créé

### Méthode 2 : Déployer tous les index en une fois 🎯

```bash
# Dans le terminal, à la racine du projet
firebase deploy --only firestore:indexes
```

⏱️ **Temps d'attente** : 2-5 minutes par index

## 🔧 Solution Manuelle (Firebase Console)

Si vous préférez créer les index manuellement :

### 1. Accéder à Firebase Console
1. Allez sur https://console.firebase.google.com
2. Sélectionnez votre projet **dizonli**
3. Dans le menu latéral, cliquez sur **"Firestore Database"**
4. Allez dans l'onglet **"Indexes"** (Index)

### 2. Créer les index nécessaires

#### Index 1 : Steps (Historique récent) ⭐ **PRIORITAIRE**
```
Collection: steps
Champs:
  - userId (Ascending)
  - date (Descending)
État de la requête: Collection
```

#### Index 2 : Steps (Historique complet)
```
Collection: steps
Champs:
  - userId (Ascending)
  - date (Ascending)
État de la requête: Collection
```

#### Index 3 : Challenges (À venir)
```
Collection: challenges
Champs:
  - isPublic (Ascending)
  - startDate (Ascending)
État de la requête: Collection
```

#### Index 4 : Challenges (Complétés)
```
Collection: challenges
Champs:
  - participantIds (Array-contains)
  - endDate (Descending)
État de la requête: Collection
```

#### Index 5 : Posts (Par utilisateur)
```
Collection: posts
Champs:
  - userId (Ascending)
  - createdAt (Descending)
État de la requête: Collection
```

### 3. Vérifier la création

- Chaque index prend **2-5 minutes** à être créé
- Le statut passe de **"Building"** (🔨) à **"Enabled"** (✅)
- Actualisez la page pour voir les changements

## 📝 Instructions Détaillées pour Chaque Index

### Étapes pour créer un index :

1. Cliquez sur **"Create Index"** (Créer un index)
2. **Collection ID** : Entrez le nom de la collection (ex: `steps`)
3. **Champs** :
   - Cliquez sur **"Add field"** (Ajouter un champ)
   - Entrez le nom du champ
   - Choisissez l'ordre : **Ascending** ou **Descending**
   - Répétez pour chaque champ
4. **Query scope** : Laissez sur **"Collection"**
5. Cliquez sur **"Create"** (Créer)

## 🎨 Capture d'écran (exemple pour steps)

```
┌─────────────────────────────────────────────┐
│ Create a new index                          │
├─────────────────────────────────────────────┤
│ Collection ID: steps                        │
│                                             │
│ Fields indexed:                             │
│   userId          [Ascending ▼]             │
│   date            [Descending ▼]            │
│                                             │
│ Query scope:      [Collection ▼]            │
│                                             │
│ [Cancel]                   [Create Index]   │
└─────────────────────────────────────────────┘
```

## ✅ Vérification

Après avoir créé les index, **relancez l'application** :

```bash
flutter run -d chrome
```

L'erreur devrait disparaître ! 🎉

## 🆘 En cas de problème

### L'index ne se crée pas
- Vérifiez que vous êtes sur le bon projet Firebase
- Vérifiez que vous avez les droits d'administration
- Essayez de rafraîchir la page

### L'erreur persiste après création
- Attendez 5 minutes supplémentaires (propagation)
- Vérifiez que l'index est bien **"Enabled"** (vert)
- Redémarrez l'application Flutter
- Videz le cache : `flutter clean && flutter pub get`

### Trop d'index à créer ?
Utilisez la commande Firebase CLI :
```bash
firebase deploy --only firestore:indexes
```

## 📊 Index créés pour DIZONLI

| Collection | Champs | Ordre | Statut |
|-----------|--------|-------|--------|
| steps | userId, date | ASC, DESC | ⏳ À créer |
| steps | userId, date | ASC, ASC | ⏳ À créer |
| challenges | isPublic, startDate | ASC, ASC | ⏳ À créer |
| challenges | participantIds, endDate | ARRAY, DESC | ⏳ À créer |
| posts | userId, createdAt | ASC, DESC | ⏳ À créer |

## 🎯 Priorités

1. **URGENT** : Index `steps` (userId + date DESC) → pour les statistiques
2. Important : Index `posts` (userId + createdAt) → pour le fil social
3. Optionnel : Index `challenges` → si vous utilisez les podothons

## 💡 Astuce

Pour éviter ce problème à l'avenir, utilisez toujours :
```bash
firebase deploy --only firestore:indexes
```
avant de déployer une nouvelle version de l'application.

---

**Note** : Le fichier `firestore.indexes.json` contient la configuration complète. Vous pouvez le déployer automatiquement avec Firebase CLI.

