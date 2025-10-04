import 'package:cloud_firestore/cloud_firestore.dart';

/// Service de base pour toutes les opérations Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée un document dans une collection
  Future<void> createDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Erreur lors de la création du document: $e');
    }
  }

  /// Lit un document
  Future<Map<String, dynamic>?> readDocument(
    String collection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Erreur lors de la lecture du document: $e');
    }
  }

  /// Récupère un document (retourne DocumentSnapshot)
  Future<DocumentSnapshot> getDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).get();
  }

  /// Récupère tous les documents d'une collection
  Future<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).get();
  }

  /// Définit un document (crée ou fusionne)
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
  }

  /// Stream d'une collection
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Stream d'un document
  Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Met à jour un document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du document: $e');
    }
  }

  /// Supprime un document
  Future<void> deleteDocument(
    String collection,
    String documentId,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du document: $e');
    }
  }

  /// Stream pour écouter les changements d'un document
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  /// Requête simple avec filtre
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    String? field,
    dynamic isEqualTo,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      throw Exception('Erreur lors de la requête: $e');
    }
  }

  /// Stream pour écouter une collection
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
    String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Batch write pour plusieurs opérations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (var operation in operations) {
        final docRef = _firestore.collection(operation.collection).doc(operation.documentId);

        switch (operation.type) {
          case BatchOperationType.create:
          case BatchOperationType.update:
            batch.set(docRef, operation.data!, SetOptions(merge: true));
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du batch write: $e');
    }
  }
}

/// Type d'opération batch
enum BatchOperationType { create, update, delete }

/// Opération batch
class BatchOperation {
  final BatchOperationType type;
  final String collection;
  final String documentId;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.collection,
    required this.documentId,
    this.data,
  });
}

