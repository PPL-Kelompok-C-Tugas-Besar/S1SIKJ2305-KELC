import 'package:flutter/material.dart';
import '../../utils/palette.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  String _location = 'Gym';
  String _type     = 'Upper Body';

  List<Workout> _workouts = [];
  Set<String> _savedWorkoutIds = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedLocation = 'all';
  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  String _selectedSaved = 'all';

  static const _locations = [
    _FilterOption(label: 'All', value: 'all'),
    _FilterOption(label: 'Home', value: 'home'),
    _FilterOption(label: 'Gym', value: 'gym'),
    _FilterOption(label: 'Anywhere', value: 'anywhere'),
  ];

  static const _categories = [
    _FilterOption(label: 'All', value: 'all'),
    _FilterOption(label: 'Workout', value: 'workout'),
    _FilterOption(label: 'Warmup', value: 'warmup'),
  ];

  static const _difficulties = [
    _FilterOption(label: 'All', value: 'all'),
    _FilterOption(label: 'Beginner', value: 'beginner'),
    _FilterOption(label: 'Intermediate', value: 'intermediate'),
    _FilterOption(label: 'Advanced', value: 'advanced'),
  ];

  static const _savedOptions = [
    _FilterOption(label: 'All', value: 'all'),
    _FilterOption(label: 'Saved', value: 'saved'),
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final workouts = await _workoutService.getWorkouts(
        location: _selectedLocation,
        category: _selectedCategory,
      );
      final savedWorkoutIds = await _workoutService.getSavedWorkoutIds();
      final workoutsWithSavedState = workouts
          .map(
            (workout) => workout.copyWith(
              isSaved: savedWorkoutIds.contains(workout.id),
            ),
          )
          .toList();

      // Filter by difficulty if not 'all'
      final difficultyFilteredWorkouts = _selectedDifficulty == 'all'
          ? workoutsWithSavedState
          : workoutsWithSavedState
              .where(
                (workout) =>
                    workout.difficulty.toLowerCase() == _selectedDifficulty,
              )
              .toList();

      final filteredWorkouts = _selectedSaved == 'saved'
          ? difficultyFilteredWorkouts
              .where((workout) => workout.isSaved)
              .toList()
          : difficultyFilteredWorkouts;

      if (!mounted) return;
      setState(() {
        _workouts = filteredWorkouts;
        _savedWorkoutIds = savedWorkoutIds;
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

  void _setLocation(String value) {
    if (_selectedLocation == value) return;
    setState(() => _selectedLocation = value);
    _loadWorkouts();
  }

  void _setCategory(String value) {
    if (_selectedCategory == value) return;
    setState(() => _selectedCategory = value);
    _loadWorkouts();
  }

  void _setDifficulty(String value) {
    if (_selectedDifficulty == value) return;
    setState(() => _selectedDifficulty = value);
    _loadWorkouts();
  }

  void _setSaved(String value) {
    if (_selectedSaved == value) return;
    setState(() => _selectedSaved = value);
    _loadWorkouts();
  }

  Future<void> _toggleSaved(Workout workout) async {
    final shouldSave = !workout.isSaved;
    setState(() {
      if (shouldSave) {
        _savedWorkoutIds.add(workout.id);
      } else {
        _savedWorkoutIds.remove(workout.id);
      }

      _workouts = _workouts
          .map(
            (item) => item.id == workout.id
                ? item.copyWith(isSaved: shouldSave)
                : item,
          )
          .where((item) => _selectedSaved != 'saved' || item.isSaved)
          .toList();
    });

    final ok = shouldSave
        ? await _workoutService.saveWorkout(workout.id)
        : await _workoutService.unsaveWorkout(workout.id);

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update saved workout')),
      );
      _loadWorkouts();
    }
  }

  void _openWorkout(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseSelectionPage(
          workoutId: workout.id,
          location: workout.locationType,
          workoutType: workout.title,
          workout: workout, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: kAccent,
        backgroundColor: kCard,
        onRefresh: _loadWorkouts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Train',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'What do you want to focus on today?',
                      style: TextStyle(color: kTextMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    _FilterSection(
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                      options: _locations,
                      selected: _selectedLocation,
                      onSelect: _setLocation,
                    ),
                    const SizedBox(height: 18),
                    _FilterSection(
                      label: 'Category',
                      icon: Icons.category_outlined,
                      options: _categories,
                      selected: _selectedCategory,
                      onSelect: _setCategory,
                    ),
                    const SizedBox(height: 18),
                    _FilterSection(
                      label: 'Difficulty',
                      icon: Icons.trending_up_outlined,
                      options: _difficulties,
                      selected: _selectedDifficulty,
                      onSelect: _setDifficulty,
                    ),
                    const SizedBox(height: 18),
                    _FilterSection(
                      label: 'Saved',
                      icon: Icons.bookmark_border_rounded,
                      options: _savedOptions,
                      selected: _selectedSaved,
                      onSelect: _setSaved,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Workouts',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isLoading)
                          Text(
                            '${_workouts.length} found',
                            style: const TextStyle(
                              color: kTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                child: const Text('Start Workout',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
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
                  title: 'Failed to load workouts',
                  message: 'Check the server connection and try again.',
                  actionLabel: 'Retry',
                  onAction: _loadWorkouts,
                ),
              )
            else if (_workouts.isEmpty)
              const SliverFillRemaining(
                child: _MessageState(
                  icon: Icons.fitness_center,
                  title: 'No workouts found',
                  message: 'No database workouts match this filter.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final workout = _workouts[index];
                      return _WorkoutCard(
                        workout: workout,
                        imageUrl: _imageForWorkout(workout),
                        onTap: () => _openWorkout(workout),
                        onToggleSaved: () => _toggleSaved(workout),
                      );
                    },
                    childCount: _workouts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Selector section ──────────────────────────────────────────────────────────
class _SelectorSection extends StatelessWidget {
  const _SelectorSection({
    required this.label,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String        label;
  final IconData      icon;
  final List<String>  options;
  final String        selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kAccent, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: kTextMuted,
                    fontSize: 13,
                    letterSpacing: 0.8)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options
              .map((opt) => _OptionChip(
                    label: opt,
                    isSelected: opt == selected,
                    onTap: () => onSelect(opt),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ── Option chip ───────────────────────────────────────────────────────────────
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kAccent : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      isSelected ? kBg : kTextPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize:   14,
          ),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.imageUrl,
    required this.onTap,
    required this.onToggleSaved,
  });

  final Workout workout;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 244,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(138),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MetaPill(
                    icon: Icons.location_on_outlined,
                    label: _capitalize(workout.locationType),
                    color: kAccent,
                  ),
                  const SizedBox(width: 8),
                  _MetaPill(
                    icon: Icons.category_outlined,
                    label: _capitalize(workout.category),
                    color: const Color(0xFF6BE5FF),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onToggleSaved,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(96),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(
                        workout.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: workout.isSaved ? kAccent : kTextPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                workout.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                workout.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${_capitalize(workout.difficulty)} - ${workout.durationMinutes ?? 0} min - ${workout.exerciseCount} exercises - ${workout.caloriesBurned?.toStringAsFixed(0) ?? '0'} kcal',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: kBg,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF6BE5FF),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Equipment: ${workout.equipmentSummary.isEmpty ? 'none' : workout.equipmentSummary}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return '-';
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Selection',
              style: TextStyle(
                  color: kTextMuted, fontSize: 12, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryChip(icon: Icons.location_on_outlined, label: location),
              const SizedBox(width: 12),
              _SummaryChip(icon: Icons.fitness_center,       label: type),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kAccent, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color:      kAccent,
                  fontWeight: FontWeight.w600,
                  fontSize:   13)),
        ],
      ),
    );
  }
}