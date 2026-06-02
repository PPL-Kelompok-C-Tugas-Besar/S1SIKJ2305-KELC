import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymbro/screen/exercise_execution_screen.dart';

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

// ── Warm-up Exercises (3 gerakan peregangan awal) ────────────────────────────
const List<Exercise> _warmupExercises = [
  Exercise(
    name: 'Neck Rolls',
    gif: 'assets/gifs/neck-rolls.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 20,
    advanced: 20,
  ),
  Exercise(
    name: 'Arm Circles',
    gif: 'assets/gifs/arm-circles.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 20,
    advanced: 20,
  ),
  Exercise(
    name: 'Hip Circles',
    gif: 'assets/gifs/hip-circles.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 20,
    advanced: 20,
  ),
];

// ── Per-Level Exercise Lists ──────────────────────────────────────────────────
const List<Exercise> _beginnerExercises = [
  Exercise(
    name: 'Squat',
    gif: 'assets/gifs/squat.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Glute Bridge',
    gif: 'assets/gifs/fitness_legs.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Standing Side Leg Raise',
    gif: 'assets/gifs/side-leg-raise.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 10,
    advanced: 10,
  ),
  Exercise(
    name: 'Sit-up',
    gif: 'assets/gifs/sit-up.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Bicycle Crunch',
    gif: 'assets/gifs/bicycle-crunch.gif',
    type: ExerciseType.reps,
    beginner: 16,
    intermediate: 16,
    advanced: 16,
  ),
  Exercise(
    name: 'Mountain Climbers',
    gif: 'assets/gifs/mountain_climb.gif',
    type: ExerciseType.reps,
    beginner: 20,
    intermediate: 20,
    advanced: 20,
  ),
  Exercise(
    name: 'Wall Sit',
    gif: 'assets/gifs/wall-squat.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 20,
    advanced: 20,
  ),
  Exercise(
    name: 'Lunges',
    gif: 'assets/gifs/Lunges.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 10,
    advanced: 10,
  ),
];

const List<Exercise> _intermediateExercises = [
  Exercise(
    name: 'Bulgarian Split Squat',
    gif: 'assets/gifs/squat.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 10,
    advanced: 10,
  ),
  Exercise(
    name: 'Jump Squat',
    gif: 'assets/gifs/Jump-Squat.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Leg Raise',
    gif: 'assets/gifs/leg-raises.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Russian Twist',
    gif: 'assets/gifs/Russian-Twist.gif',
    type: ExerciseType.reps,
    beginner: 16,
    intermediate: 20,
    advanced: 20,
  ),
  Exercise(
    name: 'Burpees',
    gif: 'assets/gifs/burpees.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 10,
    advanced: 10,
  ),
  Exercise(
    name: 'High Knees',
    gif: 'assets/gifs/high-knees.gif',
    type: ExerciseType.reps,
    beginner: 20,
    intermediate: 30,
    advanced: 30,
  ),
  Exercise(
    name: 'Decline Push-Up',
    gif: 'assets/gifs/pushups.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Diamond Push-Up',
    gif: 'assets/gifs/pushups.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 10,
    advanced: 10,
  ),
  Exercise(
    name: 'Pike Push-Up',
    gif: 'assets/gifs/Pike-Push-Ups.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 10,
    advanced: 10,
  ),
  Exercise(
    name: 'Bench Dips',
    gif: 'assets/gifs/bench-dips.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 12,
    advanced: 12,
  ),
  Exercise(
    name: 'Single-Leg Romanian Deadlift',
    gif: 'assets/gifs/fitness_legs.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 10,
    advanced: 10,
  ),
  Exercise(
    name: 'Skater Jump',
    gif: 'assets/gifs/skater-jump.gif',
    type: ExerciseType.reps,
    beginner: 12,
    intermediate: 16,
    advanced: 16,
  ),
];

const List<Exercise> _advancedExercises = [
  Exercise(
    name: 'Handstand Push-Up',
    gif: 'assets/gifs/handstand-pushup.gif',
    type: ExerciseType.reps,
    beginner: 3,
    intermediate: 5,
    advanced: 8,
  ),
  Exercise(
    name: 'Pseudo Planche Push-Up',
    gif: 'assets/gifs/pseudo-planche-pushup.gif',
    type: ExerciseType.reps,
    beginner: 5,
    intermediate: 8,
    advanced: 12,
  ),
  Exercise(
    name: 'Archer Push-Up',
    gif: 'assets/gifs/archer-pushup.gif',
    type: ExerciseType.reps,
    beginner: 5,
    intermediate: 8,
    advanced: 12,
  ),
  Exercise(
    name: 'Clap Push-Up',
    gif: 'assets/gifs/clap-pushup.gif',
    type: ExerciseType.reps,
    beginner: 5,
    intermediate: 8,
    advanced: 12,
  ),
  Exercise(
    name: 'Pistol Squat',
    gif: 'assets/gifs/pistol-squat.gif',
    type: ExerciseType.reps,
    beginner: 3,
    intermediate: 5,
    advanced: 8,
  ),
  Exercise(
    name: 'Bulgarian Split Squat',
    gif: 'assets/gifs/bulgarian-split-squat.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 12,
    advanced: 15,
  ),
  Exercise(
    name: 'Single-Leg Glute Bridge',
    gif: 'assets/gifs/Single-Leg-Glute-Bridge.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 12,
    advanced: 15,
  ),
  Exercise(
    name: 'Hollow Body Hold',
    gif: 'assets/gifs/hollow-body.gif',
    type: ExerciseType.timed,
    beginner: 20,
    intermediate: 35,
    advanced: 50,
  ),
  Exercise(
    name: 'Dragon Flag',
    gif: 'assets/gifs/dragon-flag.gif',
    type: ExerciseType.reps,
    beginner: 3,
    intermediate: 5,
    advanced: 8,
  ),
  Exercise(
    name: 'V-Ups',
    gif: 'assets/gifs/v-ups.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 12,
    advanced: 18,
  ),
  Exercise(
    name: 'Plank to Push-Up',
    gif: 'assets/gifs/plank-push-up.gif',
    type: ExerciseType.reps,
    beginner: 8,
    intermediate: 12,
    advanced: 16,
  ),
  Exercise(
    name: 'Jump Lunges',
    gif: 'assets/gifs/Lunges.gif',
    type: ExerciseType.reps,
    beginner: 10,
    intermediate: 14,
    advanced: 20,
  ),
  Exercise(
    name: 'High Knees',
    gif: 'assets/gifs/high-knees.gif',
    type: ExerciseType.reps,
    beginner: 30,
    intermediate: 40,
    advanced: 50,
  ),
  Exercise(
    name: 'Handstand Shoulder Taps',
    gif: 'assets/gifs/handstand-shoulder-taps.gif',
    type: ExerciseType.reps,
    beginner: 6,
    intermediate: 10,
    advanced: 16,
  ),
  Exercise(
    name: 'L-Sit',
    gif: 'assets/gifs/plank.gif',
    type: ExerciseType.timed,
    beginner: 10,
    intermediate: 20,
    advanced: 30,
  ),
  Exercise(
    name: 'Tuck Planche',
    gif: 'assets/gifs/plank.gif',
    type: ExerciseType.timed,
    beginner: 10,
    intermediate: 20,
    advanced: 30,
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
    exercises: _beginnerExercises,
  ),
  WorkoutCategory(
    level: WorkoutLevel.intermediate,
    label: 'Intermediate',
    subtitle: '25 menit · 12 latihan · Menantang',
    color: const Color(0xFFFF9800),
    darkColor: const Color(0xFFE65100),
    icon: Icons.directions_run,
    totalMinutes: 25,
    exercises: _intermediateExercises,
  ),
  WorkoutCategory(
    level: WorkoutLevel.advanced,
    label: 'Advanced',
    subtitle: '40 menit · 16 latihan · Keras!',
    color: const Color(0xFFF44336),
    darkColor: const Color(0xFFB71C1C),
    icon: Icons.local_fire_department,
    totalMinutes: 40,
    exercises: _advancedExercises,
  ),
];

// ── Screen States ─────────────────────────────────────────────────────────

enum ScreenState {
  selectCategory,
  previewPlan,
  warmup,
  doExercise,
  resting,
  complete,
}

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
  int _warmupIndex = 0;

  // Animation
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _btnPressed = false;
  bool _isSaving = false;

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

  Future<void> _saveWorkoutHistory() async {
    final cat = _selectedCategory;
    if (cat == null) return;

    // Simulasi delay proses simpan
    await Future.delayed(const Duration(seconds: 2));

    debugPrint('--- Workout Summary ---');
    debugPrint('Level: ${cat.label}');
    debugPrint('Total Latihan: ${cat.exercises.length}');
    debugPrint('Durasi: ${cat.totalMinutes} Menit');
    debugPrint('-----------------------');
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

  // warmup helpers
  Exercise get _currentWarmup => _warmupExercises[_warmupIndex];
  bool get _isLastWarmup => _warmupIndex >= _warmupExercises.length - 1;

  void _startSession() {
    // Langsung gabung warmup + latihan utama ke ExerciseExecutionScreen
    _beginMainExercise();
  }

  void _doneWarmupStep() {
    _timer?.cancel();
    if (_isLastWarmup) {
      _beginMainExercise();
    } else {
      setState(() => _warmupIndex++);
      final wu = _currentWarmup;
      if (wu.type == ExerciseType.timed) {
        _beginTimer(_valueFor(wu));
      }
    }
  }

  void _beginMainExercise() {
    _timer?.cancel();
    final cat = _selectedCategory!;

    // Warmup exercises di awal (digabung sebelum latihan utama)
    final warmupItems = _warmupExercises.map((e) {
      return ExerciseExecutionItem(
        name: e.name,
        gifPath: e.gif,
        type: e.type == ExerciseType.reps
            ? ExerciseExecutionType.reps
            : ExerciseExecutionType.timed,
        value: _valueFor(e),
        description: 'Pemanasan',
      );
    }).toList();

    // Latihan utama sesuai level
    final mainItems = cat.exercises.map((e) {
      return ExerciseExecutionItem(
        name: e.name,
        gifPath: e.gif,
        type: e.type == ExerciseType.reps
            ? ExerciseExecutionType.reps
            : ExerciseExecutionType.timed,
        value: _valueFor(e),
      );
    }).toList();

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ExerciseExecutionScreen(
              exercises: [...warmupItems, ...mainItems],
              workoutTitle: '${cat.label} Workout',
              themeColor: cat.color,
              warmupCount: warmupItems.length,
            ),
          ),
        )
        .then((_) => _backToCategories());
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

  void _addRestSeconds(int seconds) {
    setState(() {
      _timerSeconds += seconds;
    });
  }

  void _showEditRestTimeDialog() {
    final controller = TextEditingController(text: _timerSeconds.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ubah Waktu Istirahat',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Color(0xFF2D2D2D)),
          decoration: const InputDecoration(
            labelText: 'Durasi',
            labelStyle: TextStyle(color: Color(0xFF6C757D)),
            suffixText: 'detik',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2E7D32)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6C757D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newSeconds = int.tryParse(controller.text);
              if (newSeconds != null && newSeconds > 0) {
                setState(() {
                  _timerSeconds = newSeconds;
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F2F5), // Light Grey
            Color(0xFFFFE5D9), // Soft Peach
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildBody(),
        ),
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
              color: Color(0xFF2D2D2D),
              letterSpacing: 3,
            ),
          ),
        ],
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D2D2D)),
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
      case ScreenState.warmup:
        return _warmupScreen();
      case ScreenState.doExercise:
        return _exerciseScreen();
      case ScreenState.resting:
        return _restScreen();
      case ScreenState.complete:
        return _completeScreen();
    }
  }

  // ── Warmup Screen ─────────────────────────────────────────────────────────
  Widget _warmupScreen() {
    final wu = _currentWarmup;
    final isTimer = wu.type == ExerciseType.timed;
    final val = _valueFor(wu);
    final progress = (_warmupIndex + 1) / _warmupExercises.length;
    final cat = _selectedCategory!;

    return SingleChildScrollView(
      key: ValueKey('wu_$_warmupIndex'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        children: [
          // Warmup badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.whatshot, color: Colors.greenAccent, size: 18),
                SizedBox(width: 8),
                Text(
                  'PEMANASAN',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _progressRow(
            progress,
            _warmupIndex + 1,
            _warmupExercises.length,
            Colors.greenAccent,
          ),
          const SizedBox(height: 16),
          _mediaBox(wu.gif),
          const SizedBox(height: 16),
          Text(
            wu.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (isTimer) ...[
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _pulseAnim,
              child: Text(
                _timerSeconds.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 90,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const Text(
              'detik',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 16),
            IconButton(
              iconSize: 60,
              icon: Icon(
                _isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled,
                color: Colors.greenAccent,
              ),
              onPressed: () => setState(() => _isPaused = !_isPaused),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'TARGET',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$val',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'reps',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _bigButton(
              _isLastWarmup ? 'MULAI LATIHAN ▶' : 'SELESAI · NEXT ▶',
              cat.color,
              _doneWarmupStep,
            ),
          ],
          if (isTimer) ...[
            const SizedBox(height: 12),
            _bigButton('SKIP', Colors.white24, _doneWarmupStep),
          ],
        ],
      ),
    );
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
              color: Color(0xFF6C757D),
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Workout Hari Ini',
            style: TextStyle(
              color: Color(0xFF2D2D2D),
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
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                              color: Color(0xFF2D2D2D),
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
                      color: Colors.black38,
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
            _bigButton('✓  SELESAI $val REPS', cat.color, _doneReps),
          ],
        ],
      ),
    );
  }

  // ── 4. Rest Screen ────────────────────────────────────────────────────────

  Widget _restScreen() {
    final next = _selectedCategory!.exercises[_exerciseIndex + 1];
    const restGreen = Color(0xFF2E7D32);

    return Center(
      key: const ValueKey('rest'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Meditating circle icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: restGreen.withValues(alpha: 0.12),
                border: Border.all(color: restGreen, width: 2),
              ),
              child: const Icon(
                Icons.self_improvement,
                color: restGreen,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ISTIRAHAT',
              style: TextStyle(
                color: restGreen,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Berikutnya: ${next.name}',
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ScaleTransition(
              scale: _pulseAnim,
              child: Text(
                '$_timerSeconds',
                style: const TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
            const Text(
              'detik',
              style: TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            // Side-by-side buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _showEditRestTimeDialog,
                  icon: const Icon(Icons.edit_calendar_rounded, color: restGreen, size: 20),
                  label: const Text(
                    'Edit Waktu',
                    style: TextStyle(
                      color: restGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: restGreen, width: 1.5),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => _addRestSeconds(20),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: restGreen, width: 1.5),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '+ 20s',
                    style: TextStyle(
                      color: restGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            _bigButton(
              'SKIP ISTIRAHAT →',
              restGreen,
              _skipRest,
              textColor: Colors.white,
            ),
          ],
        ),
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
                color: Color(0xFF2D2D2D),
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu hebat! Workout ${cat.label} selesai.',
              style: const TextStyle(color: Color(0xFF6C757D), fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cat.color.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
            _bigButton('KEMBALI KE MENU', cat.color, () async {
              if (_isSaving) return;
              setState(() => _isSaving = true);

              await _saveWorkoutHistory();

              if (!mounted) return;

              setState(() => _isSaving = false);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✓ Riwayat latihan berhasil disimpan!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              _backToCategories();
            }, isLoading: _isSaving),
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
              style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13),
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
            backgroundColor: Colors.black.withOpacity(0.08),
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
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.fitness_center, color: Colors.black26, size: 64),
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
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTapDown: isLoading ? null : (_) => setState(() => _btnPressed = true),
      onTapUp: isLoading
          ? null
          : (_) {
              setState(() => _btnPressed = false);
              onTap();
            },
      onTapCancel: isLoading ? null : () => setState(() => _btnPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        transform: _btnPressed && !isLoading
            // ignore: deprecated_member_use
            ? (Matrix4.identity()..translate(0.0, 3.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: (_btnPressed || isLoading)
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
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
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
            color: Color(0xFF2D2D2D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6C757D), fontSize: 12),
        ),
      ],
    );
  }
}
