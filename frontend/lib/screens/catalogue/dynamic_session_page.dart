import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/palette.dart';
import 'workout_summary_screen.dart';

// ══════════════════════════════════════════════
//  MODEL DATA
// ══════════════════════════════════════════════

/// Model untuk satu gerakan latihan.
class ExerciseModel {
  final String name;

  /// Label tampilan: durasi ("00:45") atau reps ("x10").
  final String durationOrReps;

  /// Nilai numerik: detik (jika isTimer) atau jumlah reps.
  final int value;

  /// `true` → timer countdown otomatis, `false` → reps manual.
  final bool isTimer;

  /// Path ke GIF di folder aset lokal.
  final String imagePath;

  /// Ikon fallback untuk preview.
  final IconData icon;

  const ExerciseModel({
    required this.name,
    required this.durationOrReps,
    required this.value,
    required this.isTimer,
    required this.imagePath,
    this.icon = Icons.fitness_center_rounded,
  });
}

/// Paket latihan yang membungkus daftar gerakan.
class WorkoutPackage {
  final String title;

  /// Durasi istirahat antar gerakan (dalam detik).
  final int restDuration;

  /// Daftar gerakan di dalam paket.
  final List<ExerciseModel> exercises;

  const WorkoutPackage({
    required this.title,
    required this.restDuration,
    required this.exercises,
  });
}

// ══════════════════════════════════════════════
//  PRE-BUILT PACKAGES
// ══════════════════════════════════════════════

/// Paket "Home HIIT Blast" — 4 gerakan, istirahat 15 detik.
const hiitBlastPackage = WorkoutPackage(
  title: 'HOME HIIT BLAST',
  restDuration: 15,
  exercises: [
    ExerciseModel(
      name: 'Jumping Jacks',
      durationOrReps: '00:45',
      value: 45,
      isTimer: true,
      imagePath: 'lib/assets/gifs/jumping_jack.gif',
      icon: Icons.directions_run_rounded,
    ),
    ExerciseModel(
      name: 'Mountain Climbers',
      durationOrReps: '00:30',
      value: 30,
      isTimer: true,
      imagePath: 'lib/assets/gifs/mountain_climb.gif',
      icon: Icons.landscape_rounded,
    ),
    ExerciseModel(
      name: 'Burpees',
      durationOrReps: 'x10',
      value: 10,
      isTimer: false,
      imagePath: 'lib/assets/gifs/burpees.gif',
      icon: Icons.fitness_center_rounded,
    ),
    ExerciseModel(
      name: 'Lunges',
      durationOrReps: 'x12',
      value: 12,
      isTimer: false,
      imagePath: 'lib/assets/gifs/Lunges.gif',
      icon: Icons.accessibility_new_rounded,
    ),
  ],
);

/// Paket "Powerlifting Basics" — 2 gerakan, istirahat 60 detik.
const powerliftingBasicsPackage = WorkoutPackage(
  title: 'POWERLIFTING BASICS',
  restDuration: 60,
  exercises: [
    ExerciseModel(
      name: 'Barbell Squat',
      durationOrReps: 'x5',
      value: 5,
      isTimer: false,
      imagePath: 'lib/assets/gifs/Barbel_Squat.gif',
      icon: Icons.fitness_center_rounded,
    ),
    ExerciseModel(
      name: 'Russian Twist',
      durationOrReps: 'x15',
      value: 15,
      isTimer: false,
      imagePath: 'lib/assets/gifs/Russian-Twist.gif',
    ),
  ],
);

/// Paket "Yoga Flow" — 5 gerakan, istirahat 15 detik.
const yogaFlowPackage = WorkoutPackage(
  title: 'Yoga Flow',
  restDuration: 15,
  exercises: [
    ExerciseModel(
      name: 'Neck Rolls',
      durationOrReps: '01:00',
      value: 60,
      isTimer: true,
      imagePath: 'lib/assets/gifs/neck-rolls.gif',
      icon: Icons.self_improvement_rounded,
    ),
    ExerciseModel(
      name: 'Arm Circles',
      durationOrReps: '01:00',
      value: 60,
      isTimer: true,
      imagePath: 'lib/assets/gifs/arm-circles.gif',
      icon: Icons.accessibility_new_rounded,
    ),
    ExerciseModel(
      name: 'Torso Twists',
      durationOrReps: '01:00',
      value: 60,
      isTimer: true,
      imagePath: 'lib/assets/gifs/Torso-Twist.gif',
      icon: Icons.accessibility_new_rounded,
    ),
    ExerciseModel(
      name: 'Plank',
      durationOrReps: '02:00',
      value: 120,
      isTimer: true,
      imagePath: 'lib/assets/gifs/plank.gif',
      icon: Icons.fitness_center_rounded,
    ),
    ExerciseModel(
      name: 'Abdominal Crunches',
      durationOrReps: 'x20',
      value: 20,
      isTimer: false,
      imagePath: 'lib/assets/gifs/Abdominal-Crunces.gif',
      icon: Icons.fitness_center_rounded,
    ),
  ],
);

// ══════════════════════════════════════════════
//  DYNAMIC SESSION PAGE
// ══════════════════════════════════════════════

class DynamicSessionPage extends StatefulWidget {
  final WorkoutPackage package;

  const DynamicSessionPage({super.key, required this.package});

  @override
  State<DynamicSessionPage> createState() => _DynamicSessionPageState();
}

class _DynamicSessionPageState extends State<DynamicSessionPage> {
  // ── State ──
  int _currentIndex = 0;
  int _secondsRemaining = 0;
  bool _isResting = false;
  bool _isFinished = false;
  bool _timerRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  List<ExerciseModel> get _exercises => widget.package.exercises;
  ExerciseModel get _currentExercise => _exercises[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startNextPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════
  //  CORE LOGIC
  // ══════════════════════════════════════

  /// Mulai fase berikutnya: jika timer → countdown, jika reps → tunggu manual.
  void _startNextPhase() {
    final exercise = _currentExercise;

    if (exercise.isTimer) {
      setState(() {
        _secondsRemaining = exercise.value;
        _timerRunning = true;
        _isPaused = false;
      });
      _runTimer(onDone: _onExerciseDone);
    } else {
      // Reps manual — tampilkan target, tunggu tombol
      setState(() {
        _timerRunning = false;
        _isPaused = false;
      });
    }
  }

  void _runTimer({required VoidCallback onDone}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 1) {
        t.cancel();
        onDone();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _togglePause() {
    if (_isPaused) {
      // Resume
      setState(() => _isPaused = false);
      _runTimer(
        onDone: _isResting ? _goToNextExercise : _onExerciseDone,
      );
    } else {
      // Pause
      _timer?.cancel();
      setState(() => _isPaused = true);
    }
  }

  /// Dipanggil saat satu gerakan selesai (timer habis ATAU tombol reps diklik).
  void _onExerciseDone() {
    _timer?.cancel();

    if (_currentIndex >= _exercises.length - 1) {
      // Semua gerakan selesai
      setState(() => _isFinished = true);
      return;
    }

    // Mulai fase istirahat
    setState(() {
      _isResting = true;
      _secondsRemaining = widget.package.restDuration;
      _timerRunning = true;
      _isPaused = false;
    });
    _runTimer(onDone: _goToNextExercise);
  }

  void _skipRest() {
    _timer?.cancel();
    _goToNextExercise();
  }

  void _goToNextExercise() {
    _timer?.cancel();
    setState(() {
      _currentIndex++;
      _isResting = false;
    });
    _startNextPhase();
  }

  // ── Helpers ──
  String _formatSeconds(int s) => s.toString().padLeft(2, '0');
  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  // ── Dialog Edit Waktu Istirahat ──
  void _showEditTimeDialog() {
    final controller = TextEditingController(
      text: _secondsRemaining.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Set Waktu Istirahat',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: kTextPrimary, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Masukkan detik',
            hintStyle: const TextStyle(color: kTextMuted),
            suffixText: 'detik',
            suffixStyle: const TextStyle(color: kTextMuted),
            filled: true,
            fillColor: kBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: kAccent.withAlpha(100)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kAccent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim();
              if (input.isEmpty) {
                Navigator.of(ctx).pop();
                return;
              }
              try {
                final newSeconds = int.parse(input);
                if (newSeconds > 0) {
                  setState(() => _secondsRemaining = newSeconds);
                }
              } catch (_) {
                // Input tidak valid, abaikan
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
        title: Text(
          widget.package.title,
          style: const TextStyle(
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
    final exercise = _currentExercise;
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
  //  EXERCISE VIEW (Timer atau Reps)
  // ══════════════════════════════════════
  Widget _buildExerciseView(ExerciseModel exercise) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // ── GIF Gerakan ──
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
                    exercise.isTimer
                        ? 'Durasi: ${exercise.durationOrReps}'
                        : 'Target: ${exercise.durationOrReps} reps',
                    style: const TextStyle(
                      color: kTextMuted,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Display tengah: Timer atau Reps ──
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: exercise.isTimer
                          ? _buildTimerDisplay()
                          : _buildRepsDisplay(exercise),
                    ),
                  ),

                  // ── Tombol bawah ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: exercise.isTimer
                        ? _buildTimerControls()
                        : _buildRepsButton(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Timer Display ──
  Widget _buildTimerDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(_secondsRemaining),
          style: const TextStyle(
            color: kAccent,
            fontSize: 72,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isPaused ? 'DIJEDA' : 'berjalan...',
          style: TextStyle(
            color: _isPaused ? Colors.orangeAccent : kTextMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Reps Display ──
  Widget _buildRepsDisplay(ExerciseModel exercise) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          exercise.durationOrReps,
          style: const TextStyle(
            color: kAccent,
            fontSize: 72,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'selesaikan repetisi lalu tekan tombol',
          style: TextStyle(color: kTextMuted, fontSize: 14),
        ),
      ],
    );
  }

  // ── Timer Controls (Pause/Play) ──
  Widget _buildTimerControls() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _togglePause,
        icon: Icon(
          _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          size: 28,
        ),
        label: Text(
          _isPaused ? 'LANJUTKAN' : 'JEDA',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPaused ? kAccent : kCard,
          foregroundColor: _isPaused ? Colors.black : kTextPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: _isPaused
              ? BorderSide.none
              : const BorderSide(color: kAccent, width: 1.5),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Tombol SELESAI REPS ✓ ──
  Widget _buildRepsButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _onExerciseDone,
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
    );
  }

  // ══════════════════════════════════════
  //  REST VIEW (badge + ikon + timer + tombol)
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

                // ── 1. Badge Pill "FASE ISTIRAHAT" ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: kAccent, width: 1.5),
                  ),
                  child: const Text(
                    'FASE ISTIRAHAT',
                    style: TextStyle(
                      color: kAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── 2. Ikon Lingkaran ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: kAccent, width: 2),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 60,
                    color: kAccent,
                  ),
                ),
                const SizedBox(height: 28),

                // ── 3. Judul & Subjudul ──
                const Text(
                  'ISTIRAHAT',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selanjutnya: ${nextExercise.name}',
                  style: const TextStyle(
                    color: kTextMuted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                // ── 4. Display Timer (format 00:xx) ──
                Text(
                  '00:${_formatSeconds(_secondsRemaining)}',
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 80,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'detik',
                  style: TextStyle(
                    color: kTextMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // ── 5. Tombol Edit & +20s ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _showEditTimeDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kAccent,
                        side: const BorderSide(color: kAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        'Edit Waktu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _secondsRemaining += 20);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kAccent,
                        side: const BorderSide(color: kAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        '+ 20s',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── 6. Tombol MULAI LATIHAN → ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _skipRest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'MULAI LATIHAN →',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
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
    final timerCount =
        _exercises.where((e) => e.isTimer).length;
    final repsCount =
        _exercises.where((e) => !e.isTimer).length;

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
              'Sesi Selesai! 🔥',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kamu berhasil menyelesaikan\nsemua gerakan ${widget.package.title}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                  if (timerCount > 0) ...[
                    const Divider(color: Colors.white10, height: 24),
                    _summaryRow(
                      Icons.timer_rounded,
                      'Tipe Timer',
                      '$timerCount gerakan',
                    ),
                  ],
                  if (repsCount > 0) ...[
                    const Divider(color: Colors.white10, height: 24),
                    _summaryRow(
                      Icons.repeat_rounded,
                      'Tipe Reps',
                      '$repsCount gerakan',
                    ),
                  ],
                  const Divider(color: Colors.white10, height: 24),
                  _summaryRow(
                    Icons.self_improvement_rounded,
                    'Istirahat',
                    '${widget.package.restDuration} detik / set',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Tombol Selanjutnya ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
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
