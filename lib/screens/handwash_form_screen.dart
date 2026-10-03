import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../widgets/choice_group.dart';

class HandwashFormScreen extends StatefulWidget {
  const HandwashFormScreen({super.key, required this.userId});
  final int userId;

  @override
  State<HandwashFormScreen> createState() => _HandwashFormScreenState();
}

class _HandwashFormScreenState extends State<HandwashFormScreen> {
  static const _stepLabels = [
    '1. Palmă pe palmă',
    '2. Dosul mâinilor',
    '3. Între degete',
    '4. Dosul degetelor',
    '5. Police (Degetul mare)',
    '6. Unghii / Palmă',
    '7. Încheieturi',
  ];

  final Map<String, String?> _answers = {
    for (int i = 1; i <= 7; i++) 'step$i': null,
  };

  DateTime _selectedDate = DateTime.now();

  bool _submitting = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    for (int i = 1; i <= 7; i++) {
      if (_answers['step$i'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vă rugăm să selectați o opțiune pentru Pasul $i')),
        );
        return;
      }
    }

    setState(() => _submitting = true);

    final boolSteps = {
      for (final entry in _answers.entries) entry.key: entry.value == 'true',
    };

    await DatabaseHelper.instance.createHandwashSurvey(
      userId: widget.userId,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      steps: boolSteps,
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evaluare salvată')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluare Tehnica Spălare (7 Pași)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Data Evaluării',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _pickDate,
              child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
            ),
            const Divider(height: 32),
            for (int i = 1; i <= 7; i++)
              ChoiceGroup(
                label: _stepLabels[i - 1],
                options: const {'Da': 'true', 'Nu': 'false'},
                selected: _answers['step$i'],
                onSelected: (v) => setState(() => _answers['step$i'] = v),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Salvează Evaluarea'),
            ),
          ],
        ),
      ),
    );
  }
}