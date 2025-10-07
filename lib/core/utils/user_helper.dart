import '../../models/user_model.dart';

/// Extension pour ajouter des helpers au UserModel
extension UserModelHelper on UserModel {
  /// Extrait le prénom du champ `name`
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }
  
  /// Extrait le nom de famille du champ `name`
  String get lastName {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return '';
  }
  
  /// Alias pour photoUrl (compatibilité)
  String get photoURL => photoUrl ?? '';
  
  /// Retourne les initiales pour l'avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  
  /// Format le nombre de pas
  String get formattedSteps {
    if (totalSteps >= 1000000) {
      return '${(totalSteps / 1000000).toStringAsFixed(1)}M';
    } else if (totalSteps >= 1000) {
      return '${(totalSteps / 1000).toStringAsFixed(1)}k';
    }
    return totalSteps.toString();
  }
}
