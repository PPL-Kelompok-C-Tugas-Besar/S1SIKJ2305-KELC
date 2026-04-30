import 'dart:async';
import 'package:flutter/material.dart';

class AlifWorkoutScreen extends StatefulWidget {
  const AlifWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<AlifWorkoutScreen> createState() => _AlifWorkoutScreenState();
}

enum WorkoutState { inputDuration, exercising, inputRest, restTime, complete }

class _AlifWorkoutScreenState extends State<AlifWorkoutScreen> {
  WorkoutState _currentState = WorkoutState.inputDuration;
  
  final TextEditingController _workDurationController = TextEditingController(text: '30');
  final TextEditingController _restDurationController = TextEditingController(text: '20');
  final TextEditingController _repsController = TextEditingController(text: '12');

  int _currentIndex = 0;
  
  final List<Map<String, dynamic>> _workoutList = [
    {'name': 'Jumping Jacks', 'gif': 'assets/gifs/jumping_jack.gif', 'defaultReps': '20'}, 
    {'name': 'Push Up', 'gif': 'assets/gifs/pushups.gif', 'defaultReps': '15'}, 
    {'name': 'Air Squat', 'gif': 'assets/gifs/squat.gif', 'defaultReps': '20'},
    {'name': 'Fitness Legs', 'gif': 'assets/gifs/fitness_legs.gif', 'defaultReps': '15'},
    {'name': 'Plank', 'gif': 'assets/gifs/plank.gif', 'defaultReps': '1'},
    {'name': 'Mountain Climbers', 'gif': 'assets/gifs/mountain_climb.gif', 'defaultReps': '30'}, 
    {'name': 'Dumbbell Flyes', 'gif': 'assets/gifs/chest_fly_dumbells.gif', 'defaultReps': '12'}, 
  ];

  int _timerSeconds = 0;
  String _currentReps = '0';
  Timer? _timer;
  bool _isPaused = false;

  // State tambahan buat efek tombol 3D Lif
  bool _is3DPressed = false;

  void _startWorkout() {
    int duration = int.tryParse(_workDurationController.text) ?? 30;
    setState(() {
      _timerSeconds = duration;
      _currentReps = _repsController.text;
      _currentState = WorkoutState.exercising;
      _isPaused = false;
    });
    _runTimer();
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
        } else {
          _timer?.cancel();
          _checkNextPhase();
        }
      }
    });
  }

  void _checkNextPhase() {
    if (_currentState == WorkoutState.exercising) {
      if (_currentIndex < _workoutList.length - 1) {
        setState(() => _currentState = WorkoutState.inputRest);
      } else {
        setState(() => _currentState = WorkoutState.complete);
      }
    } else if (_currentState == WorkoutState.restTime) {
      _goToNextExercise();
    }
  }

  void _startRest() {
    int rest = int.tryParse(_restDurationController.text) ?? 20;
    setState(() {
      _timerSeconds = rest;
      _currentState = WorkoutState.restTime;
    });
    _runTimer();
  }

  void _goToNextExercise() {
    _timer?.cancel();
    setState(() {
      _currentIndex++;
      _repsController.text = _workoutList[_currentIndex]['defaultReps'];
      _currentState = WorkoutState.inputDuration;
    });
  }

  void _backToSettings() {
    _timer?.cancel();
    setState(() {
      _currentState = WorkoutState.inputDuration;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workDurationController.dispose();
    _restDurationController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  // WIDGET HELPER BUAT TOMBOL 3D BIAR GAK REPOT COPY-PASTE LIF
  Widget _build3DButton({
    required String text, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _is3DPressed = true),
      onTapUp: (_) => setState(() => _is3DPressed = false),
      onTapCancel: () => setState(() => _is3DPressed = false),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: _is3DPressed
              ? null // Mendam pas ditekan
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showBackButton = _currentState == WorkoutState.exercising || 
                         _currentState == WorkoutState.restTime || 
                         _currentState == WorkoutState.inputRest;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('GYMBRO', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: _backToSettings,
            )
          : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case WorkoutState.inputDuration: return _inputUI();
      case WorkoutState.exercising: return _exerciseUI();
      case WorkoutState.inputRest: return _inputRestUI();
      case WorkoutState.restTime: return _restUI();
      case WorkoutState.complete: return _completeUI();
    }
  }

  Widget _inputUI() {
    final current = _workoutList[_currentIndex];
    return Column(
      children: [
        const Text("SET YOUR TARGET", style: TextStyle(color: Colors.grey)),
        Text(current['name'], style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _mediaDisplay(current['gif']),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _inputFieldCol("Duration (s)", _workDurationController),
            _inputFieldCol("Reps", _repsController),
          ],
        ),
        const SizedBox(height: 40),
        _build3DButton(
          text: "START WORKOUT", 
          color: Colors.orangeAccent, 
          onTap: _startWorkout
        ),
      ],
    );
  }

  Widget _exerciseUI() {
    return Column(
      children: [
        _mediaDisplay(_workoutList[_currentIndex]['gif']),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(10)),
          child: Text("DO IT: $_currentReps REPS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Text('$_timerSeconds', style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        IconButton(
          icon: Icon(_isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled, size: 80, color: Colors.orangeAccent),
          onPressed: () => setState(() => _isPaused = !_isPaused),
        ),
      ],
    );
  }

  Widget _inputRestUI() {
    return Column(
      children: [
        const Icon(Icons.timer_outlined, color: Colors.greenAccent, size: 80),
        const SizedBox(height: 20),
        const Text("SET REST DURATION", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _customTextField(_restDurationController),
        const SizedBox(height: 40),
        _build3DButton(
          text: "START REST", 
          color: Colors.greenAccent, 
          onTap: _startRest
        ),
      ],
    );
  }

  Widget _restUI() {
    return Column(
      children: [
        const Text("RESTING...", style: TextStyle(color: Colors.greenAccent, fontSize: 24)),
        const SizedBox(height: 10),
        Text('$_timerSeconds', style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _build3DButton(
          text: "SKIP REST", 
          color: Colors.orangeAccent, 
          onTap: _goToNextExercise
        ),
      ],
    );
  }

  Widget _completeUI() {
    return Column(
      children: [
        const Icon(Icons.stars, color: Colors.amber, size: 100),
        const Text("WELL DONE!", style: TextStyle(color: Colors.white, fontSize: 32)),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("FINISH")),
      ],
    );
  }

  Widget _inputFieldCol(String label, TextEditingController controller) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        _customTextField(controller),
      ],
    );
  }

  Widget _mediaDisplay(String path) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(path, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.videocam_off, color: Colors.red, size: 50))),
      ),
    );
  }

  Widget _customTextField(TextEditingController controller) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 24),
        decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent))),
      ),
    );
  }
}