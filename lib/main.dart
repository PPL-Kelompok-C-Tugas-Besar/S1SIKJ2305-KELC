import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

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
  // --- STATE DATA ---
  late VideoPlayerController _videoController;
  int _secondsRemaining = 54;
  Timer? _timer;
  bool _isPaused = false;

  String _currentExercise = "Jumping jacks";
  String _currentReps = "x15";
  String _nextExercise = "Push ups";

  @override
  void initState() {
    super.initState();
    // Inisialisasi Video
    _videoController =
        VideoPlayerController.networkUrl(
            Uri.parse(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            ),
          )
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
            _videoController.setLooping(true);
          });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _showFinishedConfirmation();
      }
    });
  }

  void _togglePauseResume() {
    setState(() {
      if (_isPaused) {
        _startTimer();
        _videoController.play();
      } else {
        _timer?.cancel();
        _videoController.pause();
      }
      _isPaused = !_isPaused;
    });
  }

  void _showFinishedConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "YA, KONFIRMASI",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.close, color: Colors.black),
        actions: const [
          Icon(Icons.share, color: Colors.black),
          SizedBox(width: 15),
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black45, width: 2),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "09:52 AM",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.battery_full, size: 14),
              ],
            ),
            const Spacer(),
            // NAMA LATIHAN (Nggak boleh const karena pake variabel)
            Text(
              "$_currentExercise\n$_currentReps",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),

            // KOTAK VIDEO
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: _videoController.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            const Spacer(),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const Center(child: Icon(Icons.access_time, size: 50)),
            ),
            const SizedBox(height: 10),
            Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Spacer(),

            // TOMBOL NAVIGASI (Hapus const di baris Row ini)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWireframeButton(
                  text: _isPaused ? "Resume" : "Pause",
                  onPressed: _togglePauseResume,
                ),
                const SizedBox(width: 20),
                _buildWireframeButton(
                  text: "Next",
                  onPressed: _showFinishedConfirmation,
                ),
              ],
            ),
            const SizedBox(height: 25),
            // INFO NEXT (Nggak boleh const karena ada $_nextExercise)
            Text(
              "Next:\n$_nextExercise",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildWireframeButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        border: Border.all(color: Colors.black38),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
