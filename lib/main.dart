// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'projects_page.dart';
import 'theme_notifier.dart';
import 'splash_screen.dart';
import 'skill_page.dart';
import 'contact_page.dart';
import 'package:firebase_core/firebase_core.dart';

// - 🎯 Próximos pasos después de configurar:
  // 1. Reemplazar login simulado por Firebase Auth
  // 2.  Guardar proyectos en Firestore
  // 3. Subir imágenes a Firebase Storage
  // 4. Sincronización automática
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAM-9B4wiL_uNizTDb63SArvhEON-k69OU",
        authDomain: "mi-portafolio-flutter.firebaseapp.com",
        projectId: "mi-portafolio-flutter",
        storageBucket: "mi-portafolio-flutter.firebasestorage.app",
        messagingSenderId: "535815520030",
        appId: "1:535815520030:web:ec0ae4bbe0c2ea725fd30f",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Portafolio Personal',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

// * Pagina de registro/login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Simulación de "base de datos" con un Map
  final Map<String, String> _users = {"a": "a", "sebastian": "1234"};

  String _message = "";

  void _login() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    if (_users.containsKey(user) && _users[user] == pass) {
      setState(() {
        _message = "✅ Bienvenido, $user";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(username: user)),
      );
    } else {
      setState(() {
        _message = "❌ Usuario o contraseña incorrectos";
      });
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage(users: _users)),
    ).then((_) {
      // Refrescar la pantalla al volver
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        title: const Row(
          children: [
            Icon(Icons.person_4_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text("Mi Portafolio", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Usuario",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(3.0),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Ingresar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  margin: const EdgeInsets.all(3.0),
                  child: TextButton(
                    onPressed: _goToRegister,
                    child: const Text("Crear cuenta"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// * Pagina de registro
class RegisterPage extends StatefulWidget {
  final Map<String, String> users;

  const RegisterPage({super.key, required this.users});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _newUserController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  String _message = "";

  void _register() {
    String user = _newUserController.text.trim();
    String pass = _newPassController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() {
        _message = "❗ Los campos no pueden estar vacíos";
      });
      return;
    }
    if (widget.users.containsKey(user)) {
      setState(() {
        _message = "❗ El usuario ya existe";
      });
    } else {
      widget.users[user] = pass;
      setState(() {
        _message = "✅ Usuario registrado con éxito";
      });

      // Volver al login después de un segundo
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _newUserController,
              decoration: const InputDecoration(
                labelText: "Nuevo usuario",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nueva contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
              ),
              child: const Text(
                "Registrar",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

// * Pagina de inicio (home)
class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "Nombre de Usuario";
  String email = "correo@ejemplo.com";
  String bio = "Aquí va una breve descripción del usuario.";
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? name;
      email = prefs.getString("email") ?? email;
      bio = prefs.getString("bio") ?? bio;
      imagePath = prefs.getString("imagePath");
    });
  }

  Future<void> _saveProfile(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
      _saveProfile("imagePath", pickedFile.path);
    }
  }

  void _editField(
    String field,
    String currentValue,
    Function(String) onSave,
    String key,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar $field"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = controller.text;
              onSave(newValue);
              _saveProfile(key, newValue);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: imagePath != null
                        ? FileImage(File(imagePath!))
                        : const AssetImage("assets/avatar.png")
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editField(
                    "Nombre",
                    name,
                    (v) => setState(() => name = v),
                    "name",
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editField(
                    "Correo",
                    email,
                    (v) => setState(() => email = v),
                    "email",
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: Text(bio),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editField(
                    "Biografía",
                    bio,
                    (v) => setState(() => bio = v),
                    "bio",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// * Dashboard page
class DashboardPage extends StatefulWidget {
  final String username;

  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// * Menu lateral de navegacion
class _DashboardPageState extends State<DashboardPage> {
  int _selectedBottomIndex = 0; // Para el menú inferior

  // Páginas del menú inferior
  late List<Widget> _bottomPages;

  // Títulos para el AppBar según la página seleccionada
  final List<String> _pageTitles = ["Proyectos", "Habilidades", "Contacto"];

  @override
  void initState() {
    super.initState();
    _bottomPages = [
      const ProjectsPage(), // Proyectos
      const SkillsPage(), // Habilidades
      const ContactPage(), // Contacto
    ];
  }

  void _onBottomItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(username: widget.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedBottomIndex]),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),

      // ✅ DRAWER LATERAL: Solo perfil, configuración y logout
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E88E5)),
              accountName: Text(widget.username),
              accountEmail: const Text("mi.portafolio@ejemplo.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF1E88E5)),
              ),
            ),

            // Ir al perfil
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Ver Perfil"),
              onTap: () {
                Navigator.pop(context); // Cerrar drawer
                _goToProfile();
              },
            ),

            const Divider(),

            // Modo oscuro
            Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) {
                return SwitchListTile(
                  title: const Text("Modo oscuro"),
                  secondary: const Icon(Icons.brightness_6),
                  value: themeNotifier.isDarkMode,
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                );
              },
            ),

            const Divider(),

            // Cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ✅ CONTENIDO PRINCIPAL
      body: _bottomPages[_selectedBottomIndex],

      // ✅ MENÚ INFERIOR: Proyectos, Habilidades, Contacto
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedBottomIndex,
        onDestinationSelected: _onBottomItemTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Proyectos',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Habilidades',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacto',
          ),
        ],
      ),
    );
  }
}
