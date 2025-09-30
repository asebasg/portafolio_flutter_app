// lib/contact_page.dart
import 'package:flutter/material.dart';
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
  bool _hasContact = false;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
    // keep preview in sync when user types
    _phoneController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
    _linkedinController.addListener(() => setState(() {}));
    _githubController.addListener(() => setState(() {}));
    _websiteController.addListener(() => setState(() {}));
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
          _hasContact = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasContact = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveContactInfo() async {
    // saving state not tracked by UI (dialog disables itself)

    try {
      await _firestoreService.updateContact(
        phone: _phoneController.text,
        location: _locationController.text,
        linkedin: _linkedinController.text,
        github: _githubController.text,
        website: _websiteController.text,
      );

      if (mounted) {
        setState(() {
          _hasContact = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Información guardada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      }
    } finally {}
  }

  Future<void> _deleteContact() async {
    try {
      await _firestoreService.deleteContact();
      if (mounted) {
        setState(() {
          _phoneController.clear();
          _locationController.clear();
          _linkedinController.clear();
          _githubController.clear();
          _websiteController.clear();
          _hasContact = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Información eliminada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error eliminando: $e')));
      }
    }
  }

  Future<void> _showEditDialog({required bool isEditing}) async {
    if (!isEditing) {
      // clear controllers for adding
      _phoneController.clear();
      _locationController.clear();
      _linkedinController.clear();
      _githubController.clear();
      _websiteController.clear();
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar información de contacto' : 'Añadir información de contacto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Ubicación', prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn', prefixIcon: Icon(Icons.work)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _githubController,
                decoration: const InputDecoration(labelText: 'GitHub', prefixIcon: Icon(Icons.code)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Sitio Web', prefixIcon: Icon(Icons.language)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _saveContactInfo();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información de Contacto', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Completa tu información para que otros puedan contactarte', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // Add card when no contact
            if (!_hasContact)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('No hay información de contacto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text('Pulsa para añadir tu información de contacto.'),
                          ],
                        ),
                      ),
                      ElevatedButton(onPressed: () => _showEditDialog(isEditing: false), child: const Text('Añadir')),
                    ],
                  ),
                ),
              )
            else
              // Preview card with edit/delete menu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.contact_mail, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Información de contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await _showEditDialog(isEditing: true);
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar'),
                                          content: const Text('¿Seguro que quieres eliminar la información de contacto?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) await _deleteContact();
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_phoneController.text.isNotEmpty)
                              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.phone), title: Text(_phoneController.text), dense: true),
                            if (_locationController.text.isNotEmpty)
                              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_on), title: Text(_locationController.text), dense: true),
                            if (_linkedinController.text.isNotEmpty)
                              const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.work), title: Text('LinkedIn'), dense: true),
                            if (_githubController.text.isNotEmpty)
                              const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.code), title: Text('GitHub'), dense: true),
                            if (_websiteController.text.isNotEmpty)
                              const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.language), title: Text('Sitio Web'), dense: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.removeListener(() {});
    _locationController.removeListener(() {});
    _linkedinController.removeListener(() {});
    _githubController.removeListener(() {});
    _websiteController.removeListener(() {});
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
