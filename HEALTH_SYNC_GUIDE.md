# 🏃 Guide de Synchronisation Automatique des Pas

## ✅ Fonctionnalité Implémentée : Comptage 24h/24

DIZONLI utilise maintenant **Google Fit** et **Health Connect** pour compter automatiquement vos pas, **même quand l'application est fermée** !

---

## 🎯 Comment ça fonctionne ?

### **Mode Automatique (Prioritaire)** ⭐

1. **Au premier lancement**, l'application demande l'accès à Google Fit / Health Connect
2. **Acceptez les permissions** pour activer le comptage automatique
3. **L'app synchronise automatiquement** :
   - ✅ Toutes les **15 minutes**
   - ✅ À chaque **ouverture de l'application**
   - ✅ Lors du **Pull to Refresh**
   - ✅ **Même quand l'app est fermée** (via le système Android)

### **Mode Fallback (Si système non disponible)**

Si Google Fit n'est pas disponible, l'application utilise le **capteur de pas intégré** :
- Comptage uniquement quand l'app est ouverte
- Sauvegarde toutes les 10 pas et toutes les 2 minutes

---

## 📱 Permissions Nécessaires

### **Android 14+ (Health Connect)**
- `READ_STEPS` : Lire les pas
- `READ_DISTANCE` : Lire la distance
- `READ_ACTIVE_CALORIES_BURNED` : Lire les calories

### **Android 10-13 (Google Fit)**
- `ACTIVITY_RECOGNITION` : Reconnaissance d'activité

---

## 🔄 Synchronisation de l'Historique

L'application peut synchroniser vos pas des **7 derniers jours** depuis Google Fit !

### **Comment synchroniser l'historique :**

1. Ouvrez l'application
2. **Tirez vers le bas** (Pull to Refresh) sur l'écran d'accueil
3. Les données historiques se synchronisent automatiquement

---

## 🎛️ Configuration Recommandée

### **1. Activer Google Fit / Health Connect**

#### **Android 14+** :
```
Paramètres → Santé → Autorisations d'application
→ DIZONLI → Autoriser toutes les permissions
```

#### **Android 10-13** :
```
Installez Google Fit depuis Play Store
→ Ouvrez DIZONLI
→ Acceptez les permissions
```

### **2. Désactiver l'optimisation de batterie**

```
Paramètres → Batterie → DIZONLI
→ "Ne pas optimiser"
```

Cela garantit que les synchronisations périodiques fonctionnent même en arrière-plan.

---

## 📊 Avantages du Système Automatique

| Fonctionnalité | Avec Google Fit | Sans (Capteur seul) |
|----------------|-----------------|---------------------|
| **Comptage quand app fermée** | ✅ OUI | ❌ NON |
| **Données multi-sources** | ✅ OUI (Smartwatch, etc.) | ❌ NON |
| **Historique complet** | ✅ OUI | ⚠️ Limité |
| **Précision** | ✅ Excellente | ⚠️ Bonne |
| **Consommation batterie** | ✅ Faible | ⚠️ Modérée |

---

## 🔍 Vérifier le Mode Actif

Dans l'application, vous verrez un indicateur :
- ✅ **"Utilisation de Google Fit"** → Mode automatique actif
- ⚠️ **"Utilisation du capteur local"** → Mode fallback

---

## ⚡ Synchronisation Automatique

### **Fréquence de synchronisation :**

- **Immédiate** : À l'ouverture de l'app
- **Périodique** : Toutes les 15 minutes (en arrière-plan)
- **Temps réel** : Rafraîchissement toutes les 5 minutes dans l'app
- **Manuel** : Pull to Refresh

---

## 🆘 Problèmes Courants

### **Les pas ne se synchronisent pas**

1. Vérifiez que **Google Fit** ou **Health Connect** est installé
2. Acceptez toutes les **permissions** dans les paramètres Android
3. Désactivez l'**optimisation de batterie** pour DIZONLI
4. **Redémarrez l'application**

### **Les données sont en retard**

- **Normal** : La synchronisation a lieu toutes les 15 minutes
- **Solution** : Faites un **Pull to Refresh** pour forcer la mise à jour

### **Mode capteur au lieu de Google Fit**

1. Installez **Google Fit** depuis le Play Store
2. Ouvrez Google Fit et configurez-le
3. **Fermez DIZONLI complètement**
4. **Rouvrez DIZONLI** → Les permissions seront redemandées

---

## 📈 Données Synchronisées

- ✅ **Pas quotidiens**
- ✅ **Distance parcourue**
- ✅ **Calories brûlées**
- ✅ **Historique des 7 derniers jours**
- ✅ **Progression en temps réel**

---

## 🚀 Prochaines Améliorations

- [ ] Synchronisation avec Apple Health (iOS)
- [ ] Support des smartwatches (Wear OS)
- [ ] Notifications de rappel personnalisées
- [ ] Export des données de santé

---

**🎉 Profitez du comptage automatique 24h/24 !**

Plus besoin de garder l'app ouverte - vos pas sont comptés en permanence par le système Android.
