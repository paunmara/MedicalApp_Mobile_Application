import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../widgets/choice_group.dart';

class _StepAnswers {
  String? mandatory;
  String? method;
  String? rating;
}

class ObservationPage3Screen extends StatefulWidget {
  const ObservationPage3Screen({super.key, required this.observationId});
  final int observationId;

  @override
  State<ObservationPage3Screen> createState() => _ObservationPage3ScreenState();
}

class _ObservationPage3ScreenState extends State<ObservationPage3Screen> {
  final List<_StepAnswers> _steps = List.generate(5, (_) => _StepAnswers());

  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);

    for (int i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      await DatabaseHelper.instance.createFinalStep(
        observationId: widget.observationId,
        stepNumber: i + 1,
        isMandatory: step.mandatory == 'mandatory',
        method: step.method,
        rating: step.rating,
      );
    }

    setState(() => _submitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observație finalizată')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observație - Secțiunea 3')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < _steps.length; i++) ...[
              Text(
                'Momentul ${i + 1} - A fost aplicat corect?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ChoiceGroup(
                label: 'Aplicare',
                options: const {'Obligatoriu': 'mandatory', 'Opțional': 'optional'},
                selected: _steps[i].mandatory,
                onSelected: (v) => setState(() => _steps[i].mandatory = v),
              ),
              ChoiceGroup(
                label: 'Metodă',
                options: const {'Spălare': 'SPALARE', 'Frecare': 'FRECARE'},
                selected: _steps[i].method,
                onSelected: (v) => setState(() => _steps[i].method = v),
              ),
              ChoiceGroup(
                label: 'Evaluare',
                options: const {'Conform': 'C', 'Incomplet': 'I', 'Neconform': 'N'},
                selected: _steps[i].rating,
                onSelected: (v) => setState(() => _steps[i].rating = v),
              ),
              const Divider(height: 32),
            ],
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Finalizați Observație'),
            ),
          ],
        ),
      ),
    );
  }
}