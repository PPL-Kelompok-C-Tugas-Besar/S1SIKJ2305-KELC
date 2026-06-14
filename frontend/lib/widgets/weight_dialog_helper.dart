import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/palette.dart';

class WeightDialogHelper {
  static void show(BuildContext context, {VoidCallback? onSuccess}) {
    final TextEditingController weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? weightError;
    bool isSubmitting = false;
    final AuthService authService = AuthService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catat Berat Badan',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Berat Badan
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: kTextPrimary),
                    onChanged: (value) {
                      if (weightError != null) {
                        setModalState(() => weightError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Berat Badan (kg)',
                      labelStyle: const TextStyle(color: kTextMuted),
                      errorText: weightError,
                      filled: true,
                      fillColor: kBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.monitor_weight_outlined, color: kTextMuted),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Tanggal
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: modalContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: kAccent,
                                onPrimary: kBg,
                                surface: kCard,
                                onSurface: kTextPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: kTextMuted),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate),
                            style: const TextStyle(color: kTextPrimary, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final weightText = weightController.text.trim();
                              
                              if (weightText.isEmpty) {
                                setModalState(() => weightError = 'Berat badan tidak boleh kosong');
                                return;
                              }
                              
                              final weight = double.tryParse(weightText.replaceAll(',', '.'));
                              if (weight == null) {
                                setModalState(() => weightError = 'Masukkan angka yang valid');
                                return;
                              }
                              
                              if (weight < 20 || weight > 300) {
                                setModalState(() => weightError = 'Berat badan harus antara 20 - 300 kg');
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              
                              final result = await authService.updateWeight(weight, selectedDate);
                              
                              setModalState(() => isSubmitting = false);

                              if (modalContext.mounted) {
                                Navigator.pop(modalContext); // Tutup dialog
                                
                                if (result['success'] == true) {
                                  ScaffoldMessenger.of(modalContext).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message']),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // Refresh profil agar UI terupdate dengan berat terbaru
                                  modalContext.read<AuthProvider>().checkAuthStatus();
                                  if (onSuccess != null) {
                                    onSuccess();
                                  }
                                } else {
                                  ScaffoldMessenger.of(modalContext).showSnackBar(
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
                      child: isSubmitting
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
}
