// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'projects_page.dart';
import 'theme_notifier.dart';
import 'splash_screen.dart';
import 'skill_page.dart';
import 'contact_page.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      title: 'PortApp',
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

// ========== LOGIN PAGE CON FIREBASE ==========
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _message = "";
  bool _isLoading = false;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String pass = _passController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _message = "❗ Completa todos los campos";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (mounted) {
        // persist email and name locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        final displayName = _authService.currentUser?.displayName;
        if (displayName != null && displayName.isNotEmpty) {
          await prefs.setString('name', displayName);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              username: _authService.currentUser?.displayName ?? email,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = "❌ $e";
        _isLoading = false;
      });
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
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
            Text("PortApp", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Ingresar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _goToRegister,
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// ========== REGISTER PAGE CON FIREBASE ==========
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _message = "";
  bool _isLoading = false;

  Future<void> _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String pass = _passController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() {
        _message = "❗ Completa todos los campos";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: pass,
        displayName: name,
      );

        // save email and name locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('name', name);

        setState(() {
          _message = "✅ Usuario registrado con éxito";
          _isLoading = false;
        });

      // Volver al login después de 1.5 segundos
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _message = "❌ $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña (mínimo 6 caracteres)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Registrar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  fontSize: 14,
                  color: _message.contains("✅") ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// ========== HOME PAGE (PERFIL) ==========
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
      // upload to Firebase Storage and save URL
      try {
        final firestore = FirestoreService();
        final url = await firestore.uploadProfileImage(pickedFile);
        await firestore.setProfileImageUrl(url);
        // persist the image url locally so drawer/profile can read it
        await _saveProfile("imagePath", url);
        if (mounted) {
          setState(() {
            imagePath = url;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error subiendo imagen: $e')));
        }
      }
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
              if (key == 'name') {
                // If user leaves name empty, keep the existing registered name
                final finalName = newValue.trim().isEmpty ? name : newValue;
                onSave(finalName);
                _saveProfile(key, finalName);
                try {
                  final authService = FirebaseAuthService();
                  authService.updateDisplayName(finalName);
                } catch (_) {}
              } else {
                onSave(newValue);
                _saveProfile(key, newValue);
              }
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
                  Builder(builder: (context) {
                    ImageProvider? avatarProvider;
                    if (imagePath != null && imagePath!.isNotEmpty) {
                      if (imagePath!.startsWith('http')) {
                        avatarProvider = NetworkImage(imagePath!);
                      } else {
                        avatarProvider = FileImage(File(imagePath!));
                      }
                    } else {
                      avatarProvider = const AssetImage("assets/avatar.png");
                    }

                    return CircleAvatar(
                      radius: 60,
                      backgroundImage: avatarProvider,
                    );
                  }),
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
            // email is displayed in drawer/header; editing email from profile removed
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

// ========== DASHBOARD PAGE ==========
class DashboardPage extends StatefulWidget {
  final String username;

  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedBottomIndex = 0;
  late List<Widget> _bottomPages;
  final List<String> _pageTitles = ["Proyectos", "Habilidades", "Contacto"];
  String _drawerName = '';
  String _drawerEmail = '';
  String? _drawerImagePath;

  @override
  void initState() {
    super.initState();
    _bottomPages = [
      const ProjectsPage(),
      const SkillsPage(),
      const ContactPage(),
    ];
    _loadDrawerInfo();
  }

  Future<void> _loadDrawerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _drawerName = prefs.getString('name') ?? widget.username;
      _drawerEmail = prefs.getString('email') ?? 'mi.portafolio@ejemplo.com';
      _drawerImagePath = prefs.getString('imagePath');
    });
  }

  void _onBottomItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  void _goToProfile() {
    // Navigate to profile and refresh when returning so drawer/header show updated info
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(username: widget.username),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedBottomIndex]),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E88E5)),
              accountName: Text(_drawerName.isNotEmpty ? _drawerName : widget.username),
              accountEmail: Text(_drawerEmail.isNotEmpty ? _drawerEmail : 'mi.portafolio@ejemplo.com'),
              currentAccountPicture: _drawerImagePath != null && _drawerImagePath!.isNotEmpty
                  ? (_drawerImagePath!.startsWith('http')
                      ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(_drawerImagePath!))
                      : CircleAvatar(backgroundImage: FileImage(File(_drawerImagePath!))))
                  : const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFF1E88E5)),
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Ver Perfil"),
              onTap: () {
                Navigator.pop(context);
                _goToProfile();
              },
            ),
            const Divider(),
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
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final authService = FirebaseAuthService();
                await authService.signOut();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: _bottomPages[_selectedBottomIndex],
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
