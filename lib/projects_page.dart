// lib/projects_page.dart
import 'package:flutter/material.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 100,
              color: Color(0xFF1E88E5),
            ),
            SizedBox(height: 20),
            Text(
              "Mis Proyectos",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Esta sección estará lista pronto...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí irá la funcionalidad de agregar proyecto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Próximamente: Agregar proyecto")),
          );
        },
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}