import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/history_model.dart';
import '../../services/history_service.dart';
import '../../utils/palette.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  List<WorkoutHistory> _histories = [];
  bool _isLoading = true;

  // --- Stat Getters ---
  int get _totalSessions => _histories.length;
  int get _totalMinutes =>
      _histories.fold(0, (sum, h) => sum + h.durationMinutes);
  int get _totalCalories =>
      _histories.fold(0, (sum, h) => sum + h.caloriesBurned);

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final data = await _historyService.getHistory();
    setState(() {
      _histories = data;
      _isLoading = false;
    });
  }

  // Groups histories by date label (e.g. "Hari Ini", "Kemarin", "22 Apr 2026")
  Map<String, List<WorkoutHistory>> get _grouped {
    final Map<String, List<WorkoutHistory>> map = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final h in _histories) {
      final d = h.date.toLocal();
      final day = DateTime(d.year, d.month, d.day);
      String label;
      if (day == today) {
        label = 'Hari Ini';
      } else if (day == yesterday) {
        label = 'Kemarin';
      } else {
        label = DateFormat('dd MMM yyyy').format(d);
      }
      map.putIfAbsent(label, () => []).add(h);
    }
    return map;
  }

  void _showAddHistoryDialog() {
    final formKey = GlobalKey<FormState>();
    String workoutName = '';
    String durationStr = '';
    String caloriesStr = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white10),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Text('Catat Latihan Baru',
                    style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Nama Latihan',
                  icon: Icons.fitness_center,
                  onSaved: (v) => workoutName = v!,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Nama latihan wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Durasi (menit)',
                        icon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                        onSaved: (v) => durationStr = v!,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'Kalori (kkal)',
                        icon: Icons.local_fire_department_outlined,
                        keyboardType: TextInputType.number,
                        onSaved: (v) => caloriesStr = v!,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: kBg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Navigator.pop(ctx);
                        final ok = await _historyService.addHistory(
                          workoutName: workoutName,
                          durationMinutes: int.tryParse(durationStr) ?? 0,
                          caloriesBurned: int.tryParse(caloriesStr) ?? 0,
                        );
                        if (ok) {
                          _fetchHistory();
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Gagal menyimpan riwayat')),
                          );
                        }
                      }
                    },
                    child: const Text('Simpan Latihan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      style: const TextStyle(color: kTextPrimary),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: kAccent, size: 20),
        filled: true,
        fillColor: kBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccent),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: kAccent,
          backgroundColor: kCard,
          onRefresh: _fetchHistory,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Riwayat',
                              style: TextStyle(
                                  color: kTextMuted, fontSize: 14)),
                          Text('Latihan',
                              style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                        onTap: _showAddHistoryDialog,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              const Icon(Icons.add, color: kBg, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Summary Stats ─────────────────────────────────────────────
              if (!_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        _StatCard(
                          icon: Icons.bar_chart_rounded,
                          value: '$_totalSessions',
                          label: 'Sesi',
                          color: kAccent,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.timer_outlined,
                          value: '$_totalMinutes',
                          label: 'Menit',
                          color: const Color(0xFF6BE5FF),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.local_fire_department,
                          value: '$_totalCalories',
                          label: 'kkal',
                          color: const Color(0xFFFF7043),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Loading ───────────────────────────────────────────────────
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: kAccent)),
                )

              // ── Empty State ───────────────────────────────────────────────
              else if (_histories.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: kCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Icon(Icons.fitness_center,
                              color: kTextMuted, size: 48),
                        ),
                        const SizedBox(height: 20),
                        const Text('Belum Ada Riwayat',
                            style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Tekan tombol + untuk mencatat\nlatihan pertamamu!',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: kTextMuted, height: 1.5)),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _showAddHistoryDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              color: kAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Catat Sekarang',
                                style: TextStyle(
                                    color: kBg,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ── History List (grouped by date) ────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entries = _grouped.entries.toList();
                        final entry = entries[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date group header
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12, top: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: kAccent,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(entry.key,
                                      style: const TextStyle(
                                          color: kTextPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Text('(${entry.value.length} sesi)',
                                      style: const TextStyle(
                                          color: kTextMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            // Cards in this group
                            ...entry.value.map(
                              (h) => _WorkoutCard(history: h),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                      childCount: _grouped.length,
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

// ─── Summary stat box ─────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: kTextMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── Individual workout card ──────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.history});
  final WorkoutHistory history;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.fitness_center, color: kAccent, size: 24),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(history.workoutName,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 6),
                // Stat pills row
                Row(
                  children: [
                    _Pill(
                      icon: Icons.timer_outlined,
                      label: '${history.durationMinutes} menit',
                      color: const Color(0xFF6BE5FF),
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      icon: Icons.local_fire_department,
                      label: '${history.caloriesBurned} kkal',
                      color: const Color(0xFFFF7043),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(history.date.toLocal()),
                style: const TextStyle(
                    color: kTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Small info pill ──────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  const _Pill(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
