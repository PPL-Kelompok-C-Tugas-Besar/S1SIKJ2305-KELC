import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/calorie_calculator.dart';
import '../../services/history_service.dart';

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

// ── Color Palette (Light Mode) ─────────────────────────────────────────────────

const _bg = Colors.transparent;
const _surface = Colors.white70;
const _card = Colors.white;
const _border = Color(0xFFE2E8F0);
const _accent = Color(0xFFFF6B35);
const _green = Color(0xFF2E7D32);
const _white = Color(0xFF2D2D2D);

// ── Screen ────────────────────────────────────────────────────────────────────

class ExerciseExecutionScreen extends StatefulWidget {
  final List<ExerciseExecutionItem> exercises;
  final String workoutTitle;
  final Color themeColor;
  /// Jumlah item pertama yang merupakan warmup (0 = tidak ada warmup)
  final int warmupCount;
  final String workoutLevel;
  final int durationMinutes;

  const ExerciseExecutionScreen({
    super.key,
    required this.exercises,
    required this.workoutTitle,
    this.themeColor = _accent,
    this.warmupCount = 0,
    this.workoutLevel = 'beginner',
    this.durationMinutes = 15,
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

  // ── Warmup Group (tampilkan semua warmup sekaligus) ──
  bool _showingWarmupGroup = false;
  int _warmupGroupSeconds = 30;

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
        statusBarIconBrightness: Brightness.dark,
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

    // Jika ada warmup items, tampilkan group warmup screen dulu
    if (widget.warmupCount > 0) {
      _showingWarmupGroup = true;
      _startWarmupGroupTimer();
    } else {
      _loadExercise();
    }
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

  // ── Warmup Group Logic ────────────────────────────────────────────────────

  void _startWarmupGroupTimer() {
    _timer?.cancel();
    setState(() {
      _warmupGroupSeconds = 30;
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;
      if (_warmupGroupSeconds > 0) {
        setState(() => _warmupGroupSeconds--);
      } else {
        t.cancel();
        _finishWarmupGroup();
      }
    });
  }

  /// Warmup group selesai → pindah ke rest "Pemanasan Selesai" → latihan utama
  void _finishWarmupGroup() {
    _timer?.cancel();
    setState(() {
      _showingWarmupGroup = false;
      // Posisikan di item warmup terakhir agar rest view mendeteksi isWarmupDone
      _currentIndex = widget.warmupCount - 1;
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

  void _skipWarmupGroup() {
    _timer?.cancel();
    _finishWarmupGroup();
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

  void _addRestSeconds(int seconds) {
    setState(() {
      _restSeconds += seconds;
    });
  }

  void _showEditRestTimeDialog() {
    final controller = TextEditingController(text: _restSeconds.toString());
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
                  _restSeconds = newSeconds;
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
        exercises: widget.exercises,
        themeColor: widget.themeColor,
        workoutLevel: widget.workoutLevel,
        durationMinutes: widget.durationMinutes,
        onDone: () => Navigator.of(context)
          ..pop()
          ..pop(),
      ),
    );
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
        backgroundColor: _bg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showingWarmupGroup
              ? _buildWarmupGroupView()
              : _isResting
                  ? _buildRestView()
                  : _buildExerciseView(),
        ),
      ),
    );
  }

  // ── Warmup Group View (3 GIF ditampilkan sekaligus) ──────────────────────

  Widget _buildWarmupGroupView() {
    final top = MediaQuery.of(context).padding.top;
    final warmupItems = widget.exercises.sublist(0, widget.warmupCount);

    return Column(
      key: const ValueKey('warmup_group'),
      children: [
        // ── Header ──
        Container(
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 12),
          color: _surface,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF2D2D2D),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.workoutTitle,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Badge pemanasan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: _green.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: _green,
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pemanasan',
                          style: TextStyle(
                            color: _green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Banner SESI PEMANASAN ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.10),
            border: Border(
              bottom:
                  BorderSide(color: _green.withValues(alpha: 0.30), width: 1),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: _green, size: 16),
              SizedBox(width: 8),
              Text(
                'SESI PEMANASAN',
                style: TextStyle(
                  color: _green,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.local_fire_department, color: _green, size: 16),
            ],
          ),
        ),

        // ── 3 GIF Cards ──
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: warmupItems.map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _green.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _green.withValues(alpha: 0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              item.gifPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, st) => Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  color: _green.withValues(alpha: 0.4),
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Timer & Controls ──
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Lakukan semua gerakan di atas',
                  style: TextStyle(color: Color(0xFF6C757D), fontSize: 12),
                ),
                const SizedBox(height: 6),
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Text(
                    '$_warmupGroupSeconds',
                    style: const TextStyle(
                      color: _white,
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const Text(
                  'detik',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ActionButton(
                    label: 'SKIP PEMANASAN →',
                    color: Colors.black.withValues(alpha: 0.08),
                    textColor: const Color(0xFF2D2D2D),
                    onTap: _skipWarmupGroup,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Exercise View ─────────────────────────────────────────────────────────

  Widget _buildExerciseView() {
    final ex = _current;
    final color = widget.themeColor;
    final isWarmup =
        widget.warmupCount > 0 && _currentIndex < widget.warmupCount;

    return Column(
      key: const ValueKey('exercise'),
      children: [
        // ── Top Bar ──
        _TopBar(
          title: widget.workoutTitle,
          current: _currentIndex + 1,
          total: widget.exercises.length,
          progress: _progress,
          color: isWarmup ? _green : color,
          onBack: () => Navigator.of(context).pop(),
          isWarmup: isWarmup,
          warmupCurrent: isWarmup ? _currentIndex + 1 : 0,
          warmupTotal: widget.warmupCount,
        ),

        // ── Banner PEMANASAN (hanya saat warmup) ──
        if (isWarmup)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.10),
              border: Border(
                bottom: BorderSide(
                  color: _green.withValues(alpha: 0.30),
                  width: 1,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, color: _green, size: 16),
                SizedBox(width: 8),
                Text(
                  'SESI PEMANASAN',
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.local_fire_department, color: _green, size: 16),
              ],
            ),
          ),

        // ── Media Area (fokus utama – vertikal) ──
        Expanded(
          flex: 5,
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _MediaPanel(
                gifPath: ex.gifPath,
                color: isWarmup ? _green : color,
              ),
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
              color: isWarmup ? _green : color,
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
    // Deteksi: apakah ini jeda antara warmup terakhir dan latihan utama pertama?
    final isWarmupDone =
        widget.warmupCount > 0 && _currentIndex == widget.warmupCount - 1;

    return Center(
      key: ValueKey(isWarmupDone ? 'warmup_done' : 'rest'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWarmupDone) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _green.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: _green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'PEMANASAN SELESAI!',
                      style: TextStyle(
                        color: _green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
            // Meditating circle icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.12),
                border: Border.all(color: _green, width: 2),
              ),
              child: const Icon(
                Icons.self_improvement,
                color: _green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ISTIRAHAT',
              style: TextStyle(
                color: _green,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isWarmupDone ? 'Latihan pertama: ${next.name}' : 'Berikutnya: ${next.name}',
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
                '$_restSeconds',
                style: const TextStyle(
                  color: _white,
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
                  icon: const Icon(Icons.edit_calendar_rounded, color: _green, size: 20),
                  label: const Text(
                    'Edit Waktu',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _green, width: 1.5),
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
                    side: const BorderSide(color: _green, width: 1.5),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '+ 20s',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            _ActionButton(
              label: isWarmupDone ? 'MULAI LATIHAN →' : 'SKIP ISTIRAHAT →',
              color: isWarmupDone ? widget.themeColor : _green,
              textColor: Colors.white,
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
  final bool isWarmup;
  final int warmupCurrent;
  final int warmupTotal;

  const _TopBar({
    required this.title,
    required this.current,
    required this.total,
    required this.progress,
    required this.color,
    required this.onBack,
    this.isWarmup = false,
    this.warmupCurrent = 0,
    this.warmupTotal = 0,
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
                  color: Color(0xFF2D2D2D),
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
              // Badge PEMANASAN atau counter latihan
              if (isWarmup)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: _green,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pemanasan $warmupCurrent/$warmupTotal',
                        style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
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
              style: const TextStyle(color: Color(0xFF6C757D), fontSize: 12),
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
            color: isTimer && !isLast ? Colors.black.withValues(alpha: 0.08) : color,
            textColor: isTimer && !isLast ? const Color(0xFF2D2D2D) : Colors.white,
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
            style: TextStyle(color: Color(0xFF6C757D), fontSize: 16),
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
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = _white,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 14,
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

// ── [PKCTB-384] Completion Dialog ─────────────────────────────────────────────

class _CompletionDialog extends StatefulWidget {
  final String workoutTitle;
  final int totalExercises;
  final List<ExerciseExecutionItem> exercises;
  final Color themeColor;
  final String workoutLevel;
  final int durationMinutes;
  final VoidCallback onDone;

  const _CompletionDialog({
    required this.workoutTitle,
    required this.totalExercises,
    required this.exercises,
    required this.themeColor,
    required this.workoutLevel,
    required this.durationMinutes,
    required this.onDone,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  bool _isSaving = false;
  bool _showBreakdown = false;
  late final int _caloriesBurned;
  late final List<int> _perExerciseCalories;

  @override
  void initState() {
    super.initState();
    _caloriesBurned = CalorieCalculator.calculateCalories(
      durationMinutes: widget.durationMinutes,
      level: widget.workoutLevel,
    );

    // [PKCTB-384] Hitung distribusi kalori per exercise
    final effortList = widget.exercises.map((ex) {
      return CalorieCalculator.estimateEffortSeconds(
        isTimed: ex.type == ExerciseExecutionType.timed,
        value: ex.value,
      );
    }).toList();

    _perExerciseCalories = CalorieCalculator.distributeCaloriesPerExercise(
      totalCalories: _caloriesBurned,
      effortSecondsPerExercise: effortList,
    );
  }

  Future<void> _saveWorkoutHistory() async {
    try {
      final ok = await HistoryService().addHistory(
        workoutName: widget.workoutTitle,
        durationMinutes: widget.durationMinutes,
        caloriesBurned: _caloriesBurned,
      );
      debugPrint('Workout history save status: $ok');
    } catch (e) {
      debugPrint('Error saving workout history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
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
                  widget.workoutTitle,
                  style: const TextStyle(color: Color(0xFF6C757D), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ── [PKCTB-384] Prominent Kalori Terbakar Section ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7043).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            'Kalori Terbakar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('🔥', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_caloriesBurned',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text(
                              ' kkal',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stat Chips (Latihan & Menit) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statChip('${widget.totalExercises}', 'Latihan', widget.themeColor),
                    _statChip('${widget.durationMinutes}', 'Menit', const Color(0xFF6BE5FF)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── [PKCTB-384] Breakdown Per Latihan ──
                GestureDetector(
                  onTap: () => setState(() => _showBreakdown = !_showBreakdown),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFFFF7043), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Detail Per Latihan',
                          style: TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _showBreakdown ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFF6C757D),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showBreakdown) ...[
                  const SizedBox(height: 12),
                  ...List.generate(widget.exercises.length, (i) {
                    final ex = widget.exercises[i];
                    final cal = _perExerciseCalories[i];
                    final isTimed = ex.type == ExerciseExecutionType.timed;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7043).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFFFF7043),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: const TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    isTimed ? '${ex.value} detik' : '${ex.value} reps',
                                    style: const TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '~$cal kkal',
                              style: const TextStyle(
                                color: Color(0xFFFF7043),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 28),
                _ActionButton(
                  label: 'KEMBALI KE MENU',
                  color: widget.themeColor,
                  isLoading: _isSaving,
                  onTap: () async {
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

                    widget.onDone();
                  },
                ),
              ],
            ),
          ),
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
          style: const TextStyle(color: Color(0xFF6C757D), fontSize: 12),
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
