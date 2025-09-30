// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';

  // ========== PROYECTOS ==========

  // Obtener proyectos del usuario actual
  Stream<QuerySnapshot> getProjects() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Agregar proyecto
  Future<void> addProject({
    required String title,
    required String description,
    required String technologies,
    required String status,
    String? imageUrl,
    String? link,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .add({
          'title': title,
          'description': description,
          'technologies': technologies,
          'status': status,
          'imageUrl': imageUrl,
          'link': link,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Actualizar proyecto
  Future<void> updateProject({
    required String projectId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(projectId)
        .update(data);
  }

  // Eliminar proyecto
  Future<void> deleteProject(String projectId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(projectId)
        .delete();
  }

  // Eliminar todos los proyectos
  Future<void> deleteAllProjects() async {
    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .get();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ========== HABILIDADES ==========

  // Obtener habilidades
  Stream<QuerySnapshot> getSkills() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .orderBy('category')
        .snapshots();
  }

  // Agregar habilidad
  Future<void> addSkill({
    required String name,
    required String category,
    required int level,
  }) async {
    await _firestore.collection('users').doc(userId).collection('skills').add({
      'name': name,
      'category': category,
      'level': level,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Actualizar habilidad
  Future<void> updateSkill({
    required String skillId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .doc(skillId)
        .update(data);
  }

  // Eliminar habilidad
  Future<void> deleteSkill(String skillId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .doc(skillId)
        .delete();
  }

  // Eliminar todas las habilidades
  Future<void> deleteAllSkills() async {
    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .get();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ========== PERFIL ==========

  // Obtener datos del perfil
  Future<DocumentSnapshot> getProfile() {
    return _firestore.collection('users').doc(userId).get();
  }

  // Actualizar perfil
  Future<void> updateProfile({
    required String name,
    required String email,
    required String bio,
    String? imageUrl,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'bio': bio,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ========== CONTACTO ==========

  // Obtener información de contacto
  Future<DocumentSnapshot> getContact() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('info')
        .doc('contact')
        .get();
  }

  // Actualizar contacto
  Future<void> updateContact({
    required String phone,
    required String location,
    required String linkedin,
    required String github,
    required String website,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('info')
        .doc('contact')
        .set({
          'phone': phone,
          'location': location,
          'linkedin': linkedin,
          'github': github,
          'website': website,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // Eliminar contacto
  Future<void> deleteContact() async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('info')
        .doc('contact')
        .delete();
  }

  // Subir imagen de perfil a Firebase Storage y devolver la URL
  Future<String> uploadProfileImage(XFile image) async {
    if (userId.isEmpty) throw Exception('Usuario no autenticado');
    final bytes = await image.readAsBytes();
    final path = 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);
    final meta = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(bytes, meta);
    final url = await ref.getDownloadURL();
    return url;
  }

  // Guardar solo la URL de la imagen en el documento del usuario
  Future<void> setProfileImageUrl(String imageUrl) async {
    if (userId.isEmpty) throw Exception('Usuario no autenticado');
    await _firestore.collection('users').doc(userId).set({
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
