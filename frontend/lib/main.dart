import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/homepage_screens.dart';
<<<<<<< HEAD
import 'screens/auth/catalogue.dart';
import 'package:frontend/screens/auth/workout_screen.dart';
=======
>>>>>>> 82db700 (PKCTB-85 Delete file code duplicate di luar frontend/lib, integrasi screen workout ke homepage & nyamain warna dan layoutnya)

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const GymbroApp(),
    ),
  );
}

class GymbroApp extends StatelessWidget {
  const GymbroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymbro',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/admin-dashboard': (_) => const AdminDashboardScreen(),
<<<<<<< HEAD
        '/exercise-catalogue': (_) => const ExerciseCatalogueScreen(),
        '/exercise-workout': (_) => const AlifWorkoutScreen(),
=======
>>>>>>> 82db700 (PKCTB-85 Delete file code duplicate di luar frontend/lib, integrasi screen workout ke homepage & nyamain warna dan layoutnya)
      },
    );
  }
}