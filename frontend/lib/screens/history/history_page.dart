import 'package:flutter/material.dart';
import '../../models/history_model.dart';
import '../../services/history_service.dart';
import '../../utils/palette.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  List<WorkoutHistory> _histories = [];
  bool _isLoading = true;

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

  void _showAddHistoryDialog() {
    final _formKey = GlobalKey<FormState>();
    String workoutName = '';
    int duration = 0;
    int calories = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Catat Latihan Baru', style: TextStyle(color: kTextPrimary)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: const TextStyle(color: kTextPrimary),
                decoration: const InputDecoration(labelText: 'Nama Latihan', labelStyle: TextStyle(color: kTextMuted)),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => workoutName = val!,
              ),
              TextFormField(
                style: const TextStyle(color: kTextPrimary),
                decoration: const InputDecoration(labelText: 'Durasi (menit)', labelStyle: TextStyle(color: kTextMuted)),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => duration = int.parse(val!),
              ),
              TextFormField(
                style: const TextStyle(color: kTextPrimary),
                decoration: const InputDecoration(labelText: 'Kalori Terbakar', labelStyle: TextStyle(color: kTextMuted)),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => calories = int.parse(val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(ctx);
                final success = await _historyService.addHistory(
                  workoutName: workoutName,
                  durationMinutes: duration,
                  caloriesBurned: calories,
                );
                if (success) {
                  _fetchHistory();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menyimpan riwayat')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: const Text('Riwayat Latihan', style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _histories.isEmpty
              ? const Center(child: Text('Belum ada riwayat latihan.', style: TextStyle(color: kTextMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _histories.length,
                  itemBuilder: (context, index) {
                    final history = _histories[index];
                    return Card(
                      color: kCard,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fitness_center, color: kAccent),
                        ),
                        title: Text(history.workoutName, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              '${history.durationMinutes} menit • ${history.caloriesBurned} kkal',
                              style: const TextStyle(color: kTextMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(history.date.toLocal()),
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccent,
        foregroundColor: kBg,
        onPressed: _showAddHistoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
