# 📊 Firebase - Monitoring des Quotas

## Comment Vérifier Votre Usage

### 1. Firebase Console
1. Allez sur: https://console.firebase.google.com
2. Sélectionnez votre projet DIZONLI
3. Menu latéral → **Storage**
4. Onglet **Usage** en haut

### 2. Métriques à Surveiller

```
📦 STOCKAGE TOTAL
   Limite: 5 GB gratuit
   Alert: Si > 4 GB
   
📤 UPLOADS
   Limite: 1 GB/jour gratuit
   Alert: Si > 800 MB/jour
   
📥 DOWNLOADS
   Limite: 1 GB/jour gratuit
   Alert: Si > 800 MB/jour
```

### 3. Configurer Alertes

#### Dans Firebase Console:
```
1. Settings → Usage and Billing
2. Set Budget Alerts
3. Email: votre-email@example.com
4. Threshold: 80% du quota
```

---

## 📈 Tableaux de Bord Recommandés

### Quotidien (Phase Beta)
- Vérifier une fois par semaine

### Croissance Active
- Vérifier 2-3 fois par semaine

### Post-Launch
- Dashboard automatique (Firebase Analytics)

---

## 🚨 Alertes Critiques

### Approche Limite Gratuite
```
⚠️ Si Stockage > 4 GB:
   1. Compresser images existantes
   2. Nettoyer posts anciens
   3. Planifier migration plan Blaze

⚠️ Si Uploads > 800 MB/jour:
   1. Réduire qualité compression
   2. Limiter nombre d'images/post
   3. Rate limiting côté serveur

⚠️ Si Downloads > 800 MB/jour:
   1. Implémenter cache local
   2. Thumbnails pour feed
   3. CDN si nécessaire
```

---

## 💰 Calculateur de Coûts

### Plan Blaze (Pay-as-you-go)

**Tarifs (au-delà du gratuit):**
```
📦 Stockage: 0.026 $/GB/mois
📤 Uploads: 0.05 $/GB
📥 Downloads: 0.12 $/GB
```

### Exemples Concrets

#### 1,000 Utilisateurs Actifs
```
Stockage: 10 GB × 0.026 $ = 0.26 $/mois
Uploads: 5 GB/mois × 0.05 $ = 0.25 $/mois
Downloads: 10 GB/mois × 0.12 $ = 1.20 $/mois

TOTAL: ~1.71 $/mois (~1.60 €/mois)
```

#### 5,000 Utilisateurs Actifs
```
Stockage: 30 GB × 0.026 $ = 0.78 $/mois
Uploads: 20 GB/mois × 0.05 $ = 1.00 $/mois
Downloads: 50 GB/mois × 0.12 $ = 6.00 $/mois

TOTAL: ~7.78 $/mois (~7.30 €/mois)
```

#### 10,000 Utilisateurs Actifs
```
Stockage: 60 GB × 0.026 $ = 1.56 $/mois
Uploads: 40 GB/mois × 0.05 $ = 2.00 $/mois
Downloads: 100 GB/mois × 0.12 $ = 12.00 $/mois

TOTAL: ~15.56 $/mois (~14.60 €/mois)
```

---

## 🎯 Stratégie Recommandée

### Phase 1: Beta (0-3 mois)
```
✅ Plan Spark (gratuit)
✅ Pas de carte bancaire
✅ 0 € de coût
```

### Phase 2: Early Growth (3-6 mois)
```
✅ Plan Spark tant que possible
⏳ Monitoring hebdomadaire
⏳ Compression images activée
⏳ 0 € de coût (ou < 5 €)
```

### Phase 3: Scale (6+ mois)
```
⏳ Plan Blaze
⏳ Budget alert: 20 €/mois
⏳ Optimisations continues
⏳ Coût: 5-20 €/mois
```

---

## ✅ Actions Immédiates

### Aujourd'hui
- [ ] Vérifier quotas actuels Firebase Console
- [ ] Configurer email alertes
- [ ] Documenter usage baseline

### Cette Semaine
- [ ] Implémenter compression images
- [ ] Tester usage avec 10-20 utilisateurs beta
- [ ] Calculer projections

### Ce Mois
- [ ] Monitoring hebdomadaire
- [ ] Optimiser si nécessaire
- [ ] Décider timing migration plan Blaze

---

## 📞 Support & Ressources

### Documentation
- Firebase Pricing: https://firebase.google.com/pricing
- Storage Quotas: https://firebase.google.com/docs/storage/quotas-pricing

### Calculateur Officiel
- https://firebase.google.com/pricing#blaze-calculator

### Support Firebase
- Forum: https://groups.google.com/g/firebase-talk
- Stack Overflow: Tag `firebase-storage`

---

**Dernière mise à jour:** 7 Octobre 2025
**Prochaine révision:** Après 1 semaine de tests
