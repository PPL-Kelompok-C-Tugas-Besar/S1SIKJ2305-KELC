import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/admin_colors.dart';
import 'manage_users_screen.dart';
import 'manage_workouts_screen.dart';
import 'manage_exercises_screen.dart';
import 'manage_supplements_screen.dart';
import 'manage_vouchers_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bgColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: AdminColors.textPrimary)),
        backgroundColor: AdminColors.cardColor,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: AdminColors.bgColor,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AdminColors.cardColor),
              child: Center(
                child: Text(
                  'Admin Menu',
                  style: TextStyle(
                    color: AdminColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: AdminColors.textPrimary),
              title: const Text('Profil Admin', style: TextStyle(color: AdminColors.textPrimary)),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showAdminLogoutDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // First Row
            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    title: 'Workouts',
                    icon: Icons.fitness_center,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageWorkoutsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    title: 'Users',
                    icon: Icons.people,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Second Row
            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    title: 'Exercises',
                    icon: Icons.upload_file,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageExercisesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    title: 'Supplements',
                    icon: Icons.inventory,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageSupplementsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Third Row (Vouchers)
            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    title: 'Vouchers',
                    icon: Icons.confirmation_number_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageVouchersScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.accentColor.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AdminColors.accentColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AdminColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Keamanan Sesi',
            style: TextStyle(
              color: AdminColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin mengakhiri sesi administratif ini? Pastikan semua perubahan data telah tersimpan.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                print('Admin Logout Successful'); // Placeholder
                // Tetap panggil fungsi logout agar aplikasinya benar-benar logout
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }
}
