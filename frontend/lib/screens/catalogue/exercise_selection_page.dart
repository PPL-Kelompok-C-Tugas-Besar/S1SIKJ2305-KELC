import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';
import '../../utils/palette.dart';

class ExerciseSelectionPage extends StatefulWidget {
  const ExerciseSelectionPage({
    super.key,
    this.workoutId,
    required this.location,
    required this.workoutType,
  });

  final String? workoutId;
  final String location;
  final String workoutType;

  @override
  State<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  final ExerciseService _exerciseService = ExerciseService();
  final TextEditingController _searchController = TextEditingController();

  List<Exercise> _exercises = [];
  final Set<String> _selectedExerciseIds = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  String _selectedEquipment = 'All';
  String _selectedDifficulty = 'All';

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final exercises = await _exerciseService.getExercises(
        workoutId: widget.workoutId,
        location: widget.location,
        workoutType: widget.workoutType,
      );

      if (!mounted) return;
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  List<String> get _equipmentFilters {
    final values = _exercises
        .map((exercise) => exercise.equipmentRequired)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<String> get _difficultyFilters {
    final values = _exercises
        .map((exercise) => exercise.difficulty)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<Exercise> get _filteredExercises {
    final query = _searchQuery.toLowerCase();

    return _exercises.where((exercise) {
      final matchesSearch = query.isEmpty ||
          exercise.name.toLowerCase().contains(query) ||
          exercise.workoutTitle.toLowerCase().contains(query) ||
          exercise.equipmentRequired.toLowerCase().contains(query) ||
          exercise.instructions.toLowerCase().contains(query);

      final matchesEquipment = _selectedEquipment == 'All' ||
          exercise.equipmentRequired == _selectedEquipment;

      final matchesDifficulty = _selectedDifficulty == 'All' ||
          exercise.difficulty == _selectedDifficulty;

      return matchesSearch && matchesEquipment && matchesDifficulty;
    }).toList();
  }

  void _toggleExercise(Exercise exercise) {
    setState(() {
      if (_selectedExerciseIds.contains(exercise.id)) {
        _selectedExerciseIds.remove(exercise.id);
      } else {
        _selectedExerciseIds.add(exercise.id);
      }
    });
  }

  void _confirmSelection() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedExerciseIds.length} exercise selected',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _filteredExercises;

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: _selectedExerciseIds.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: kBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Start ${_selectedExerciseIds.length} Exercises',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kAccent,
          backgroundColor: kCard,
          onRefresh: _loadExercises,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: kTextPrimary,
                            ),
                            tooltip: 'Back',
                          ),
                          const Spacer(),
                          _SelectionBadge(count: _selectedExerciseIds.length),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choose Exercises',
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: Icons.location_on_outlined,
                            label: widget.location,
                          ),
                          _InfoPill(
                            icon: Icons.accessibility_new_rounded,
                            label: widget.workoutType,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SearchField(controller: _searchController),
                      const SizedBox(height: 20),
                      _FilterSection(
                        title: 'Equipment',
                        options: _equipmentFilters,
                        selected: _selectedEquipment,
                        onSelected: (value) {
                          setState(() => _selectedEquipment = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _FilterSection(
                        title: 'Difficulty',
                        options: _difficultyFilters,
                        selected: _selectedDifficulty,
                        onSelected: (value) {
                          setState(() => _selectedDifficulty = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: kAccent),
                  ),
                )
              else if (_hasError)
                SliverFillRemaining(
                  child: _MessageState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Failed to load exercises',
                    message: 'Check the server connection and try again.',
                    actionLabel: 'Retry',
                    onAction: _loadExercises,
                  ),
                )
              else if (_exercises.isEmpty)
                const SliverFillRemaining(
                  child: _MessageState(
                    icon: Icons.fitness_center,
                    title: 'No exercises found',
                    message: 'No database exercises match this workout option.',
                  ),
                )
              else if (filteredExercises.isEmpty)
                const SliverFillRemaining(
                  child: _MessageState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: 'Try a different search or filter.',
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    _selectedExerciseIds.isEmpty ? 24 : 96,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final exercise = filteredExercises[index];
                        return _ExerciseCard(
                          exercise: exercise,
                          isSelected:
                              _selectedExerciseIds.contains(exercise.id),
                          onTap: () => _toggleExercise(exercise),
                        );
                      },
                      childCount: filteredExercises.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: count == 0 ? kCard : kAccent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: count == 0 ? Colors.white10 : kAccent),
      ),
      child: Text(
        '$count selected',
        style: TextStyle(
          color: count == 0 ? kTextMuted : kBg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kAccent, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: kTextPrimary),
      decoration: InputDecoration(
        hintText: 'Search exercises',
        hintStyle: const TextStyle(color: kTextMuted),
        prefixIcon: const Icon(Icons.search_rounded, color: kTextMuted),
        filled: true,
        fillColor: kCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kAccent),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kTextMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selected;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (_) => onSelected(option),
                showCheckmark: false,
                selectedColor: kAccent,
                backgroundColor: kCard,
                side: BorderSide(
                  color: isSelected ? kAccent : Colors.white12,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? kBg : kTextPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: options.length,
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? kAccent : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ExerciseThumb(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name.isEmpty
                              ? 'Untitled Exercise'
                              : exercise.name,
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? kAccent : kTextMuted,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (exercise.workoutTitle.isNotEmpty)
                    Text(
                      exercise.workoutTitle,
                      style: const TextStyle(
                        color: kTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (exercise.workoutTitle.isNotEmpty)
                    const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (exercise.repsOrDuration.isNotEmpty)
                        _ExercisePill(
                          icon: Icons.repeat_rounded,
                          label: exercise.repsOrDuration,
                          color: kAccent,
                        ),
                      if (exercise.equipmentRequired.isNotEmpty)
                        _ExercisePill(
                          icon: Icons.fitness_center,
                          label: exercise.equipmentRequired,
                          color: const Color(0xFF6BE5FF),
                        ),
                      if (exercise.difficulty.isNotEmpty)
                        _ExercisePill(
                          icon: Icons.trending_up_rounded,
                          label: exercise.difficulty,
                          color: const Color(0xFFFFB74D),
                        ),
                      if (exercise.baseCaloriesBurn != null)
                        _ExercisePill(
                          icon: Icons.local_fire_department,
                          label:
                              '${exercise.baseCaloriesBurn!.toStringAsFixed(1)} kcal',
                          color: const Color(0xFFFF7043),
                        ),
                    ],
                  ),
                  if (exercise.instructions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      exercise.instructions,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextMuted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseThumb extends StatelessWidget {
  const _ExerciseThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Icon(Icons.fitness_center, color: kAccent, size: 28),
    );
  }
}

class _ExercisePill extends StatelessWidget {
  const _ExercisePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: Icon(icon, color: kTextMuted, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextMuted,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
