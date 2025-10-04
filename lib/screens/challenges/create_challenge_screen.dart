import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/challenge_model.dart';
import '../../services/challenge_service.dart';

/// Screen for creating a new challenge
class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({Key? key}) : super(key: key);

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _rewardController = TextEditingController();
  final ChallengeService _challengeService = ChallengeService();

  ChallengeType _selectedType = ChallengeType.steps;
  ChallengeScope _selectedScope = ChallengeScope.personal;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPublic = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un Défi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre du défi',
                  hintText: 'Ex: Marche de 10 000 pas',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  if (value.trim().length < 5) {
                    return 'Le titre doit contenir au moins 5 caractères';
                  }
                  return null;
                },
                maxLength: 50,
              ),

              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez le défi...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Type Selection
              DropdownButtonFormField<ChallengeType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type de défi',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ChallengeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Target Value
              TextFormField(
                controller: _targetController,
                decoration: InputDecoration(
                  labelText: 'Objectif',
                  hintText: _getTargetHint(),
                  prefixIcon: const Icon(Icons.flag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixText: _getTargetSuffix(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un objectif';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Scope Selection
              DropdownButtonFormField<ChallengeScope>(
                value: _selectedScope,
                decoration: InputDecoration(
                  labelText: 'Portée',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ChallengeScope.values.map((scope) {
                  return DropdownMenuItem(
                    value: scope,
                    child: Text(_getScopeLabel(scope)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedScope = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: _buildDateSelector(
                      label: 'Début',
                      date: _startDate,
                      onTap: () => _selectStartDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateSelector(
                      label: 'Fin',
                      date: _endDate,
                      onTap: () => _selectEndDate(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Reward Points
              TextFormField(
                controller: _rewardController,
                decoration: InputDecoration(
                  labelText: 'Points de récompense (optionnel)',
                  hintText: '100',
                  prefixIcon: const Icon(Icons.stars),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // Public Toggle
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Défi public',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _isPublic
                        ? 'Visible par tous les utilisateurs'
                        : 'Visible uniquement par vous',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  activeColor: AppColors.primary,
                  secondary: Icon(
                    _isPublic ? Icons.public : Icons.lock,
                    color: _isPublic ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Créer le Défi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Sélectionner',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord sélectionner une date de début'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 7)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les dates de début et de fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final challenge = ChallengeModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        scope: _selectedScope,
        creatorId: currentUser.uid,
        participantIds: [currentUser.uid],
        targetValue: int.parse(_targetController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        rewardPoints: int.tryParse(_rewardController.text) ?? 0,
        progress: {currentUser.uid: 0},
        createdAt: DateTime.now(),
        isPublic: _isPublic,
      );

      await _challengeService.createChallenge(challenge);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTypeLabel(ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        return 'Nombre de pas';
      case ChallengeType.distance:
        return 'Distance';
      case ChallengeType.duration:
        return 'Durée';
      case ChallengeType.streak:
        return 'Constance';
    }
  }

  String _getScopeLabel(ChallengeScope scope) {
    switch (scope) {
      case ChallengeScope.personal:
        return 'Personnel';
      case ChallengeScope.group:
        return 'Groupe';
      case ChallengeScope.friends:
        return 'Amis';
      case ChallengeScope.global:
        return 'Global';
    }
  }

  String _getTargetHint() {
    switch (_selectedType) {
      case ChallengeType.steps:
        return '10000';
      case ChallengeType.distance:
        return '5';
      case ChallengeType.duration:
        return '30';
      case ChallengeType.streak:
        return '7';
    }
  }

  String _getTargetSuffix() {
    switch (_selectedType) {
      case ChallengeType.steps:
        return 'pas';
      case ChallengeType.distance:
        return 'km';
      case ChallengeType.duration:
        return 'min';
      case ChallengeType.streak:
        return 'jours';
    }
  }
}

