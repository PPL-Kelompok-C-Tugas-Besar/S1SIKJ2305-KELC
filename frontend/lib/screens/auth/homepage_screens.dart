import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../models/workout_model.dart';
import '../../services/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/palette.dart';
import '../catalogue/catalogue_page.dart';
import '../history/history_page.dart';
import '../profile/profile_page.dart';
import '../catalogue/workout_detail.dart';

// ─── Root shell – owns the bottom nav ────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    _HomePage(),
    CataloguePage(),
    _PlaceholderPage(label: 'Marketplace'),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: kCard,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kAccent,
          unselectedItemColor: kTextMuted,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center), label: 'Workout'),
            BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined), label: 'Marketplace'),
            BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart_outlined), label: 'Progress'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ─── Home tab ─────────────────────────────────────────────────────────────────
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final user      = context.watch<AuthProvider>().user;
    final firstName = user?.fullName.split(' ').first ?? 'User';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(firstName: firstName),
            const SizedBox(height: 24),
            _DailyStatsRow(),
            const SizedBox(height: 24),
            _WeeklyGoalCard(),
            const SizedBox(height: 32),
            const _SectionTitle(title: 'Popular Goals'),
            const SizedBox(height: 16),
            _GoalList(),
            const SizedBox(height: 32),
            const _SectionTitle(title: 'Recommended Today'),
            const SizedBox(height: 16),
            const _HotWorkoutList(), // Now fetches from DB
            const SizedBox(height: 32),
            const _SectionTitle(title: 'Warm-up & Stretches'),
            const SizedBox(height: 16),
            _WarmUpList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hey, $firstName',
                style: const TextStyle(color: kTextMuted, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Ready to workout?',
                style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            const _StreakBadge(),
            IconButton(
              icon: const Icon(Icons.logout, color: kTextMuted),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department,
              color: Colors.orangeAccent, size: 20),
          SizedBox(width: 4),
          Text('3',
              style: TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

// ── Daily Stats ──────────────────────────────────────────────────────────────
class _DailyStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Calories',
            value: '320',
            unit: 'kcal',
            icon: Icons.local_fire_department,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Time',
            value: '45',
            unit: 'min',
            icon: Icons.timer_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label, value, unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccent.withAlpha(31),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: kTextMuted, fontSize: 12)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value,
                      style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text(unit, style: const TextStyle(color: kTextMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Weekly Goal Card ─────────────────────────────────────────────────────────
class _WeeklyGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int currentWeekday = now.weekday; 
    final DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Weekly Goal',
                  style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('3 of 4 days',
                  style: TextStyle(
                      color: kAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final DateTime date = startOfWeek.add(Duration(days: index));
              final bool isActive = index == (currentWeekday - 1);
              
              return _DayBadge(
                day: dayNames[index],
                date: date.day.toString(),
                isActive: isActive,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({
    required this.day,
    required this.date,
    required this.isActive,
  });

  final String day;
  final String date;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? kAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? null : Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(day,
              style: TextStyle(
                  color: isActive ? kBg : kTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(date,
              style: TextStyle(
                  color: isActive ? kBg : kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {},
          child:
              const Text('See All', style: TextStyle(color: kAccent)),
        ),
      ],
    );
  }
}

// ── Goal list ────────────────────────────────────────────────────────────────
class _GoalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: const [
          _GoalCard(title: 'Weight Loss', icon: Icons.monitor_weight_outlined),
          SizedBox(width: 16),
          _GoalCard(title: 'Muscle Gain', icon: Icons.fitness_center),
          SizedBox(width: 16),
          _GoalCard(title: 'Flexibility', icon: Icons.self_improvement),
          SizedBox(width: 16),
          _GoalCard(title: 'Endurance', icon: Icons.directions_run),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kAccent, size: 28),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Dynamic Workout cards ─────────────────────────────────────────────────────
class _HotWorkoutList extends StatefulWidget {
  const _HotWorkoutList();

  @override
  State<_HotWorkoutList> createState() => _HotWorkoutListState();
}

class _HotWorkoutListState extends State<_HotWorkoutList> {
  late Future<List<Workout>> futureWorkouts;

  @override
  void initState() {
    super.initState();
    futureWorkouts = fetchWorkouts();
  }

  Future<List<Workout>> fetchWorkouts() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/workouts?category=workout'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Workout.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load workouts. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Workout>>(
        future: futureWorkouts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAccent));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load workouts.', style: TextStyle(color: kTextMuted)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workouts available.', style: TextStyle(color: kTextMuted)));
          }

          List<Workout> workouts = snapshot.data!;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: workouts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              
              final String imageUrl = index % 2 == 0
                  ? 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&q=80'
                  : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&q=80';

              return _WorkoutCard(
                title: workout.title,
                level: workout.difficulty[0].toUpperCase() + workout.difficulty.substring(1),
                duration: '${workout.durationMinutes} min',
                imageUrl: imageUrl,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailPage(workout: workout),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WarmUpList extends StatefulWidget {
  @override
  State<_WarmUpList> createState() => _WarmUpListState();
}

class _WarmUpListState extends State<_WarmUpList> {
  late Future<List<Workout>> futureWarmups;

  @override
  void initState() {
    super.initState();
    futureWarmups = fetchWarmups();
  }

  Future<List<Workout>> fetchWarmups() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/workouts?category=warmup'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Workout.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load warmups.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Workout>>(
        future: futureWarmups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAccent));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load warmups.', style: TextStyle(color: kTextMuted)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No warmups available.', style: TextStyle(color: kTextMuted)));
          }

          List<Workout> warmups = snapshot.data!;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: warmups.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final warmup = warmups[index];
              
              final String imageUrl = index % 2 == 0
                  ? 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80'
                  : 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=400&q=80';

              return _WorkoutCard(
                title: warmup.title,
                level: warmup.difficulty[0].toUpperCase() + warmup.difficulty.substring(1),
                duration: '${warmup.durationMinutes} min',
                imageUrl: imageUrl,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailPage(workout: warmup),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.title,
    required this.level,
    required this.duration,
    required this.imageUrl,
    required this.onTap, // Inject callback
  });

  final String title, level, duration, imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(128), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(level,
                      style: const TextStyle(
                          color: kTextPrimary, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text('• $duration',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onTap, // Execute injected callback
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kBg,
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Check',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Placeholder tabs ─────────────────────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label,
          style: const TextStyle(color: kTextMuted, fontSize: 18)),
    );
  }
}

// ─── Admin dashboard ─────────────────────────────────────────────────────────
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Admin: ${user?.fullName ?? 'Admin'}'),
      ),
    );
  }
}