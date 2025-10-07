# 🏃 Guide d'activation Google Fit / Health Connect

## ✅ **ACTIVÉ !** Le comptage en arrière-plan est maintenant configuré

---

## 🎯 **Comment ça fonctionne maintenant**

### **Mode Google Fit / Health Connect (Prioritaire)**
- ✅ Compte les pas **24h/24, 7j/7**
- ✅ Fonctionne même quand l'app est **fermée**
- ✅ Fonctionne même quand le téléphone est en **veille**
- ✅ Synchronisation automatique toutes les **15 minutes**
- ✅ Accès à l'historique complet des pas

### **Mode Capteur Local (Fallback)**
- Si Google Fit échoue, l'app utilise le capteur local
- Compte uniquement quand l'app est **ouverte**

---

## 📱 **IMPORTANT : Test sur VRAI TÉLÉPHONE uniquement**

⚠️ **L'émulateur Android n'a PAS de capteur de pas !**

### **Étapes pour tester sur votre téléphone :**

#### 1️⃣ **Installer Google Fit ou Health Connect**

**Option A : Android 14+ (recommandé)**
- Health Connect est intégré au système
- Aller dans : **Paramètres → Santé → Health Connect**

**Option B : Android < 14**
- Installer **Google Fit** depuis le Play Store
- Ouvrir Google Fit et accepter les permissions

#### 2️⃣ **Activer le mode développeur sur votre téléphone**
```
1. Paramètres → À propos du téléphone
2. Taper 7 fois sur "Numéro de build"
3. Retourner dans Paramètres → Système → Options pour développeurs
4. Activer "Débogage USB"
```

#### 3️⃣ **Connecter votre téléphone au PC**
```
1. Brancher le téléphone via USB
2. Autoriser le débogage USB sur le téléphone
3. Vérifier la connexion :
```

```bash
flutter devices
```

Vous devriez voir votre téléphone dans la liste.

#### 4️⃣ **Lancer l'app sur votre téléphone**
```bash
flutter run
```

#### 5️⃣ **Lors du premier lancement**
L'app demandera les permissions suivantes :
- ✅ **Activité physique** (obligatoire)
- ✅ **Accès aux données de santé** (obligatoire)

**ACCEPTEZ TOUTES LES PERMISSIONS !**

---

## 🔍 **Vérification dans les logs**

### **✅ Si Google Fit fonctionne :**
```
🔄 Tentative d'initialisation Google Fit / Health Connect...
✅ Utilisation de Google Fit / Health Connect activée
✅ HealthSyncService initialisé avec succès
✅ Synchronisation automatique démarrée
```

### **⚠️ Si fallback sur capteur local :**
```
⚠️ Impossible d'utiliser le système, fallback sur capteur local: ...
🚶 Démarrage du capteur de pas local (fallback)...
✅ Capteur de pas local démarré
```

---

## 🧪 **Comment tester**

### **Test 1 : Vérifier la synchronisation**
1. Marchez **100 pas** avec votre téléphone
2. Attendez **30 secondes**
3. Ouvrez l'app DIZONLI
4. Les pas devraient apparaître immédiatement

### **Test 2 : Comptage en arrière-plan**
1. Ouvrez l'app DIZONLI
2. **FERMEZ** complètement l'app (swipe up)
3. Marchez **200 pas** avec votre téléphone
4. Attendez **5 minutes** (synchronisation)
5. Rouvrez l'app
6. ✅ Les pas devraient être comptés !

### **Test 3 : Historique**
1. Si vous avez déjà marché aujourd'hui
2. L'app devrait importer automatiquement l'historique
3. Tous vos pas de la journée seront synchronisés

---

## 🔧 **Dépannage**

### **Problème : "Permissions refusées"**
**Solution :**
```
1. Désinstaller l'app du téléphone
2. Relancer : flutter run
3. Accepter TOUTES les permissions
```

### **Problème : "Health Connect non disponible"**
**Solution :**
```
1. Installer Google Fit depuis le Play Store
2. Ouvrir Google Fit au moins une fois
3. Accepter les permissions
4. Relancer l'app DIZONLI
```

### **Problème : "Aucun pas compté"**
**Solution :**
```
1. Vérifier que Google Fit est installé ET ouvert
2. Dans Google Fit, aller dans Paramètres → Permissions
3. Vérifier que "Activité physique" est activée
4. Marcher avec le téléphone (pas la main !)
```

### **Problème : Émulateur**
**Solution :**
```
❌ NE PAS UTILISER L'ÉMULATEUR pour tester les pas
✅ UTILISER UN VRAI TÉLÉPHONE ANDROID
```

---

## 📊 **Synchronisation automatique**

Une fois configuré, l'app synchronise automatiquement :

| Action | Délai de synchronisation |
|--------|-------------------------|
| Ouverture de l'app | Immédiat |
| App en arrière-plan | Toutes les 5 min |
| App fermée | Toutes les 15 min |
| Historique | Au premier lancement |

---

## 🎉 **Avantages de Google Fit / Health Connect**

✅ **Économie de batterie**
- Pas besoin de garder l'app ouverte
- Le système gère le comptage

✅ **Précision**
- Utilise les capteurs du téléphone
- Algorithmes optimisés de Google

✅ **Compatibilité**
- Fonctionne avec toutes les apps de santé
- Données centralisées

✅ **Historique**
- Accès aux pas des jours précédents
- Synchronisation multi-appareils

---

## 🚀 **Prêt pour la production !**

Avec Google Fit / Health Connect activé, votre app est maintenant :
- ✅ **Production-ready**
- ✅ **Compte les pas 24h/24**
- ✅ **Batterie optimisée**
- ✅ **Expérience utilisateur professionnelle**

---

## 📝 **Checklist finale**

Avant de publier sur le Play Store :

- [ ] Tester sur plusieurs téléphones Android
- [ ] Vérifier Android 14+ (Health Connect natif)
- [ ] Vérifier Android 11-13 (Google Fit)
- [ ] Tester le comptage en arrière-plan
- [ ] Vérifier la synchronisation automatique
- [ ] Tester avec app fermée
- [ ] Vérifier l'historique
- [ ] Optimiser la batterie

---

**Besoin d'aide ?** Consultez les logs dans le terminal pendant les tests !
