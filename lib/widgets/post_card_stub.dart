// Stub pour les plateformes non-web (Android, iOS)
import 'dart:typed_data';

void downloadImageWebImpl(Uint8List imageBytes, String filename) {
  // Ne fait rien sur mobile car le partage natif est utilisé
}

