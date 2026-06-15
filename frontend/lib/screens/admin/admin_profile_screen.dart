import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/admin_colors.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AdminColors.bgColor,
      appBar: AppBar(
        title: const Text('Profil Admin', style: TextStyle(color: AdminColors.textPrimary)),
        backgroundColor: AdminColors.cardColor,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto Profil
              CircleAvatar(
                radius: 60,
                backgroundColor: AdminColors.cardColor,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 60,
                  color: AdminColors.accentColor,
                ),
              ),
              const SizedBox(height: 24),

              // Nama Admin
              Text(
                user?.fullName ?? 'Admin Gymbro',
                style: const TextStyle(
                  color: AdminColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email Admin
              Text(
                user?.email ?? 'admin@gymbro.com',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Badge Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AdminColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminColors.accentColor),
                ),
                child: Text(
                  'SUPER ADMIN',
                  style: TextStyle(
                    color: AdminColors.accentColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
