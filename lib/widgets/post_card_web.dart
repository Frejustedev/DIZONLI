// Implémentation web pour le téléchargement d'images
import 'dart:typed_data';
import 'dart:html' as html;

void downloadImageWebImpl(Uint8List imageBytes, String filename) {
  final blob = html.Blob([imageBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

