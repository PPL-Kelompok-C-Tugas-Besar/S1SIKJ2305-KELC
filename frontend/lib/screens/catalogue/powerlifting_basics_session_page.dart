import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/palette.dart';

// ──────────────────────────────────────────────
//  Data model untuk satu gerakan Powerlifting
// ──────────────────────────────────────────────
class PowerliftExercise {
  final String name;
  final int targetReps;
  final String repsDisplay;
  final String imagePath;
  final IconData icon;

  const PowerliftExercise({
    required this.name,
    required this.targetReps,
    required this.repsDisplay,
    required this.imagePath,
    required this.icon,
  });
}

// ──────────────────────────────────────────────
//  Halaman sesi Powerlifting Basics
// ──────────────────────────────────────────────
class PowerliftingBasicsSessionPage extends StatefulWidget {
  const PowerliftingBasicsSessionPage({super.key});

  @override
  State<PowerliftingBasicsSessionPage> createState() =>
      _PowerliftingBasicsSessionPageState();
}

class _PowerliftingBasicsSessionPageState
    extends State<PowerliftingBasicsSessionPage> {
  // ── Hardcoded exercise list (Powerlifting only) ──
  final List<PowerliftExercise> _exercises = const [
    PowerliftExercise(
      name: 'Barbell Squat',
      targetReps: 5,
      repsDisplay: 'x5',
      imagePath: 'lib/assets/gifs/Barbel_Squat.gif',
      icon: Icons.fitness_center_rounded,
    ),
    PowerliftExercise(
      name: 'Russian Twist',
      targetReps: 15,
      repsDisplay: 'x15',
      imagePath: 'lib/assets/gifs/Russian-Twist.gif',
      icon: Icons.self_improvement_rounded,
    ),
  ];

  // ── State ──
  int _currentIndex = 0;
  int _secondsRemaining = 0;
  bool _isResting = false;
  bool _isFinished = false;
  Timer? _timer;

  // Istirahat 60 detik untuk powerlifting
  static const int _restDuration = 60;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Selesai satu gerakan → istirahat atau selesai ──
  void _onRepsDone() {
    _timer?.cancel();

    if (_currentIndex >= _exercises.length - 1) {
      setState(() => _isFinished = true);
      return;
    }

    // Mulai fase istirahat 60 detik
    setState(() {
      _isResting = true;
      _secondsRemaining = _restDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 1) {
        t.cancel();
        _goToNextExercise();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _skipRest() {
    _timer?.cancel();
    _goToNextExercise();
  }

  void _goToNextExercise() {
    setState(() {
      _currentIndex++;
      _isResting = false;
    });
  }

  // ── Format waktu ──
  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ══════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kTextPrimary),
          onPressed: () => _showExitDialog(context),
        ),
        title: const Text(
          'POWERLIFTING BASICS',
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isFinished ? _buildFinishedView() : _buildSessionView(),
      ),
    );
  }

  // ── Dialog konfirmasi keluar ──
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari sesi?',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Progres latihan kamu akan hilang.',
          style: TextStyle(color: kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  SESSION VIEW
  // ══════════════════════════════════════
  Widget _buildSessionView() {
    final exercise = _exercises[_currentIndex];
    final progress =
        (_currentIndex + (_isResting ? 1 : 0)) / _exercises.length;

    return Column(
      children: [
        // ── Progress bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isResting
                        ? 'Istirahat'
                        : 'Latihan ${_currentIndex + 1} / ${_exercises.length}',
                    style: const TextStyle(
                      color: kTextMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: kAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: kCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Content ──
        Expanded(
          child: _isResting
              ? _buildRestView()
              : _buildExerciseView(exercise),
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  //  EXERCISE VIEW (Reps manual only)
  // ══════════════════════════════════════
  Widget _buildExerciseView(PowerliftExercise exercise) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // ── Aset GIF gerakan ──
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 180),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          exercise.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // ── Nama gerakan ──
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target: ${exercise.repsDisplay} reps',
                    style: const TextStyle(
                      color: kTextMuted,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Target reps display (besar di tengah) ──
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            exercise.repsDisplay,
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 72,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'selesaikan repetisi lalu tekan tombol',
                            style:
                                TextStyle(color: kTextMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tombol SELESAI REPS ✓ ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _onRepsDone,
                        icon: const Icon(Icons.check_rounded, size: 24),
                        label: const Text(
                          'SELESAI REPS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════
  //  REST VIEW (60 detik countdown)
  // ══════════════════════════════════════
  Widget _buildRestView() {
    final nextExercise = _exercises[_currentIndex + 1];
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ── Ikon istirahat ──
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: kCard,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: kAccent.withAlpha(80), width: 2),
                  ),
                  child: Icon(
                    Icons.self_improvement_rounded,
                    size: 64,
                    color: kAccent.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Istirahat',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rilekskan otot & atur nafas',
                  style: TextStyle(color: kTextMuted, fontSize: 15),
                ),
                const SizedBox(height: 28),

                // ── Timer istirahat ──
                Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Info gerakan selanjutnya ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kAccent.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(nextExercise.icon,
                            color: kAccent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selanjutnya',
                              style: TextStyle(
                                color: kTextMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextExercise.name,
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        nextExercise.repsDisplay,
                        style: const TextStyle(
                          color: kAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Tombol Skip Istirahat ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _skipRest,
                      icon:
                          const Icon(Icons.skip_next_rounded, size: 24),
                      label: const Text(
                        'Skip Istirahat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════
  //  FINISHED VIEW
  // ══════════════════════════════════════
  Widget _buildFinishedView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ikon selesai ──
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: kCard,
                shape: BoxShape.circle,
                border: Border.all(color: kAccent, width: 3),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 72,
                color: kAccent,
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Sesi Selesai! 💪',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kamu berhasil menyelesaikan\nsemua gerakan Powerlifting Basics!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kTextMuted,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // ── Ringkasan ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _summaryRow(Icons.fitness_center_rounded, 'Total Gerakan',
                      '${_exercises.length} exercise'),
                  const Divider(color: Colors.white10, height: 24),
                  _summaryRow(
                    Icons.repeat_rounded,
                    'Tipe',
                    'Semua Reps Manual',
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _summaryRow(
                    Icons.timer_rounded,
                    'Istirahat',
                    '$_restDuration detik / set',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Tombol kembali ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                label: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kAccent, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: kTextMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
