import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String title;
  String photoUrl;
  String location;

  Product({
    required this.id,
    required this.title,
    required this.photoUrl,
    required this.location,
  });

  factory Product.fromJson(QueryDocumentSnapshot snap) {
    return Product(
      id: snap.id,
      title: snap['title'],
      photoUrl: snap['photoUrl'],
      location: snap['location'],
    );
  }
}
