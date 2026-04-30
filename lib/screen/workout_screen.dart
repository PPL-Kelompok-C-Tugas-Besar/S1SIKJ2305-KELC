import 'dart:async';
import 'package:flutter/material.dart';

// ── Data Model ──────────────────────────────────────────────────────────────

enum ExerciseType { reps, timed }

class Exercise {
  final String name;
  final String gif;
  final ExerciseType type;

  /// reps count (for reps-type) or recommended seconds (for timed-type)
  final int beginner;
  final int intermediate;
  final int advanced;
  const Exercise({
    required this.name,
    required this.gif,
    required this.type,
    required this.beginner,
    required this.intermediate,
    required this.advanced,
  });
}

enum WorkoutLevel { beginner, intermediate, advanced }

class WorkoutCategory {
  final WorkoutLevel level;
  final String label;
  final String subtitle;
  final Color color;
  final Color darkColor;
  final IconData icon;
  final int totalMinutes;
  final List<Exercise> exercises;
  const WorkoutCategory({
    required this.level,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.totalMinutes,
    required this.exercises,
  });
}

// ── Exercise Database ────────────────────────────────────────────────────────

const List<Exercise> _allExercises = [
  Exercise(
    name: 'Jumping Jacks',
    gif: 'assets/gifs/jumping_jack.gif',
    type: ExerciseType.reps,
    beginner: 15,
    intermediate: 25,
    advanced: 40,
  ),
  Exercise(
    name: 'Push Up',
    gif: 'assets/gifs/pushups.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 15,
    advanced: 25,
  ),
  Exercise(
    name: 'Air Squat',
    gif: 'assets/gifs/squat.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 20,
    advanced: 30,
  ),
  Exercise(
    name: 'Plank',
    gif: 'assets/gifs/plank.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 40,
    advanced: 60,
  ),
  Exercise(
    name: 'Mountain Climbers',
    gif: 'assets/gifs/mountain_climb.gif',
    type: ExerciseType.reps,
    beginner: 16,
    intermediate: 24,
    advanced: 36,
  ),
  Exercise(
    name: 'Fitness Legs',
    gif: 'assets/gifs/fitness_legs.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 18,
    advanced: 28,
  ),
  Exercise(
    name: 'Dumbbell Flyes',
    gif: 'assets/gifs/chest_fly_dumbells.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 15,
    advanced: 20,
  ),
  Exercise(
    name: 'High Knees',
    gif: 'assets/gifs/jumping_jack.gif',
    type: ExerciseType.reps,
    beginner: 20,
    intermediate: 30,
    advanced: 50,
  ),
  Exercise(
    name: 'Lunges',
    gif: 'assets/gifs/squat.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 16,
    advanced: 24,
  ),
  Exercise(
    name: 'Wall Sit',
    gif: 'assets/gifs/plank.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 35,
    advanced: 60,
  ),
  Exercise(
    name: 'Burpees',
    gif: 'assets/gifs/pushups.gif',
    type: ExerciseType.reps,
    beginner: 5,
    intermediate: 10,
    advanced: 18,
  ),
  Exercise(
    name: 'Crunches',
    gif: 'assets/gifs/mountain_climb.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 20,
    advanced: 30,
  ),
  Exercise(
    name: 'Glute Bridge',
    gif: 'assets/gifs/fitness_legs.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 18,
    advanced: 25,
  ),
  Exercise(
    name: 'Superman Hold',
    gif: 'assets/gifs/plank.gif',
    type: ExerciseType.timed,
    beginner: 15,
    intermediate: 30,
    advanced: 45,
  ),
  Exercise(
    name: 'Tricep Dips',
    gif: 'assets/gifs/pushups.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 14,
    advanced: 20,
  ),
  Exercise(
    name: 'Leg Raises',
    gif: 'assets/gifs/fitness_legs.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 15,
    advanced: 22,
  ),
];

final List<WorkoutCategory> _categories = [
  WorkoutCategory(
    level: WorkoutLevel.beginner,
    label: 'Beginner',
    subtitle: '15 menit · 8 latihan · Santai',
    color: const Color(0xFF4CAF50),
    darkColor: const Color(0xFF2E7D32),
    icon: Icons.directions_walk,
    totalMinutes: 15,
    exercises: _allExercises.sublist(0, 8),
  ),
  WorkoutCategory(
    level: WorkoutLevel.intermediate,
    label: 'Intermediate',
    subtitle: '25 menit · 12 latihan · Menantang',
    color: const Color(0xFFFF9800),
    darkColor: const Color(0xFFE65100),
    icon: Icons.directions_run,
    totalMinutes: 25,
    exercises: _allExercises.sublist(0, 12),
  ),
  WorkoutCategory(
    level: WorkoutLevel.advanced,
    label: 'Advanced',
    subtitle: '40 menit · 16 latihan · Keras!',
    color: const Color(0xFFF44336),
    darkColor: const Color(0xFFB71C1C),
    icon: Icons.local_fire_department,
    totalMinutes: 40,
    exercises: _allExercises,
  ),
];

// ── Screen States ─────────────────────────────────────────────────────────

enum ScreenState { selectCategory, previewPlan, doExercise, resting, complete }

// ── Main Widget ──────────────────────────────────────────────────────────────

class AlifWorkoutScreen extends StatefulWidget {
  const AlifWorkoutScreen({super.key});
  @override
  State<AlifWorkoutScreen> createState() => _AlifWorkoutScreenState();
}

class _AlifWorkoutScreenState extends State<AlifWorkoutScreen>
    with TickerProviderStateMixin {
  ScreenState _screen = ScreenState.selectCategory;
  WorkoutCategory? _selectedCategory;
  int _exerciseIndex = 0;
  int _timerSeconds = 0;
  bool _isPaused = false;
  Timer? _timer;
  int _completedReps = 0;

  // Animation
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Exercise get _currentExercise => _selectedCategory!.exercises[_exerciseIndex];

  int _valueFor(Exercise ex) {
    switch (_selectedCategory!.level) {
      case WorkoutLevel.beginner:
        return ex.beginner;
      case WorkoutLevel.intermediate:
        return ex.intermediate;
      case WorkoutLevel.advanced:
        return ex.advanced;
    }
  }

  bool get _isLastExercise =>
      _exerciseIndex >= _selectedCategory!.exercises.length - 1;

  // ── Actions ───────────────────────────────────────────────────────────────

  void _selectCategory(WorkoutCategory cat) {
    setState(() {
      _selectedCategory = cat;
      _exerciseIndex = 0;
      _screen = ScreenState.previewPlan;
    });
  }

  void _startSession() {
    setState(() => _screen = ScreenState.doExercise);
    final ex = _currentExercise;
    if (ex.type == ExerciseType.timed) {
      _beginTimer(_valueFor(ex));
    }
  }

  void _beginTimer(int seconds) {
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
        _afterExercise();
      }
    });
  }

  void _doneReps() {
    _timer?.cancel();
    _afterExercise();
  }

  void _afterExercise() {
    if (_isLastExercise) {
      setState(() => _screen = ScreenState.complete);
    } else {
      setState(() => _screen = ScreenState.resting);
      _beginTimer(15); // 15 detik istirahat antar latihan
    }
  }

  void _skipRest() {
    _timer?.cancel();
    _nextExercise();
  }

  void _nextExercise() {
    setState(() {
      _exerciseIndex++;
      _screen = ScreenState.doExercise;
    });
    final ex = _currentExercise;
    if (ex.type == ExerciseType.timed) {
      _beginTimer(_valueFor(ex));
    } else {
      _timer?.cancel();
    }
  }

  void _backToCategories() {
    _timer?.cancel();
    setState(() {
      _screen = ScreenState.selectCategory;
      _selectedCategory = null;
      _exerciseIndex = 0;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    final showBack =
        _screen != ScreenState.selectCategory &&
        _screen != ScreenState.complete;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fitness_center,
            color: Colors.orangeAccent,
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'GYMBRO',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
              onPressed: _backToCategories,
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_screen) {
      case ScreenState.selectCategory:
        return _categoryScreen();
      case ScreenState.previewPlan:
        return _previewScreen();
      case ScreenState.doExercise:
        return _exerciseScreen();
      case ScreenState.resting:
        return _restScreen();
      case ScreenState.complete:
        return _completeScreen();
    }
  }

  // ── 1. Category Selection ─────────────────────────────────────────────────

  Widget _categoryScreen() {
    return SingleChildScrollView(
      key: const ValueKey('category'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Pilih Level',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Workout Hari Ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          ..._categories.map((cat) => _categoryCard(cat)),
        ],
      ),
    );
  }

  Widget _categoryCard(WorkoutCategory cat) {
    return GestureDetector(
      onTap: () => _selectCategory(cat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cat.darkColor, cat.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cat.color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(cat.icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip(
                          Icons.timer_outlined,
                          '${cat.totalMinutes} menit',
                        ),
                        const SizedBox(width: 8),
                        _chip(
                          Icons.fitness_center,
                          '${cat.exercises.length} latihan',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Plan Preview ───────────────────────────────────────────────────────

  Widget _previewScreen() {
    final cat = _selectedCategory!;
    return Column(
      key: const ValueKey('preview'),
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cat.darkColor, cat.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cat.exercises.length} Latihan · ${cat.totalMinutes} Menit',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: cat.exercises.length,
            itemBuilder: (ctx, i) {
              final ex = cat.exercises[i];
              final val = _valueFor(ex);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cat.color.withValues(alpha: 0.2),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: cat.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ex.type == ExerciseType.reps
                                ? '$val reps'
                                : '$val detik (timer)',
                            style: TextStyle(color: cat.color, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      ex.type == ExerciseType.reps ? Icons.repeat : Icons.timer,
                      color: Colors.white30,
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: _bigButton('MULAI WORKOUT', cat.color, _startSession),
        ),
      ],
    );
  }

  // ── 3. Exercise Screen ────────────────────────────────────────────────────

  Widget _exerciseScreen() {
    final cat = _selectedCategory!;
    final ex = _currentExercise;
    final val = _valueFor(ex);
    final isTimer = ex.type == ExerciseType.timed;
    final progress = (_exerciseIndex + 1) / cat.exercises.length;

    return SingleChildScrollView(
      key: ValueKey('ex_$_exerciseIndex'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        children: [
          // Progress bar
          _progressRow(
            progress,
            _exerciseIndex + 1,
            cat.exercises.length,
            cat.color,
          ),
          const SizedBox(height: 16),

          // Media
          _mediaBox(ex.gif),
          const SizedBox(height: 18),

          // Name
          Text(
            ex.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Badge: reps or timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cat.darkColor, cat.color]),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isTimer ? Icons.timer : Icons.repeat,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isTimer ? 'Timer: $val detik' : 'Target: $val reps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timer display or rep counter
          if (isTimer) ...[
            ScaleTransition(
              scale: _pulseAnim,
              child: Text(
                _timerSeconds.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const Text(
              'detik tersisa',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 72,
                  icon: Icon(
                    _isPaused
                        ? Icons.play_circle_fill
                        : Icons.pause_circle_filled,
                    color: cat.color,
                  ),
                  onPressed: () => setState(() => _isPaused = !_isPaused),
                ),
              ],
            ),
          ] else ...[
            // Reps counter
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cat.color.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Text(
                    'TARGET REPS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$val',
                    style: TextStyle(
                      color: cat.color,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'repetisi',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _bigButton('✓  SELESAI ${val} REPS', cat.color, _doneReps),
          ],
        ],
      ),
    );
  }

  // ── 4. Rest Screen ────────────────────────────────────────────────────────

  Widget _restScreen() {
    return Center(
      key: const ValueKey('rest'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.self_improvement,
            color: Colors.greenAccent,
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'ISTIRAHAT',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latihan berikutnya: ${_selectedCategory!.exercises[_exerciseIndex + 1].name}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Text(
            _timerSeconds.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 90,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const Text(
            'detik',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _bigButton(
            'SKIP ISTIRAHAT',
            Colors.greenAccent,
            _skipRest,
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }

  // ── 5. Complete Screen ────────────────────────────────────────────────────

  Widget _completeScreen() {
    final cat = _selectedCategory!;
    return Center(
      key: const ValueKey('complete'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              'SELESAI!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu hebat! Workout ${cat.label} selesai.',
              style: const TextStyle(color: Colors.white60, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cat.color.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statCol('${cat.exercises.length}', 'Latihan'),
                  _statCol('${cat.totalMinutes}', 'Menit'),
                  _statCol(cat.label, 'Level'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _bigButton('KEMBALI KE MENU', cat.color, _backToCategories),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  Widget _progressRow(double progress, int current, int total, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latihan $current dari $total',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _mediaBox(String path) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.fitness_center, color: Colors.white24, size: 64),
          ),
        ),
      ),
    );
  }

  Widget _bigButton(
    String text,
    Color color,
    VoidCallback onTap, {
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _btnPressed = true),
      onTapUp: (_) {
        setState(() => _btnPressed = false);
        onTap();
      },
      onTapCancel: () => setState(() => _btnPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        transform: _btnPressed
            ? (Matrix4.identity()..translate(0.0, 3.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _btnPressed
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
