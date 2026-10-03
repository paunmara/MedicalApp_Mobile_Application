import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import 'observation_page2_screen.dart';

class ObservationPage1Screen extends StatefulWidget {
  const ObservationPage1Screen({super.key, required this.userId});
  final int userId;

  @override
  State<ObservationPage1Screen> createState() => _ObservationPage1ScreenState();
}

class _ObservationPage1ScreenState extends State<ObservationPage1Screen> {
  final _formKey = GlobalKey<FormState>();

  final _professionController = TextEditingController();
  final _sectionController = TextEditingController();
  final _salonController = TextEditingController();

  DateTime? _selectedDate;
  bool _submitting = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vă rugăm să selectați o dată')),
      );
      return;
    }

    setState(() => _submitting = true);

    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final newObservationId = await DatabaseHelper.instance.createObservation(
      userId: widget.userId,
      date: dateString,
      profession: _professionController.text.trim(),
      section: _sectionController.text.trim(),
      salon: _salonController.text.trim(),
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObservationPage2Screen(observationId: newObservationId),
      ),
    );
  }

  @override
  void dispose() {
    _professionController.dispose();
    _sectionController.dispose();
    _salonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observație - Secțiunea 1')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null
                      ? 'Selectează data'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(labelText: 'Profesie'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Câmp obligatoriu' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(labelText: 'Secție'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Câmp obligatoriu' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salonController,
                decoration: const InputDecoration(labelText: 'Salon'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Câmp obligatoriu' : null,
              ),
              const SizedBox(height: 24),
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
      ),
    );
  }
}