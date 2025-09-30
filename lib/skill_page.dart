// lib/skill_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddSkillDialog({String? skillId, Map<String, dynamic>? existingData}) {
    final nameController = TextEditingController(text: existingData?['name'] ?? '');
    String category = existingData?['category'] ?? "Frontend";
    int level = existingData?['level'] ?? 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(skillId == null ? "Nueva Habilidad" : "Editar Habilidad"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre de la habilidad",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: "Categoría",
                      border: OutlineInputBorder(),
                    ),
                    items: ["Frontend", "Backend", "Mobile", "Database", "Otros"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text("Nivel: "),
                      Expanded(
                        child: Slider(
                          value: level.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: level.toString(),
                          onChanged: (value) {
                            setDialogState(() {
                              level = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text(level.toString()),
                    ],
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
                  if (nameController.text.isNotEmpty) {
                    if (skillId == null) {
                      await _firestoreService.addSkill(
                        name: nameController.text,
                        category: category,
                        level: level,
                      );
                    } else {
                      await _firestoreService.updateSkill(
                        skillId: skillId,
                        data: {
                          'name': nameController.text,
                          'category': category,
                          'level': level,
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Frontend":
        return Colors.blue;
      case "Backend":
        return Colors.green;
      case "Mobile":
        return Colors.purple;
      case "Database":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _deleteAllSkills() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todas las habilidades'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las habilidades? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteAllSkills();
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
        title: const Text('Tus habilidades'),
        actions: [
          IconButton(
            onPressed: _deleteAllSkills,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getSkills(),
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
                  Icon(
                    Icons.psychology_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No hay habilidades aún",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Presiona + para agregar una",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final skills = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              final data = skill.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(
                      data['category'] ?? '',
                    ),
                    child: const Icon(Icons.star, color: Colors.white),
                  ),
                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Categoría: ${data['category'] ?? ''}"),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (data['level'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddSkillDialog(
                          skillId: skill.id,
                          existingData: data,
                        );
                      } else if (value == 'delete') {
                        _firestoreService.deleteSkill(skill.id);
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSkillDialog,
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
