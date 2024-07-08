import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:lesson72/services/location_service.dart';

class ProductService {
  final _firebaseFirestore = FirebaseFirestore.instance.collection('locations');
  final _firebaseStorage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getLocations() async* {
    yield* _firebaseFirestore.snapshots();
  }

  Future<void> addLocations(
    String title,
    String filePath,
  ) async {
    String downloadUrl = await _uploadImage(filePath);
    final location = await LocationService.getCurrentLocation();

    await _firebaseFirestore.add(
      {
        'title': title,
        'photoUrl': downloadUrl,
        'location': '${location.latitude}, ${location.longitude}'
      },
    );
  }

  Future<void> deleteLocation(String id) async {
    await _firebaseFirestore.doc(id).delete();
  }

  Future<void> updateLocation(
    String documentId,
    String title,
    String filePath,
  ) async {
    String downloadUrl =
        filePath.startsWith('http') ? filePath : await _uploadImage(filePath);

    final location = await LocationService.getCurrentLocation();

    await _firebaseFirestore.doc(documentId).update(
      {
        'title': title,
        'photoUrl': downloadUrl,
        'location': '${location.latitude}, ${location.longitude}'
      },
    );
  }

  Future<String> _uploadImage(String filePath) async {
    File file = File(filePath);
    TaskSnapshot snapshot = await _firebaseStorage
        .ref('locations/${file.uri.pathSegments.last}')
        .putFile(file);
    return await snapshot.ref.getDownloadURL();
  }
}
