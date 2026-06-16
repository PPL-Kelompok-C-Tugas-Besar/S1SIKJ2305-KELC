import 'package:flutter/material.dart';
import '../../utils/palette.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _errorMessage;
  
  // Form data
  String _selectedGender = '';
  int _age = 25;
  double _height = 170.0;
  double _currentWeight = 70.0;
  String _activityLevel = '';
  String _dietGoal = '';
  final double _targetWeight = 65.0;
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final List<String> _genders = ['male', 'female'];
  final List<String> _dietGoals = ['cutting', 'maintenance', 'bulking'];
  final List<Map<String, String>> _activities = [
    {'value': 'sedentary', 'label': 'Sangat Ringan (Jarang olahraga)'},
    {'value': 'light', 'label': 'Ringan (1-3 hari/minggu)'},
    {'value': 'moderate', 'label': 'Sedang (3-5 hari/minggu)'},
    {'value': 'active', 'label': 'Berat (6-7 hari/minggu)'},
    {'value': 'very_active', 'label': 'Sangat Berat (Pekerjaan fisik)'},
  ];

  @override
  void initState() {
    super.initState();
    _weightController.text = _currentWeight.toStringAsFixed(1);
    _heightController.text = _height.toStringAsFixed(1);
    _ageController.text = _age.toString();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    setState(() => _errorMessage = null);

    if (_currentPage == 0) {
      if (_selectedGender.isEmpty) {
        setState(() => _errorMessage = 'Mohon pilih jenis kelamin Anda');
        return false;
      }
      return true;
    }
    
    if (_currentPage == 1) {
      final val = int.tryParse(_ageController.text);
      if (val == null) {
        setState(() => _errorMessage = 'Mohon masukkan angka yang valid');
        return false;
      }
      if (val < 10 || val > 100) {
        setState(() => _errorMessage = 'Umur harus antara 10 sampai 100 tahun');
        return false;
      }
      _age = val;
      return true;
    }
    
    if (_currentPage == 2) {
      final val = double.tryParse(_heightController.text);
      if (val == null) {
        setState(() => _errorMessage = 'Mohon masukkan angka yang valid');
        return false;
      }
      if (val < 100 || val > 250) {
        setState(() => _errorMessage = 'Tinggi harus antara 100 sampai 250 cm');
        return false;
      }
      _height = val;
      return true;
    }
    
    if (_currentPage == 3) {
      final val = double.tryParse(_weightController.text);
      if (val == null) {
        setState(() => _errorMessage = 'Mohon masukkan angka yang valid');
        return false;
      }
      if (val < 30 || val > 200) {
        setState(() => _errorMessage = 'Berat harus antara 30 sampai 200 kg');
        return false;
      }
      _currentWeight = val;
      return true;
    }
    
    if (_currentPage == 4) {
      if (_activityLevel.isEmpty) {
        setState(() => _errorMessage = 'Mohon pilih tingkat aktivitas Anda');
        return false;
      }
      return true;
    }

    if (_currentPage == 5) {
      if (_dietGoal.isEmpty) {
        setState(() => _errorMessage = 'Mohon pilih tujuan diet Anda');
        return false;
      }
      return true;
    }
    return true;
  }

  void _nextPage() {
    if (_canProceed() && _currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    
    final onboardingData = {
      'gender': _selectedGender,
      'age': _age,
      'height': _height,
      'currentWeight': _currentWeight,
      'targetWeight': _targetWeight,
      'activityLevel': _activityLevel,
      'dietGoal': _dietGoal,
      'goals': [_dietGoal], 
      'onboardingCompleted': true,
    };
    
    final success = await authProvider.completeOnboarding(onboardingData);
    
    if (success && mounted) {
      final calorieTarget = authProvider.user?.dailyCalorieTarget;
      
      if (calorieTarget != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: kCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Profil Tersimpan!', style: TextStyle(color: kTextPrimary)),
            content: Text(
              'Berdasarkan usia, berat, tinggi, aktivitas, dan tujuan diet Anda, sistem merekomendasikan target konsumsi harian sebesar:\n\n$calorieTarget kcal / hari.',
              style: const TextStyle(color: kTextMuted, fontSize: 16),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pushReplacementNamed(context, '/home'); 
                },
                style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
                child: const Text('Lanjut ke Beranda'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    icon: const Icon(Icons.arrow_back, color: kTextPrimary),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 7,
                      backgroundColor: kCard,
                      valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _errorMessage = null;
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGenderPage(),
                  _buildAgePage(),
                  _buildHeightPage(),
                  _buildWeightPage(),
                  _buildActivityLevelPage(),
                  _buildDietGoalPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(color: kAccent),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage == 6 ? _completeOnboarding : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: kBg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: kCard,
                        disabledForegroundColor: kTextMuted,
                      ),
                      child: Text(_currentPage == 6 ? 'Complete Setup' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your gender?',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us calculate your daily calorie target.',
            style: TextStyle(color: kTextMuted, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ..._genders.map((gender) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectionOption(
              label: gender[0].toUpperCase() + gender.substring(1),
              icon: Icons.person,
              isSelected: _selectedGender == gender,
              onTap: () {
                setState(() {
                  _selectedGender = gender;
                  _errorMessage = null;
                });
              },
            ),
          )),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How old are you?',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Age is used to calculate your BMR accurately.', style: TextStyle(color: kTextMuted, fontSize: 16)),
          const SizedBox(height: 32),
          _buildNumberInputContainer(
            controller: _ageController,
            unit: 'years',
            min: 10,
            max: 100,
            currentValue: _age.toDouble(),
            divisions: 90,
            onSliderChanged: (val) {
              setState(() {
                _age = val.toInt();
                _ageController.text = _age.toString();
                _errorMessage = null;
              });
            },
            onTextChanged: (val) {
              final valInt = int.tryParse(val);
              if (valInt != null) {
                setState(() {
                  _age = valInt.clamp(10, 100);
                  _errorMessage = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your height?',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Required for estimating your metabolism.', style: TextStyle(color: kTextMuted, fontSize: 16)),
          const SizedBox(height: 32),
          _buildNumberInputContainer(
            controller: _heightController,
            unit: 'cm',
            min: 100,
            max: 250,
            currentValue: _height,
            divisions: 150,
            onSliderChanged: (val) {
              setState(() {
                _height = val;
                _heightController.text = _height.toStringAsFixed(1);
                _errorMessage = null;
              });
            },
            onTextChanged: (val) {
              final valDouble = double.tryParse(val);
              if (valDouble != null) {
                setState(() {
                  _height = valDouble.clamp(100, 250);
                  _errorMessage = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your current weight?',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This helps us track your progress.', style: TextStyle(color: kTextMuted, fontSize: 16)),
          const SizedBox(height: 32),
          _buildNumberInputContainer(
            controller: _weightController,
            unit: 'kg',
            min: 30,
            max: 200,
            currentValue: _currentWeight,
            divisions: 170,
            onSliderChanged: (val) {
              setState(() {
                _currentWeight = val;
                _weightController.text = _currentWeight.toStringAsFixed(1);
                _errorMessage = null;
              });
            },
            onTextChanged: (val) {
              final weight = double.tryParse(val);
              if (weight != null) {
                setState(() {
                  _currentWeight = weight.clamp(30, 200);
                  _errorMessage = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputContainer({
    required TextEditingController controller,
    required String unit,
    required double min,
    required double max,
    required double currentValue,
    required int divisions,
    required Function(double) onSliderChanged,
    required Function(String) onTextChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _errorMessage != null ? Colors.red.withOpacity(0.5) : Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _errorMessage != null ? Colors.red.withOpacity(0.5) : Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: kTextPrimary, fontSize: 24),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter value',
                      hintStyle: TextStyle(color: kTextMuted),
                    ),
                    onChanged: (val) {
                      setState(() => _errorMessage = null);
                      onTextChanged(val);
                    },
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(color: kTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: kAccent,
            inactiveColor: kCard,
            onChanged: (val) {
              setState(() => _errorMessage = null);
              onSliderChanged(val);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()} $unit', style: const TextStyle(color: kTextMuted, fontSize: 12)),
              Text('${max.toInt()} $unit', style: const TextStyle(color: kTextMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your activity level?',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This helps determine your Total Daily Energy Expenditure (TDEE).', style: TextStyle(color: kTextMuted, fontSize: 16)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SelectionOption(
                    label: activity['label']!,
                    icon: Icons.directions_run,
                    isSelected: _activityLevel == activity['value'],
                    onTap: () {
                      setState(() {
                        _activityLevel = activity['value']!;
                        _errorMessage = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDietGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your diet goal?',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Select whether you want to lose, maintain, or gain weight.', style: TextStyle(color: kTextMuted, fontSize: 16)),
          const SizedBox(height: 32),
          ..._dietGoals.map((goal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectionOption(
              label: goal.toUpperCase(),
              icon: Icons.flag,
              isSelected: _dietGoal == goal,
              onTap: () {
                setState(() {
                  _dietGoal = goal;
                  _errorMessage = null;
                });
              },
            ),
          )),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You\'re all set!',
            style: TextStyle(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Here\'s your profile summary:', style: TextStyle(color: kTextMuted, fontSize: 16)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _SummaryItem(label: 'Gender', value: _selectedGender),
                const Divider(color: Colors.white10),
                _SummaryItem(label: 'Age', value: '$_age years'),
                const Divider(color: Colors.white10),
                _SummaryItem(label: 'Height', value: '$_height cm'),
                const Divider(color: Colors.white10),
                _SummaryItem(label: 'Weight', value: '${_currentWeight.toStringAsFixed(1)} kg'),
                const Divider(color: Colors.white10),
                _SummaryItem(label: 'Activity', value: _activityLevel),
                const Divider(color: Colors.white10),
                _SummaryItem(label: 'Goal', value: _dietGoal),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'We will calculate your daily calorie target automatically based on these physical details.',
            style: TextStyle(color: kTextMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SelectionOption extends StatelessWidget {
  const _SelectionOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? kAccent.withAlpha(31) : kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kAccent : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? kAccent : kTextMuted, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? kAccent : kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: kAccent),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: kTextMuted, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.toUpperCase(),
              style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
