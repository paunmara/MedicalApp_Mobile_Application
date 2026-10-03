import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../widgets/choice_group.dart';
import 'observation_page3_screen.dart';

class ObservationPage2Screen extends StatefulWidget {
  const ObservationPage2Screen({super.key, required this.observationId});
  final int observationId;

  @override
  State<ObservationPage2Screen> createState() => _ObservationPage2ScreenState();
}

class _ObservationPage2ScreenState extends State<ObservationPage2Screen> {
  String? _apaCurenta;
  String? _sapunLichid;
  String? _prosopHartie;
  String? _dezinfectant;
  String? _pictograme;
  String? _pregatireMaini;

  bool _submitting = false;

  bool get _allAnswered =>
      _apaCurenta != null &&
          _sapunLichid != null &&
          _prosopHartie != null &&
          _dezinfectant != null &&
          _pictograme != null &&
          _pregatireMaini != null;

  Future<void> _submit() async {
    if (!_allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer every question')),
      );
      return;
    }

    setState(() => _submitting = true);

    await DatabaseHelper.instance.createLiveCheck(
      observationId: widget.observationId,
      apaCurenta: _apaCurenta!,
      sapunLichid: _sapunLichid!,
      prosopHartie: _prosopHartie!,
      dezinfectant: _dezinfectant!,
      pictograme: _pictograme!,
      pregatireMaini: _pregatireMaini!,
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObservationPage3Screen(observationId: widget.observationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observație - Secțiunea 2')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChoiceGroup(
              label: 'Apă Curentă',
              options: const {'Da': 'Da', 'Nu': 'Nu'},
              selected: _apaCurenta,
              onSelected: (v) => setState(() => _apaCurenta = v),
            ),
            ChoiceGroup(
              label: 'Săpun Lichid',
              options: const {'Da': 'Da', 'Nu': 'Nu'},
              selected: _sapunLichid,
              onSelected: (v) => setState(() => _sapunLichid = v),
            ),
            ChoiceGroup(
              label: 'Prosoape de Hârtie',
              options: const {'Da': 'Da', 'Nu': 'Nu'},
              selected: _prosopHartie,
              onSelected: (v) => setState(() => _prosopHartie = v),
            ),
            ChoiceGroup(
              label: 'Dezinfectant',
              options: const {'Da': 'Da', 'Nu': 'Nu'},
              selected: _dezinfectant,
              onSelected: (v) => setState(() => _dezinfectant = v),
            ),
            ChoiceGroup(
              label: 'Pictograme',
              options: const {'Da': 'Da', 'Nu': 'Nu'},
              selected: _pictograme,
              onSelected: (v) => setState(() => _pictograme = v),
            ),
            ChoiceGroup(
              label: 'Pregătirea Mâinilor',
              options: const {
                'Unghii': 'Unghii',
                'Lac': 'Lac',
                'Bijuterii': 'Bijuterii',
                'Nimic': 'Nimic',
              },
              selected: _pregatireMaini,
              onSelected: (v) => setState(() => _pregatireMaini = v),
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
                  : const Text('Continuă'),
            ),
          ],
        ),
      ),
    );
  }
}