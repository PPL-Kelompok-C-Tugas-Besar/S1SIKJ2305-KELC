import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Data Models ──────────────────────────────────────────────────────────────

enum ExerciseExecutionType { reps, timed }

class ExerciseExecutionItem {
  final String name;
  final String gifPath;
  final ExerciseExecutionType type;
  final int value; // reps count or seconds
  final String? description;

  const ExerciseExecutionItem({
    required this.name,
    required this.gifPath,
    required this.type,
    required this.value,
    this.description,
  });
}

// ── Color Palette (Dark Mode) ─────────────────────────────────────────────────

const _bg = Color(0xFF0A0A0F);
const _surface = Color(0xFF14141C);
const _card = Color(0xFF1C1C28);
const _border = Color(0xFF2A2A3A);
const _accent = Color(0xFFFF6B35);
const _green = Color(0xFF00E676);
const _white = Colors.white;

// ── Screen ────────────────────────────────────────────────────────────────────

class ExerciseExecutionScreen extends StatefulWidget {
  final List<ExerciseExecutionItem> exercises;
  final String workoutTitle;
  final Color themeColor;

  const ExerciseExecutionScreen({
    super.key,
    required this.exercises,
    required this.workoutTitle,
    this.themeColor = _accent,
  });

  @override
  State<ExerciseExecutionScreen> createState() =>
      _ExerciseExecutionScreenState();
}

class _ExerciseExecutionScreenState extends State<ExerciseExecutionScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _timerSeconds = 0;
  bool _isPaused = false;
  bool _isResting = false;
  int _restSeconds = 15;
  Timer? _timer;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _ringCtrl;

  ExerciseExecutionItem get _current => widget.exercises[_currentIndex];
  bool get _isLast => _currentIndex >= widget.exercises.length - 1;
  double get _progress => (_currentIndex + 1) / widget.exercises.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _loadExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    _fadeCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  void _loadExercise() {
    _slideCtrl.forward(from: 0);
    _fadeCtrl.forward(from: 0);
    if (_current.type == ExerciseExecutionType.timed) {
      _startTimer(_current.value);
    } else {
      _timer?.cancel();
    }
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _timerSeconds = seconds;
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        t.cancel();
        _onExerciseDone();
      }
    });
  }

  void _togglePause() => setState(() => _isPaused = !_isPaused);

  void _onExerciseDone() {
    _timer?.cancel();
    if (_isLast) {
      _showCompleteDialog();
    } else {
      _beginRest();
    }
  }

  void _beginRest() {
    setState(() {
      _isResting = true;
      _restSeconds = 15;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        t.cancel();
        _goNextExercise();
      }
    });
  }

  void _skipRest() {
    _timer?.cancel();
    _goNextExercise();
  }

  void _goNextExercise() {
    setState(() {
      _currentIndex++;
      _isResting = false;
    });
    _loadExercise();
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompletionDialog(
        workoutTitle: widget.workoutTitle,
        totalExercises: widget.exercises.length,
        themeColor: widget.themeColor,
        onDone: () => Navigator.of(context)
          ..pop()
          ..pop(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isResting ? _buildRestView() : _buildExerciseView(),
      ),
    );
  }

  // ── Exercise View ─────────────────────────────────────────────────────────

  Widget _buildExerciseView() {
    final ex = _current;
    final color = widget.themeColor;

    return Column(
      key: const ValueKey('exercise'),
      children: [
        // ── Top Bar ──
        _TopBar(
          title: widget.workoutTitle,
          current: _currentIndex + 1,
          total: widget.exercises.length,
          progress: _progress,
          color: color,
          onBack: () => Navigator.of(context).pop(),
        ),

        // ── Media Area (fokus utama – vertikal) ──
        Expanded(
          flex: 5,
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _MediaPanel(gifPath: ex.gifPath, color: color),
            ),
          ),
        ),

        // ── Info + Controls ──
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _ControlPanel(
              exercise: ex,
              timerSeconds: _timerSeconds,
              isPaused: _isPaused,
              pulseAnim: _pulseAnim,
              color: color,
              onPause: _togglePause,
              onDone: _onExerciseDone,
              isLast: _isLast,
            ),
          ),
        ),
      ],
    );
  }

  // ── Rest View ─────────────────────────────────────────────────────────────

  Widget _buildRestView() {
    final next = widget.exercises[_currentIndex + 1];
    return Center(
      key: const ValueKey('rest'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.12),
                border: Border.all(color: _green, width: 2),
              ),
              child: const Icon(
                Icons.self_improvement,
                color: _green,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ISTIRAHAT',
              style: TextStyle(
                color: _green,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Berikutnya: ${next.name}',
              style: const TextStyle(color: Colors.white54, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ScaleTransition(
              scale: _pulseAnim,
              child: Text(
                '$_restSeconds',
                style: const TextStyle(
                  color: _white,
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const Text(
              'detik',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _ActionButton(
              label: 'SKIP ISTIRAHAT →',
              color: _green,
              textColor: Colors.black,
              onTap: _skipRest,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar Widget ─────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final double progress;
  final Color color;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.current,
    required this.total,
    required this.progress,
    required this.color,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(8, top + 4, 16, 12),
      color: _surface,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$current / $total',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Media Panel ───────────────────────────────────────────────────────────────

class _MediaPanel extends StatelessWidget {
  final String gifPath;
  final Color color;

  const _MediaPanel({required this.gifPath, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            gifPath,
            fit: BoxFit.contain,
            errorBuilder: (_, e, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: color.withValues(alpha: 0.4),
                    size: 72,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GIF tidak tersedia',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Subtle gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _card.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Control Panel ─────────────────────────────────────────────────────────────

class _ControlPanel extends StatelessWidget {
  final ExerciseExecutionItem exercise;
  final int timerSeconds;
  final bool isPaused;
  final Animation<double> pulseAnim;
  final Color color;
  final VoidCallback onPause;
  final VoidCallback onDone;
  final bool isLast;

  const _ControlPanel({
    required this.exercise,
    required this.timerSeconds,
    required this.isPaused,
    required this.pulseAnim,
    required this.color,
    required this.onPause,
    required this.onDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isTimer = exercise.type == ExerciseExecutionType.timed;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Exercise name
          Text(
            exercise.name,
            style: const TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          if (exercise.description != null) ...[
            const SizedBox(height: 4),
            Text(
              exercise.description!,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),

          if (isTimer)
            _TimerSection(
              seconds: timerSeconds,
              total: exercise.value,
              isPaused: isPaused,
              pulseAnim: pulseAnim,
              color: color,
              onPause: onPause,
            )
          else
            _RepsSection(value: exercise.value, color: color),

          const Spacer(),

          _ActionButton(
            label: isLast
                ? '🏆  SELESAI WORKOUT'
                : isTimer
                ? 'SKIP ▶'
                : '✓  SELESAI ${exercise.value} REPS',
            color: isTimer && !isLast ? Colors.white24 : color,
            onTap: onDone,
          ),
        ],
      ),
    );
  }
}

// ── Timer Section ─────────────────────────────────────────────────────────────

class _TimerSection extends StatelessWidget {
  final int seconds;
  final int total;
  final bool isPaused;
  final Animation<double> pulseAnim;
  final Color color;
  final VoidCallback onPause;

  const _TimerSection({
    required this.seconds,
    required this.total,
    required this.isPaused,
    required this.pulseAnim,
    required this.color,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? seconds / total : 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: fraction,
                strokeWidth: 6,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              ScaleTransition(
                scale: pulseAnim,
                child: Text(
                  '$seconds',
                  style: const TextStyle(
                    color: _white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: onPause,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: color,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reps Section ──────────────────────────────────────────────────────────────

class _RepsSection extends StatelessWidget {
  final int value;
  final Color color;

  const _RepsSection({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'reps',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = _white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Completion Dialog ─────────────────────────────────────────────────────────

class _CompletionDialog extends StatelessWidget {
  final String workoutTitle;
  final int totalExercises;
  final Color themeColor;
  final VoidCallback onDone;

  const _CompletionDialog({
    required this.workoutTitle,
    required this.totalExercises,
    required this.themeColor,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text(
              'WORKOUT SELESAI!',
              style: TextStyle(
                color: _white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              workoutTitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statChip('$totalExercises', 'Latihan', themeColor),
                _statChip('✓', 'Selesai', _green),
              ],
            ),
            const SizedBox(height: 28),
            _ActionButton(
              label: 'KEMBALI KE MENU',
              color: themeColor,
              onTap: onDone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Demo Entry Point ──────────────────────────────────────────────────────────
// Hapus / ganti ini sesuai navigasi asli dari workout_screen.dart

class ExerciseExecutionDemo extends StatelessWidget {
  const ExerciseExecutionDemo({super.key});

  static const _demoExercises = [
    ExerciseExecutionItem(
      name: 'Push Up',
      gifPath: 'assets/gifs/pushups.gif',
      type: ExerciseExecutionType.reps,
      value: 15,
      description: 'Jaga punggung lurus, turunkan dada ke lantai',
    ),
    ExerciseExecutionItem(
      name: 'Plank Hold',
      gifPath: 'assets/gifs/plank.gif',
      type: ExerciseExecutionType.timed,
      value: 30,
      description: 'Tahan posisi plank dengan core dikencangkan',
    ),
    ExerciseExecutionItem(
      name: 'Squat',
      gifPath: 'assets/gifs/squat.gif',
      type: ExerciseExecutionType.reps,
      value: 20,
      description: 'Turunkan pinggul sejajar lutut',
    ),
    ExerciseExecutionItem(
      name: 'Mountain Climbers',
      gifPath: 'assets/gifs/mountain_climb.gif',
      type: ExerciseExecutionType.timed,
      value: 25,
      description: 'Gerakan cepat, jaga pinggul tetap rendah',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const ExerciseExecutionScreen(
      exercises: _demoExercises,
      workoutTitle: 'Full Body Workout',
      themeColor: _accent,
    );
  }
}
