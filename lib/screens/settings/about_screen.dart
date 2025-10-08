import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Écran À propos de DIZONLI avec description complète et FAQ
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('À propos de DIZONLI'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec logo
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Description de l'application
            _buildSection(
              icon: Icons.info_outline,
              title: 'Qu\'est-ce que DIZONLI ?',
              content: 'DIZONLI est une application innovante de suivi de pas et de défis sportifs avec une forte dimension sociale. '
                  'Elle vous permet de suivre votre activité physique quotidienne, de relever des défis passionnants, '
                  'de vous connecter avec vos amis et de rester motivé dans votre parcours vers une vie plus active et saine.',
            ),
            
            const Divider(height: 32, thickness: 1),
            
            // Fonctionnalités principales
            _buildSection(
              icon: Icons.star,
              title: 'Fonctionnalités principales',
              children: [
                _buildFeature('📊', 'Suivi des pas', 'Comptez vos pas automatiquement avec Google Fit ou Health Connect en arrière-plan 24h/24.'),
                _buildFeature('🎯', 'Objectifs personnalisés', 'Définissez votre objectif quotidien de pas et suivez votre progression en temps réel.'),
                _buildFeature('📈', 'Statistiques détaillées', 'Consultez vos statistiques : pas, distance, calories, temps de marche par jour, semaine, mois ou année.'),
                _buildFeature('👥', 'Réseau social', 'Ajoutez des amis, suivez leurs performances et comparez vos résultats.'),
                _buildFeature('🏆', 'Système de badges', 'Débloquez des badges en atteignant des jalons (pas, niveaux, amis).'),
                _buildFeature('🏃', 'Groupes et défis', 'Créez ou rejoignez des groupes, participez à des classements compétitifs.'),
                _buildFeature('🎮', 'Défis variés', 'Relevez des défis quotidiens, hebdomadaires ou à la une pour gagner des récompenses.'),
                _buildFeature('⏱️', 'Temps de marche', 'Calculé automatiquement en fonction de vos pas et de votre vitesse moyenne.'),
                _buildFeature('🔔', 'Notifications', 'Recevez des alertes pour les nouveaux badges, demandes d\'ami et défis.'),
                _buildFeature('👤', 'Profil personnalisable', 'Ajoutez votre pseudo, photo, informations physiques (poids, taille, IMC).'),
              ],
            ),
            
            const Divider(height: 32, thickness: 1),
            
            // Comment ça marche
            _buildSection(
              icon: Icons.help_outline,
              title: 'Comment ça marche ?',
              children: [
                _buildStep('1', 'Créez votre compte', 'Inscrivez-vous avec votre email et renseignez vos informations.'),
                _buildStep('2', 'Autorisez le suivi', 'Activez Google Fit (Android) ou Health Connect pour un suivi automatique 24h/24.'),
                _buildStep('3', 'Définissez votre objectif', 'Choisissez votre objectif quotidien de pas (par défaut 10 000 pas).'),
                _buildStep('4', 'Marchez et progressez', 'L\'app compte automatiquement vos pas en arrière-plan.'),
                _buildStep('5', 'Ajoutez des amis', 'Recherchez et ajoutez des amis pour comparer vos performances.'),
                _buildStep('6', 'Rejoignez des groupes', 'Créez ou rejoignez des groupes pour des classements compétitifs.'),
                _buildStep('7', 'Relevez des défis', 'Participez à des défis pour vous dépasser et gagner des récompenses.'),
                _buildStep('8', 'Débloquez des badges', 'Atteignez des jalons pour débloquer des badges (pas, niveaux, amis).'),
              ],
            ),
            
            const Divider(height: 32, thickness: 1),
            
            // FAQ
            _buildSection(
              icon: Icons.question_answer,
              title: 'Questions fréquentes (FAQ)',
              children: [
                _buildFAQ(
                  'Comment mes pas sont-ils comptés ?',
                  'DIZONLI utilise Google Fit (Android) ou Health Connect pour compter vos pas automatiquement 24h/24. '
                  'Si ces systèmes ne sont pas disponibles, l\'app utilise le capteur de votre téléphone (uniquement quand l\'app est ouverte).',
                ),
                _buildFAQ(
                  'Pourquoi mes pas ne s\'affichent pas ?',
                  'Assurez-vous d\'avoir autorisé les permissions pour Google Fit/Health Connect. '
                  'Si le problème persiste, faites un "Pull to refresh" (tirez vers le bas) sur la page d\'accueil pour synchroniser.',
                ),
                _buildFAQ(
                  'Comment fonctionne le calcul du temps de marche ?',
                  'Le temps est calculé automatiquement : Distance = pas × 0.762 m, Vitesse moyenne = 5 km/h, Temps = Distance ÷ Vitesse.',
                ),
                _buildFAQ(
                  'Comment ajouter des amis ?',
                  'Allez dans l\'onglet "Social", cliquez sur "Amis", puis sur le bouton "+". '
                  'Recherchez vos amis par leur nom ou email et envoyez une demande.',
                ),
                _buildFAQ(
                  'Comment créer un groupe ?',
                  'Dans l\'onglet "Social", allez dans "Groupes", cliquez sur le bouton "+" et remplissez les informations. '
                  'Vous pouvez ensuite inviter des amis à rejoindre votre groupe.',
                ),
                _buildFAQ(
                  'Comment débloquer des badges ?',
                  'Les badges se débloquent automatiquement quand vous atteignez certains jalons : '
                  'nombre de pas total, niveau, nombre d\'amis. Consultez la liste complète dans "Profil > Badges".',
                ),
                _buildFAQ(
                  'Qu\'est-ce que le niveau ?',
                  'Votre niveau augmente en fonction de votre activité totale (pas, défis complétés, badges). '
                  'Plus vous êtes actif, plus vous montez de niveau !',
                ),
                _buildFAQ(
                  'Comment modifier mon objectif quotidien ?',
                  'Allez dans "Paramètres", cliquez sur "Objectif quotidien" et définissez votre nouveau objectif.',
                ),
                _buildFAQ(
                  'Puis-je modifier mes informations physiques ?',
                  'Oui ! Dans "Profil", cliquez sur l\'icône d\'édition dans la section "Informations physiques". '
                  'Vous pouvez mettre à jour votre poids et taille. L\'IMC sera calculé automatiquement.',
                ),
                _buildFAQ(
                  'Comment changer mon pseudo ?',
                  'Dans votre "Profil", cliquez sur votre pseudo (sous votre nom) pour le modifier.',
                ),
                _buildFAQ(
                  'Les données sont-elles sécurisées ?',
                  'Oui ! Toutes vos données sont stockées de manière sécurisée sur Firebase avec chiffrement. '
                  'Nous ne partageons jamais vos données avec des tiers.',
                ),
                _buildFAQ(
                  'L\'application fonctionne-t-elle hors ligne ?',
                  'Le comptage de pas fonctionne hors ligne, mais vous devez être connecté à Internet '
                  'pour synchroniser vos données, voir vos amis et accéder aux fonctionnalités sociales.',
                ),
                _buildFAQ(
                  'Comment supprimer mon compte ?',
                  'Pour supprimer votre compte, contactez-nous via l\'option "Contacter le support" dans les paramètres.',
                ),
              ],
            ),
            
            const Divider(height: 32, thickness: 1),
            
            // Informations légales
            _buildSection(
              icon: Icons.gavel,
              title: 'Informations légales',
              content: 'DIZONLI respecte votre vie privée. Vos données de santé (pas, distance, calories) sont uniquement utilisées '
                  'pour améliorer votre expérience dans l\'application. Elles ne sont jamais vendues ou partagées avec des tiers.',
            ),
            
            const SizedBox(height: 24),
            
            // Version et copyright
            _buildFooter(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          // Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_walk,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DIZONLI',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Marchez, Défiez, Évoluez',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          if (children != null) ...children,
        ],
      ),
    );
  }

  Widget _buildFeature(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Version 1.0.0-beta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '08 Octobre 2025',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '© 2025 DIZONLI. Tous droits réservés.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fait avec ❤️ pour une vie plus active',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

