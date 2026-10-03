import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../theme/app_theme.dart';

class _StepStat {
  int total = 0;
  int correct = 0;
  int fail = 0;
  double percent = 0;
}

class Page3StatsScreen extends StatefulWidget {
  const Page3StatsScreen({super.key, required this.userId, required this.isAdmin});
  final int userId;
  final bool isAdmin;

  @override
  State<Page3StatsScreen> createState() => _Page3StatsScreenState();
}

class _Page3StatsScreenState extends State<Page3StatsScreen> {
  int _days = 365;
  final _customDaysController = TextEditingController(text: '365');

  bool _loading = true;
  int _totalRecordings = 0;
  double _overallPercent = 0;
  bool _goodHospital = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  Map<int, _StepStat> _stepStats = {
    for (int i = 1; i <= 5; i++) i: _StepStat(),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    _endDate = DateTime.now();
    _startDate = _endDate.subtract(Duration(days: _days - 1));

    final userFilter = widget.isAdmin ? null : widget.userId;
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

    final totalRecordings = await DatabaseHelper.instance.getObservationCountInRange(
      startDate: startStr,
      endDate: endStr,
      userId: userFilter,
    );

    final stepRows = await DatabaseHelper.instance.getMandatoryFinalSteps(
      startDate: startStr,
      endDate: endStr,
      userId: userFilter,
    );

    // Same aggregation shape as the original Python loop: walk every
    // mandatory step row once, bucket it by step_number, count C vs. fail.
    final stats = {for (int i = 1; i <= 5; i++) i: _StepStat()};
    for (final row in stepRows) {
      final stepNumber = row['step_number'] as int;
      final stat = stats[stepNumber];
      if (stat == null) continue; // ignore anything outside 1-5, just in case
      stat.total += 1;
      if (row['rating'] == 'C') {
        stat.correct += 1;
      } else {
        stat.fail += 1; // includes 'I', 'N', and unanswered (null) ratings
      }
    }

    final percentages = <double>[];
    for (final stat in stats.values) {
      if (stat.total > 0) {
        stat.percent = double.parse(((stat.correct / stat.total) * 100).toStringAsFixed(1));
        percentages.add(stat.percent);
      }
    }

    final overallPercent = percentages.isEmpty
        ? 0.0
        : double.parse(
      (percentages.reduce((a, b) => a + b) / percentages.length).toStringAsFixed(1),
    );

    setState(() {
      _totalRecordings = totalRecordings;
      _stepStats = stats;
      _overallPercent = overallPercent;
      _goodHospital = overallPercent >= 80.0;
      _loading = false;
    });
  }

  void _setPreset(int days) {
    setState(() {
      _days = days;
      _customDaysController.text = days.toString();
    });
    _loadData();
  }

  void _applyCustomDays() {
    final parsed = int.tryParse(_customDaysController.text);
    if (parsed == null || parsed < 1 || parsed > 3650) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduceți un număr de zile între 1 și 3650')),
      );
      return;
    }
    setState(() => _days = parsed);
    _loadData();
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistica pașilor de pregătire a mâinii')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPeriodFilter(),
            const SizedBox(height: 16),
            Text(
              _days == 365
                  ? 'Ultimul An: ${_fmt(_startDate)} - ${_fmt(_endDate)}'
                  : 'Ultimele $_days de zile: ${_fmt(_startDate)} - ${_fmt(_endDate)}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildBarChartCard(),
            const SizedBox(height: 16),
            _buildDetailsTable(),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Widget _buildPeriodFilter() {
    return appCard(
      child: Column(
        children: [
          Text('Filtrează Perioada', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(label: const Text('7 Zile'), selected: _days == 7, onSelected: (_) => _setPreset(7)),
              ChoiceChip(label: const Text('30 Zile'), selected: _days == 30, onSelected: (_) => _setPreset(30)),
              ChoiceChip(label: const Text('90 Zile'), selected: _days == 90, onSelected: (_) => _setPreset(90)),
              ChoiceChip(label: const Text('1 An'), selected: _days == 365, onSelected: (_) => _setPreset(365)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Nr. zile:'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _customDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _applyCustomDays, child: const Text('Aplică')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return appCard(
      child: Column(
        children: [
          Text('Rezumat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('$_totalRecordings', style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Total înregistrări'),
                ],
              ),
              Column(
                children: [
                  Text('$_overallPercent%', style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Scor general'),
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(_goodHospital ? '✅ Bun (≥ 80%)' : '⚠ Sub 80%'),
                    backgroundColor: _goodHospital ? AppColors.goodGreenBg : AppColors.warnOrangeBg,
                    side: BorderSide(
                      color: _goodHospital ? AppColors.goodGreen : AppColors.warnOrange,
                      width: 2,
                    ),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return appCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Complianța Momentelor', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          for (int step = 1; step <= 5; step++) _buildBarRow(step),
        ],
      ),
    );
  }

  Widget _buildBarRow(int step) {
    final percent = _stepStats[step]!.percent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text('Moment $step')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderBlue, width: 2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 14,
                  backgroundColor: const Color(0xFFE6F1FF),
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 48, child: Text('$percent%', textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildDetailsTable() {
    return appCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Detalii Momente', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Moment')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Corect')),
                DataColumn(label: Text('Eșuat')),
                DataColumn(label: Text('Rată succes')),
              ],
              rows: [
                for (int step = 1; step <= 5; step++)
                  DataRow(cells: [
                    DataCell(Text('$step')),
                    DataCell(Text('${_stepStats[step]!.total}')),
                    DataCell(Text('${_stepStats[step]!.correct}')),
                    DataCell(Text('${_stepStats[step]!.fail}')),
                    DataCell(Text('${_stepStats[step]!.percent}%')),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}