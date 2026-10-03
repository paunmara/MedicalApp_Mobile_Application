import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../services/pdf_service.dart';

class Page2StatsScreen extends StatefulWidget {
  const Page2StatsScreen({super.key, required this.userId, required this.isAdmin});
  final int userId;
  final bool isAdmin;

  @override
  State<Page2StatsScreen> createState() => _Page2StatsScreenState();
}

class _Page2StatsScreenState extends State<Page2StatsScreen> {
  late int _year;
  late int _month;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final startDate = DateTime(_year, _month, 1);
    final endDate = DateTime(_year, _month + 1, 0);

    final rows = await DatabaseHelper.instance.getPage2Stats(
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
      userId: widget.isAdmin ? null : widget.userId,
    );

    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year -= 1;
      } else {
        _month -= 1;
      }
    });
    _loadData();
  }

  void _goToNextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year += 1;
      } else {
        _month += 1;
      }
    });
    _loadData();
  }

  Future<void> _exportPdf() async {
    if (_rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nu există date de exportat pentru această lună')),
      );
      return;
    }

    setState(() => _exportingPdf = true);

    await exportPage2Pdf(
      rows: _rows,
      year: _year,
      month: _month,
      generatedAt: DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
    );

    if (!mounted) return;
    setState(() => _exportingPdf = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificări resurse')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _goToPreviousMonth,
                  tooltip: 'Luna Precedentă',
                ),
                Text('$_month / $_year', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _goToNextMonth,
                  tooltip: 'Luna Următoare',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: OutlinedButton.icon(
              onPressed: _exportingPdf ? null : _exportPdf,
              icon: _exportingPdf
                  ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                ? const Center(child: Text('Nicio observație pentru această lună'))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Dată')),
                    DataColumn(label: Text('Profesie')),
                    DataColumn(label: Text('Secția')),
                    DataColumn(label: Text('Salon')),
                    DataColumn(label: Text('Apă')),
                    DataColumn(label: Text('Săpun')),
                    DataColumn(label: Text('Prosop')),
                    DataColumn(label: Text('Dezinfectant')),
                    DataColumn(label: Text('Pictograme')),
                    DataColumn(label: Text('Mâini')),
                  ],
                  rows: _rows.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['date'] as String)),
                      DataCell(Text(row['profession'] as String)),
                      DataCell(Text(row['section'] as String)),
                      DataCell(Text(row['salon'] as String)),
                      DataCell(Text(row['apa_curenta'] as String)),
                      DataCell(Text(row['sapun_lichid'] as String)),
                      DataCell(Text(row['prosop_hartie'] as String)),
                      DataCell(Text(row['dezinfectant'] as String)),
                      DataCell(Text(row['pictograme'] as String)),
                      DataCell(Text(row['pregatire_maini'] as String)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}