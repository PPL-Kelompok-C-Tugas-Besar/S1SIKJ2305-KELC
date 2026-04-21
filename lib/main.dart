import 'package:flutter/material.dart';
import 'dart:async'; // [cite: 3]

void main() {
  runApp(const GymbroApp());
}

class GymbroApp extends StatelessWidget {
  const GymbroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const WorkoutExecutionPage(),
    );
  }
}

class WorkoutExecutionPage extends StatefulWidget {
  const WorkoutExecutionPage({super.key});

  @override
  State<WorkoutExecutionPage> createState() => _WorkoutExecutionPageState();
}

class _WorkoutExecutionPageState extends State<WorkoutExecutionPage> {
  // --- LOGIKA TIMER SET & REST OTOMATIS ---
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isPaused = false;
  bool _hasStarted = false; // Flag biar nggak langsung mulai otomatis

  // Controller buat input waktu
  final TextEditingController _timeController = TextEditingController();

  final String _currentExercise = "Jumping jacks";
  final String _nextExercise = "Push ups";

  // Fungsi Mulai Manual
  void _startTimer() {
    if (_secondsRemaining > 0) {
      setState(() {
        _hasStarted = true;
        _isPaused = false;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          _showFinishedConfirmation(); //
        }
      });
    }
  }

  void _togglePauseResume() {
    setState(() {
      if (_isPaused) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
      _isPaused = !_isPaused;
    });
  }

  void _showFinishedConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "SESI SELESAI",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Verifikasi: Tandai berakhirnya satu sesi latihan secara resmi dalam sistem?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hasStarted = false;
                  _secondsRemaining = 0;
                });
              },
              child: const Text("YA, KONFIRMASI"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KENDALI SESI OLAHRAGA"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              _currentExercise,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // INPUT PILIHAN WAKTU
            if (!_hasStarted) ...[
              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Masukkan Durasi Latihan (Detik)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() => _secondsRemaining = int.tryParse(val) ?? 0);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _secondsRemaining > 0 ? _startTimer : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("MULAI LATIHAN"),
              ),
            ],

            // TAMPILAN TIMER SAAT BERJALAN
            if (_hasStarted) ...[
              const Icon(Icons.access_time, size: 80, color: Colors.blue),
              Text(
                _formatTime(_secondsRemaining),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // KONTROL NAVIGASI SESI
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _togglePauseResume,
                    child: Text(_isPaused ? "RESUME" : "PAUSE"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _showFinishedConfirmation,
                    child: const Text("STOP"),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 50),
            Text(
              "Next: $_nextExercise",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
