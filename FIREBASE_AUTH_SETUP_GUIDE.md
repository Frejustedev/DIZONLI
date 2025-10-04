# 🔥 Guide Configuration Firebase Authentication

## 📌 La Console Firebase vient de s'ouvrir!

---

## ✅ **Étapes pour Activer l'Authentification Email/Password**

### **Étape 1: Page Authentication**

Vous devriez voir la page **Authentication** du projet **dizonli**.

Si ce n'est pas le cas:
1. Cliquez sur **Authentication** dans le menu de gauche
2. Ou allez directement sur: https://console.firebase.google.com/project/dizonli/authentication

---

### **Étape 2: Get Started (Si première fois)**

Si vous voyez un bouton **"Get Started"** ou **"Commencer"**:
1. ✅ Cliquez dessus
2. Attendez que la page se charge

---

### **Étape 3: Sign-in Method**

1. ✅ Cliquez sur l'onglet **"Sign-in method"** (en haut)
2. Vous verrez une liste de méthodes d'authentification

---

### **Étape 4: Activer Email/Password**

1. ✅ Dans la liste, trouvez **"Email/Password"**
2. ✅ Cliquez sur la ligne **"Email/Password"**
3. ✅ Une fenêtre s'ouvre → Activez le **premier commutateur** (Enable)
4. ✅ Le second (Email link passwordless) → **Laissez désactivé**
5. ✅ Cliquez sur **"Save"** ou **"Enregistrer"**

---

### **Étape 5: Vérification**

Vous devriez maintenant voir:
```
Email/Password          Enabled ✅
```

---

## 🗄️ **Bonus: Créer Firestore Database (Recommandé)**

### **Étape 1: Accéder à Firestore**

1. Menu de gauche → **Firestore Database**
2. Ou: https://console.firebase.google.com/project/dizonli/firestore

---

### **Étape 2: Créer la Database**

1. ✅ Cliquez sur **"Create database"** ou **"Créer une base de données"**

---

### **Étape 3: Mode de Sécurité**

Choisissez: **"Start in test mode"** ou **"Commencer en mode test"**
- ✅ C'est parfait pour le développement
- ⚠️ À sécuriser avant la production

Cliquez **"Next"** ou **"Suivant"**

---

### **Étape 4: Région**

Sélectionnez une région proche:
- **europe-west1** (Belgique) - Recommandé pour l'Europe
- **us-central1** (Iowa) - Pour les USA

Cliquez **"Enable"** ou **"Activer"**

Attendez ~30 secondes que Firestore soit créé.

---

### **Étape 5: Vérification**

Vous devriez voir:
```
Cloud Firestore
├── (root)
└── Ready to use! ✅
```

---

## 📊 **Règles de Sécurité Firestore (Important)**

Une fois Firestore créé, dans l'onglet **"Rules"**:

Remplacez par ces règles de développement:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - Utilisateurs peuvent lire/écrire leur propre doc
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Groups collection - Lecture publique, écriture pour membres
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Step records - Utilisateurs peuvent gérer leurs propres enregistrements
    match /step_records/{recordId} {
      allow read, write: if request.auth != null;
    }
    
    // Challenges - Lecture publique, création pour utilisateurs authentifiés
    match /challenges/{challengeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
    
    // Social posts - Lecture publique, création pour utilisateurs authentifiés
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null 
        && request.auth.uid == resource.data.userId;
    }
  }
}
```

Cliquez **"Publish"** ou **"Publier"**

---

## ✅ **Récapitulatif de ce qui est fait:**

Après avoir suivi ces étapes:

- ✅ **Authentication Email/Password**: Activée
- ✅ **Firestore Database**: Créée et configurée
- ✅ **Règles de sécurité**: Configurées pour le développement
- ✅ **Prêt pour l'application**: L'app peut maintenant créer des comptes!

---

## 🚀 **Test après Configuration**

Une fois l'application lancée (après résolution du problème Visual Studio):

1. **Inscription**:
   - Cliquez "S'inscrire"
   - Remplissez le formulaire
   - Créez un compte → Sera enregistré dans Firebase!

2. **Connexion**:
   - Utilisez l'email/mot de passe créé
   - Accédez au dashboard

3. **Vérification dans Firebase**:
   - Retournez dans Firebase Console
   - Authentication → Users
   - Vous verrez le compte créé! ✅

---

## 📸 **Captures d'Écran de Vérification**

### Authentication activée:
```
┌────────────────────────────────────────┐
│ Sign-in method                         │
├────────────────────────────────────────┤
│ Email/Password          Enabled ✅     │
│ Google                  Disabled       │
│ Facebook               Disabled        │
└────────────────────────────────────────┘
```

### Firestore créée:
```
┌────────────────────────────────────────┐
│ Cloud Firestore                        │
├────────────────────────────────────────┤
│ Status: Active ✅                      │
│ Location: europe-west1                │
│ Documents: 0                           │
└────────────────────────────────────────┘
```

---

## 🔧 **Pendant ce temps: Résolution Visual Studio**

Pour que l'app Windows fonctionne, vous devez installer **Visual Studio Build Tools**.

### **Option Rapide (Recommandée pour tester):**

Testez l'application sur **navigateur Web** en attendant:

```bash
flutter run -d chrome
```

C'est plus rapide et ne nécessite pas Visual Studio!

---

## 🆘 **Besoin d'Aide?**

Si vous êtes bloqué sur une étape:
1. Regardez les captures d'écran ci-dessus
2. Cherchez les boutons/onglets mentionnés
3. Ou dites-moi où vous êtes bloqué!

---

## ⏱️ **Temps Estimé:**
- **Authentication**: 1 minute
- **Firestore**: 2 minutes
- **Total**: ~3 minutes

---

**Une fois terminé, dites-moi "C'EST CONFIGURÉ"** et je vous aiderai à lancer l'app! 😊

---

**Firebase est la clé pour que DIZONLI fonctionne! 🔥💚**

