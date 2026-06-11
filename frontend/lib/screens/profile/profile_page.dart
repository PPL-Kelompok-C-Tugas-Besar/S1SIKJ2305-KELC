import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/palette.dart';
import 'weight_tracking_page.dart';
import 'change_password_screen.dart';
import '../../widgets/weight_dialog_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);

    final bytes = await picked.readAsBytes();
    final base64Photo = base64Encode(bytes);

    final result = await context.read<AuthProvider>().uploadPhoto(base64Photo);

    setState(() => _isUploadingPhoto = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? (result['success'] == true
            ? 'Foto berhasil diperbarui'
            : 'Gagal upload foto')),
        backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _showWeightDialog(BuildContext context) {
    WeightDialogHelper.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Profile
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: kCard,
                  backgroundImage: user.photoUrl != null
                      ? MemoryImage(base64Decode(user.photoUrl!))
                      : null,
                  child: user.photoUrl == null
                      ? const Icon(Icons.person, size: 50, color: kTextMuted)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: kBg, width: 2),
                      ),
                      child: _isUploadingPhoto
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                color: kBg,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_alt, size: 16, color: kBg),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(color: kTextMuted, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Card Berat Badan
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berat Badan Saat Ini',
                        style: TextStyle(color: kTextMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            user.weight != null ? user.weight!.toStringAsFixed(1) : '--',
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'kg',
                            style: TextStyle(color: kTextMuted, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: kAccent),
                      onPressed: () => _showWeightDialog(context),
                      tooltip: 'Update Berat Badan',
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tombol Update
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showWeightDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Catat Berat Badan Baru'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAccent,
                  side: const BorderSide(color: kAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Lihat Riwayat
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WeightTrackingPage()),
                  );
                },
                icon: const Icon(Icons.history_rounded, color: kTextMuted),
                label: const Text(
                  'Lihat Riwayat Berat Badan',
                  style: TextStyle(color: kTextMuted),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Ubah Password
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()),
                  );
                },
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Ubah Password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextPrimary,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
