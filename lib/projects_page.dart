// lib/projects_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/firestore_service.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showProjectDialog({String? projectId, Map<String, dynamic>? existingData}) {
    final titleController = TextEditingController(text: existingData?['title'] ?? '');
    final descController = TextEditingController(text: existingData?['description'] ?? '');
    final techController = TextEditingController(text: existingData?['technologies'] ?? '');
    final linkController = TextEditingController(text: existingData?['link'] ?? '');
    String status = existingData?['status'] ?? "En desarrollo";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(projectId == null ? "Nuevo Proyecto" : "Editar Proyecto"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Título",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Descripción",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: techController,
                    decoration: const InputDecoration(
                      labelText: "Tecnologías (ej: Flutter, Firebase)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: linkController,
                    decoration: const InputDecoration(
                      labelText: "Enlace (GitHub u otro repositorio)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: "Estado",
                      border: OutlineInputBorder(),
                    ),
                    items: ["En desarrollo", "Completado", "Pausado"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        status = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    if (projectId == null) {
                      await _firestoreService.addProject(
                        title: titleController.text,
                        description: descController.text,
                        technologies: techController.text,
                        status: status,
                        link: linkController.text.isNotEmpty ? linkController.text : null,
                      );
                    } else {
                      await _firestoreService.updateProject(
                        projectId: projectId,
                        data: {
                          'title': titleController.text,
                          'description': descController.text,
                          'technologies': techController.text,
                          'status': status,
                          'link': linkController.text.isNotEmpty ? linkController.text : null,
                        },
                      );
                    }
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completado":
        return Colors.green;
      case "En desarrollo":
        return Colors.orange;
      case "Pausado":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _deleteAllProjects() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todos los proyectos'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los proyectos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteAllProjects();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus proyectos'),
        actions: [
          IconButton(
            onPressed: _deleteAllProjects,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "No hay proyectos aún",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Presiona + para agregar uno",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final data = project.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(data['status'] ?? ''),
                    child: const Icon(Icons.code, color: Colors.white),
                  ),
                  title: Text(
                    data['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(data['description'] ?? ''),
                      const SizedBox(height: 5),
                      Text(
                        "Tech: ${data['technologies'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          data['status'] ?? '',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: _getStatusColor(
                          data['status'] ?? '',
                        ).withValues(alpha: 0.2),
                      ),
                      if (data['link'] != null && data['link'].isNotEmpty)
                        IconButton(
                          onPressed: () => launchUrl(Uri.parse(data['link'])),
                          icon: const Icon(Icons.link),
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showProjectDialog(
                              projectId: project.id,
                              existingData: data,
                            );
                          } else if (value == 'delete') {
                            _firestoreService.deleteProject(project.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectDialog(),
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
