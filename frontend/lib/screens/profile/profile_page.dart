import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/palette.dart';
import 'weight_tracking_page.dart';
import '../marketplace/purchase_history_page.dart';
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

    if (!mounted) return;
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

  void _showHeightDialog(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final TextEditingController heightController = TextEditingController(
      text: user?.height != null ? user!.height!.toStringAsFixed(0) : '',
    );
    String? heightError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Tinggi Badan',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: kTextPrimary),
                    onChanged: (_) {
                      if (heightError != null) {
                        setModalState(() => heightError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tinggi Badan (cm)',
                      labelStyle: const TextStyle(color: kTextMuted),
                      errorText: heightError,
                      filled: true,
                      fillColor: kBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.straighten, color: kTextMuted),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              final heightText = heightController.text.trim();

                              if (heightText.isEmpty) {
                                setModalState(() => heightError = 'Tinggi badan tidak boleh kosong');
                                return;
                              }

                              final height = double.tryParse(heightText.replaceAll(',', '.'));
                              if (height == null) {
                                setModalState(() => heightError = 'Masukkan angka yang valid');
                                return;
                              }

                              if (height < 50 || height > 250) {
                                setModalState(() => heightError = 'Tinggi badan harus antara 50 - 250 cm');
                                return;
                              }

                              setModalState(() => _isSubmitting = true);

                              final result = await _authService.updateHeight(height);

                              setModalState(() => _isSubmitting = false);

                              if (context.mounted) {
                                Navigator.pop(context);

                                if (result['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tinggi badan berhasil diperbarui'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  context.read<AuthProvider>().checkAuthStatus();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Gagal menyimpan data'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: kBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: kBg, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _bmiColor(double? bmi) {
    if (bmi == null) return kTextMuted;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    final bmi = user.bmi;
    final bmiColor = _bmiColor(bmi);

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

            // Card Berat & Tinggi Badan (2 kolom)
            Row(
              children: [
                // Card Berat Badan
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Berat Badan',
                          style: TextStyle(color: kTextMuted, fontSize: 12),
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
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'kg',
                              style: TextStyle(color: kTextMuted, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showWeightDialog(context),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_rounded, color: kAccent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(color: kAccent, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Card Tinggi Badan
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tinggi Badan',
                          style: TextStyle(color: kTextMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              user.height != null ? user.height!.toStringAsFixed(0) : '--',
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'cm',
                              style: TextStyle(color: kTextMuted, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showHeightDialog(context),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_rounded, color: kAccent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(color: kAccent, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Card BMI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Indeks Massa Tubuh (BMI)',
                    style: TextStyle(color: kTextMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        bmi != null ? bmi.toStringAsFixed(1) : '--',
                        style: TextStyle(
                          color: bmiColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.bmiCategory,
                            style: TextStyle(
                              color: bmiColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (bmi == null)
                            const Text(
                              'Isi berat & tinggi badan',
                              style: TextStyle(color: kTextMuted, fontSize: 12),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (bmi != null) ...[
                    const SizedBox(height: 16),
                    _BmiScaleBar(bmi: bmi),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('<18.5', style: TextStyle(color: kTextMuted, fontSize: 10)),
                        Text('18.5', style: TextStyle(color: kTextMuted, fontSize: 10)),
                        Text('25.0', style: TextStyle(color: kTextMuted, fontSize: 10)),
                        Text('30.0', style: TextStyle(color: kTextMuted, fontSize: 10)),
                        Text('>30', style: TextStyle(color: kTextMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Update Berat Badan
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

            // Tombol Riwayat Pembelian
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PurchaseHistoryPage()),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined, color: kTextMuted),
                label: const Text(
                  'Lihat Riwayat Pembelian',
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

class _BmiScaleBar extends StatelessWidget {
  const _BmiScaleBar({required this.bmi});

  final double bmi;

  @override
  Widget build(BuildContext context) {
    // BMI scale: 10 to 40 (clamped)
    const double minBmi = 10.0;
    const double maxBmi = 40.0;
    final double clamped = bmi.clamp(minBmi, maxBmi);
    final double fraction = (clamped - minBmi) / (maxBmi - minBmi);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double dotPosition = (fraction * barWidth).clamp(8.0, barWidth - 8.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Gradient bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    Expanded(flex: 85 - 10, child: Container(color: Colors.blue.shade300)),
                    Expanded(flex: 250 - 185, child: Container(color: Colors.green.shade400)),
                    Expanded(flex: 300 - 250, child: Container(color: Colors.orange.shade400)),
                    Expanded(flex: 400 - 300, child: Container(color: Colors.redAccent)),
                  ],
                ),
              ),
            ),
            // Dot indicator
            Positioned(
              left: dotPosition - 8,
              top: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black54, width: 2),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
