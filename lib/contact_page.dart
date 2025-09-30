// lib/contact_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    try {
      final doc = await _firestoreService.getContact();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _phoneController.text = data['phone'] ?? '';
          _locationController.text = data['location'] ?? '';
          _linkedinController.text = data['linkedin'] ?? '';
          _githubController.text = data['github'] ?? '';
          _websiteController.text = data['website'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContactInfo() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateContact(
        phone: _phoneController.text,
        location: _locationController.text,
        linkedin: _linkedinController.text,
        github: _githubController.text,
        website: _websiteController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Información guardada")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Información de Contacto",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Completa tu información para que otros puedan contactarte",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Teléfono",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Ubicación",
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _linkedinController,
              decoration: const InputDecoration(
                labelText: "LinkedIn",
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
                hintText: "https://linkedin.com/in/tu-perfil",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _githubController,
              decoration: const InputDecoration(
                labelText: "GitHub",
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
                hintText: "https://github.com/tu-usuario",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: "Sitio Web",
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
                hintText: "https://tu-sitio.com",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveContactInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Guardar Información",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          "Vista Previa",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_phoneController.text.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(_phoneController.text),
                        dense: true,
                      ),
                    if (_locationController.text.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(_locationController.text),
                        dense: true,
                      ),
                    if (_linkedinController.text.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.work),
                        title: const Text("LinkedIn"),
                        dense: true,
                      ),
                    if (_githubController.text.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text("GitHub"),
                        dense: true,
                      ),
                    if (_websiteController.text.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text("Sitio Web"),
                        dense: true,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
