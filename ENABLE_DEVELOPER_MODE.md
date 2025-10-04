# ⚙️ Activer le Mode Développeur Windows

## 🔧 Action Requise

Pour lancer l'application DIZONLI, vous devez activer le **Mode Développeur** sur Windows.

---

## 📋 Étapes Simples

### **La fenêtre des paramètres vient de s'ouvrir!**

1. ✅ Dans la fenêtre **"Paramètres"** qui s'est ouverte
2. ✅ Cherchez **"Mode développeur"** ou **"Developer Mode"**
3. ✅ **Activez le commutateur** (switch) pour le Mode Développeur
4. ✅ Confirmez si une fenêtre de confirmation apparaît
5. ✅ Attendez quelques secondes que Windows configure

---

## 🖼️ Ce que vous devriez voir:

```
Paramètres > Confidentialité et sécurité > Pour les développeurs

Mode développeur: [OFF]  →  [ON] ✅
```

---

## ❓ Pourquoi c'est nécessaire?

Flutter sur Windows nécessite le support des **liens symboliques** (symlinks) pour les plugins. Le Mode Développeur active cette fonctionnalité.

---

## ⏱️ Après Activation

Une fois activé:

1. **Fermez la fenêtre des paramètres**
2. **Revenez au terminal**
3. **Relancez l'application**

---

## 🚀 Commande à Relancer

Après avoir activé le Mode Développeur:

```bash
flutter run -d windows
```

---

## 📝 Note

- ✅ **Sécurisé**: Le Mode Développeur est sûr pour le développement d'applications
- ✅ **Nécessaire une seule fois**: Vous n'aurez plus à le faire
- ✅ **Réversible**: Vous pouvez le désactiver plus tard si souhaité

---

## 🆘 Si la Fenêtre ne s'est pas Ouverte

Ouvrez manuellement:

1. **Windows + I** (ouvrir Paramètres)
2. Allez dans **"Confidentialité et sécurité"**
3. Cliquez sur **"Pour les développeurs"**
4. Activez **"Mode développeur"**

Ou tapez dans le terminal:
```bash
start ms-settings:developers
```

---

## ✅ Vérification

Une fois activé, vous verrez:
```
Mode développeur: Activé ✅
```

Puis relancez:
```bash
flutter run -d windows
```

---

**Temps requis**: 30 secondes  
**Action**: Activer un simple commutateur ✅

Dites-moi quand c'est fait! 😊

