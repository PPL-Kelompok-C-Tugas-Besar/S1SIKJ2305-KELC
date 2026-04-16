import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

Future<void> _checkAuth() async {
  // Delay satu frame supaya widget tree selesai build dulu
  await Future.delayed(Duration.zero);
  if (!mounted) return;
  
  await context.read<AuthProvider>().checkAuthStatus();
  if (!mounted) return;

  final status = context.read<AuthProvider>().status;
  final isAdmin = context.read<AuthProvider>().isAdmin;

  if (status == AuthStatus.authenticated) {
    Navigator.pushReplacementNamed(
      context,
      isAdmin ? '/admin-dashboard' : '/home',
    );
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64),
            SizedBox(height: 16),
            Text(
              'Gymbro',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}