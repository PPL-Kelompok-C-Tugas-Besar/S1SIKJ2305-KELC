import 'package:flutter/material.dart';

class ExerciseCatalogueScreen extends StatefulWidget {
  const ExerciseCatalogueScreen({super.key});

  @override
  _ExerciseCatalogueScreenState createState() =>
      _ExerciseCatalogueScreenState();
}

class _ExerciseCatalogueScreenState extends State<ExerciseCatalogueScreen> {
  String _selectedLocation = 'Gym';
  String _selectedType = 'Upper body';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Train', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Personalize your\nworkout regime:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildDropdown(
              'Workout location',
              _selectedLocation,
              ['Gym', 'Home'],
              (val) => setState(() => _selectedLocation = val!),
            ),
            const SizedBox(height: 24),
            _buildDropdown(
              'Workout type',
              _selectedType,
              ['Upper body', 'Lower body', 'Full body'],
              (val) => setState(() => _selectedType = val!),
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle start action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black),
          ...items.map((item) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => onChanged(item),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: value == item
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                if (item != items.last)
                  const Divider(height: 1, color: Colors.black),
              ],
            );
          }),
        ],
      ),
    );
  }
}