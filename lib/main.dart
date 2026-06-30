import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

Future<void> testNetwork() async {
  try {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
    );
    debugPrint('Network status: ${response.statusCode}');
  } catch (e) {
    debugPrint('Network error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await testNetwork();
  await initializeNotifications();
  runApp(const EmergencyApp());
}

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await notificationsPlugin.initialize(settings: initializationSettings);
}

Future<void> showSafetyNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'safety_channel',
    'Safety Alerts',
    channelDescription: 'Instant emergency safety alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await notificationsPlugin.show(
    id: 0,
    title: 'Safety Alert',
    body: 'Stay alert. Emergency safety notifications are active.',
    notificationDetails: notificationDetails,
  );
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emergency Response App',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _ambulanceOffset;
  late final Animation<double> _ambulanceOpacity;
  late final Animation<Offset> _policeOffset;
  late final Animation<double> _policeOpacity;
  late final Animation<Offset> _fireOffset;
  late final Animation<double> _fireOpacity;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          });

    _ambulanceOffset =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.5, curve: Curves.easeOut),
          ),
        );

    _ambulanceOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _policeOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

    _policeOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    _fireOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1, curve: Curves.easeOut),
          ),
        );

    _fireOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: Colors.redAccent,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Emergency Response',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Every second counts to save a life',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _ambulanceOffset,
                        child: FadeTransition(
                          opacity: _ambulanceOpacity,
                          child: const _SplashIconCard(
                            icon: Icons.local_hospital,
                            label: 'Ambulance',
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      SlideTransition(
                        position: _policeOffset,
                        child: FadeTransition(
                          opacity: _policeOpacity,
                          child: const _SplashIconCard(
                            icon: Icons.local_police,
                            label: 'Police',
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      SlideTransition(
                        position: _fireOffset,
                        child: FadeTransition(
                          opacity: _fireOpacity,
                          child: const _SplashIconCard(
                            icon: Icons.fire_truck,
                            label: 'Fire',
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashIconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SplashIconCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLogin = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  Future<void> createAccount() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await credential.user?.updateDisplayName(nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account creation failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 35),
                Container(
                  width: 95,
                  height: 95,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 58,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Emergency Response',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Every second counts to save a life',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 28),
                Text(
                  isLogin ? 'Login' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                if (!isLogin) ...[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isLogin) {
                        await loginUser();
                      } else {
                        await createAccount();
                      }
                    },
                    child: Text(isLogin ? 'LOGIN' : 'CREATE ACCOUNT'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don't have an account? Create Account"
                        : 'Already have an account? Login',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    DashboardPage(),
    ContactsPage(),
    ReportPage(),
    NearbyHelpPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.contacts), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.report), label: 'Report'),
          NavigationDestination(
            icon: Icon(Icons.local_hospital),
            label: 'Help',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Position?> _getCurrentPosition(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please turn on location services.')),
        );
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
      }
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> sendSms(String phone, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> sendSosAlert(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final position = await _getCurrentPosition(context);
    if (position == null) {
      return;
    }

    final locationLink =
        'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

    final contactsSnapshot = await FirebaseFirestore.instance
        .collection('emergency_contacts')
        .where('userId', isEqualTo: user.uid)
        .get();

    final phones = contactsSnapshot.docs
        .map((doc) => (doc.data()['phone'] ?? '').toString().trim())
        .where((phone) => phone.isNotEmpty)
        .toList();

    final message =
        'Emergency! I need help. My live location is: $locationLink';

    if (phones.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contacts saved. Add contacts first.'),
          ),
        );
      }
      return;
    }

    for (final phone in phones) {
      await sendSms(phone, message);
    }

    await SharePlus.instance.share(
      ShareParams(text: '$message\n\nEmergency contacts: ${phones.join(', ')}'),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SOS location opened for ${phones.length} contact(s).'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@')[0] ?? 'User';

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hello, $userName!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Are you safe today?',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => sendSosAlert(context),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 52,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ResponsiveGrid(
                children: [
                  FeatureCard(
                    icon: Icons.location_on,
                    title: 'Live Location',
                    subtitle: 'Share GPS location',
                    color: Colors.blue,
                    onTap: () async {
                      final position = await _getCurrentPosition(context);
                      if (position == null) return;
                      final locationLink =
                          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
                      await SharePlus.instance.share(
                        ShareParams(text: 'My live location: $locationLink'),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.phone,
                    title: 'Quick Call',
                    subtitle: 'Call emergency services',
                    color: Colors.green,
                    onTap: () async {
                      final Uri phoneUri = Uri.parse('tel:999');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                  ),
                  FeatureCard(
                    icon: Icons.warning,
                    title: 'Risk Alert',
                    subtitle: 'View safety warnings',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RiskAlertPage(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.notifications_active,
                    title: 'Notifications',
                    subtitle: 'Instant safety alerts',
                    color: Colors.purple,
                    onTap: () async => showSafetyNotification(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  @override
  void dispose() {
    contactNameController.dispose();
    contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> addEmergencyContact() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = contactNameController.text.trim();
    final phone = contactPhoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both name and phone number.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('emergency_contacts').add({
      'userId': user.uid,
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });

    contactNameController.clear();
    contactPhoneController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Emergency contact added.')));
  }

  Future<void> deleteContact(String docId) async {
    await FirebaseFirestore.instance
        .collection('emergency_contacts')
        .doc(docId)
        .delete();
  }

  Future<void> callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppPage(
      title: 'Emergency Contacts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add people who should receive your location when SOS is pressed.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: contactNameController,
            decoration: const InputDecoration(
              labelText: 'Contact Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contactPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: addEmergencyContact,
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Saved Contacts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emergency_contacts')
                .where('userId', isEqualTo: user?.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No emergency contacts added yet.');
              }

              final contacts = snapshot.data!.docs;

              return Column(
                children: contacts.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unnamed';
                  final phone = data['phone'] ?? '';

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(name),
                      subtitle: Text(phone),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => callContact(phone),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteContact(doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RiskAlertPage extends StatelessWidget {
  const RiskAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Risk Alerts',
      child: Column(
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('High Risk Area'),
              subtitle: Text('Avoid isolated areas and stay alert.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_fire_department, color: Colors.red),
              title: Text('Fire Risk'),
              subtitle: Text('Report smoke, fire, or gas leaks immediately.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.health_and_safety, color: Colors.blue),
              title: Text('Medical Emergency'),
              subtitle: Text('Call emergency services if someone is injured.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.flood, color: Colors.teal),
              title: Text('Flood Warning'),
              subtitle: Text('Avoid flooded roads and move to safer areas.'),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? incidentType;
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (incidentType == null || descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select incident type and add description.'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('incident_reports').add({
      'userId': user.uid,
      'email': user.email,
      'incidentType': incidentType,
      'description': descriptionController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    descriptionController.clear();
    setState(() => incidentType = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Incident report saved')));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppPage(
      title: 'Report Incident',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: incidentType,
            decoration: const InputDecoration(
              labelText: 'Incident Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Medical', child: Text('Medical')),
              DropdownMenuItem(value: 'Fire', child: Text('Fire')),
              DropdownMenuItem(value: 'Accident', child: Text('Accident')),
              DropdownMenuItem(value: 'Crime', child: Text('Crime')),
            ],
            onChanged: (value) => setState(() => incidentType = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Explain what happened...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: saveReport,
              icon: const Icon(Icons.send),
              label: const Text('Submit Report'),
            ),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('incident_reports')
                .where('userId', isEqualTo: user?.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final reports = snapshot.data!.docs;
              if (reports.isEmpty) {
                return const Text('No reports submitted yet.');
              }

              return Column(
                children: reports.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.report, color: Colors.red),
                      title: Text(data['incidentType'] ?? 'Unknown'),
                      subtitle: Text(data['description'] ?? ''),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NearbyHelpPage extends StatelessWidget {
  const NearbyHelpPage({super.key});

  static const places = [
    ['Nearest Hospital', '2.1 km away', Icons.local_hospital, Colors.red],
    ['Police Station', '3.4 km away', Icons.local_police, Colors.blue],
    ['Pharmacy', '1.2 km away', Icons.medication, Colors.green],
    ['Fire Station', '4.0 km away', Icons.fire_truck, Colors.orange],
  ];

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Nearby Help',
      child: Column(
        children: places.map((place) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: place[3] as Color,
                child: Icon(place[2] as IconData, color: Colors.white),
              ),
              title: Text(place[0] as String),
              subtitle: Text(place[1] as String),
              trailing: const Icon(Icons.directions),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? '';
    emailController.text = user?.email ?? '';
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        phoneController.text = data?['phone'] ?? '';
        nameController.text = data?['name'] ?? '';
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Profile loading error: $e');
    }
  }

  Future<void> updateProfile() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user?.updateDisplayName(nameController.text.trim());

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> changeEmail() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      await user?.verifyBeforeUpdateEmail(emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Confirm it to change email.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email change failed: $e')));
    }
  }

  Future<void> changePassword() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(passwordController.text.trim());
      passwordController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in again before changing password.'),
        ),
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'My Profile',
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: updateProfile,
            child: const Text('Update Profile'),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: changeEmail,
            child: const Text('Change Email'),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: changePassword,
            child: const Text('Change Password'),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;

  const AppPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(width < 400 ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: width < 400 ? 30 : 38, color: color),
            const SizedBox(height: 10),
            FittedBox(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: width < 400 ? 11 : 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width > 900) {
      crossAxisCount = 4;
    } else if (width > 600) {
      crossAxisCount = 3;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: width < 400 ? 0.85 : 1.0,
      children: children,
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
