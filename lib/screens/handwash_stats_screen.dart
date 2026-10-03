import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class HandwashStatsScreen extends StatefulWidget {
  const HandwashStatsScreen({super.key, required this.userId});
  final int userId;

  @override
  State<HandwashStatsScreen> createState() => _HandwashStatsScreenState();
}

class _HandwashStatsScreenState extends State<HandwashStatsScreen> {
  static const _stepLabels = [
    '1. Palmă pe palmă',
    '2. Dosul mâinilor',
    '3. Între degete',
    '4. Dosul degetelor',
    '5. Police (Degetul mare)',
    '6. Unghii / Palmă',
    '7. Încheieturi',
  ];

  bool _loading = true;
  int _total = 0;
  List<double> _percentages = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final surveys = await DatabaseHelper.instance.getHandwashSurveysForUser(widget.userId);
    final total = surveys.length;

    final percentages = List<double>.filled(7, 0);
    if (total > 0) {
      for (int i = 1; i <= 7; i++) {
        final trueCount = surveys.where((s) => s['step$i'] == 1).length;
        percentages[i - 1] = double.parse(((trueCount / total) * 100).toStringAsFixed(1));
      }
    }

    setState(() {
      _total = total;
      _percentages = percentages;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conformitate Tehnică Spălare')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bazat pe $_total evaluări înregistrate.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (_total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Nicio evaluare înregistrată încă.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              for (int i = 0; i < 7; i++) _buildStatRow(_stepLabels[i], _percentages[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double percentage) {
    final isGood = percentage >= 80;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 15,
              backgroundColor: Colors.grey.shade300,
              color: isGood ? const Color(0xFF4CAF50) : const Color(0xFFF39C12),
            ),
          ),
        ],
      ),
    );
  }
}