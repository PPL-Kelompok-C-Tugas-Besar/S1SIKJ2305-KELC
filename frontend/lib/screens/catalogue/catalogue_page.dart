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

  static const _locations = ['Gym', 'Home'];
  static const _types     = ['Upper Body', 'Lower Body', 'Full Body'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page title
            const Text('Train',
                style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Personalize your workout regime',
                style: TextStyle(color: kTextMuted, fontSize: 14)),

            const SizedBox(height: 32),

            // ── Location selector
            _SelectorSection(
              label: 'Workout Location',
              icon: Icons.location_on_outlined,
              options: _locations,
              selected: _location,
              onSelect: (v) => setState(() => _location = v),
            ),

            const SizedBox(height: 20),

            // ── Type selector
            _SelectorSection(
              label: 'Workout Type',
              icon: Icons.accessibility_new_rounded,
              options: _types,
              selected: _type,
              onSelect: (v) => setState(() => _type = v),
            ),

            const SizedBox(height: 32),

            // ── Summary card
            _SummaryCard(location: _location, type: _type),

            const SizedBox(height: 32),

            // ── Start button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Workout',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
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

// ── Summary card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.location, required this.type});

  final String location;
  final String type;

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
        color: kAccent.withAlpha(31),
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