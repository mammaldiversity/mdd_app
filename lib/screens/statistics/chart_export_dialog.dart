import 'package:flutter/material.dart';
import 'package:mdd/services/export.dart';

class ChartExportDialog extends StatefulWidget {
  const ChartExportDialog({
    super.key,
    required this.defaultFileName,
  });

  final String defaultFileName;

  @override
  State<ChartExportDialog> createState() => _ChartExportDialogState();
}

class _ChartExportDialogState extends State<ChartExportDialog> {
  late TextEditingController _filenameController;
  ExportFormat _format = ExportFormat.csv;

  @override
  void initState() {
    super.initState();
    _filenameController = TextEditingController(text: widget.defaultFileName);
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Table Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _filenameController,
            decoration: const InputDecoration(
              labelText: 'Filename',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Format',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Center(
            child: SegmentedButton<ExportFormat>(
              segments: const [
                ButtonSegment(value: ExportFormat.csv, label: Text('CSV')),
                ButtonSegment(value: ExportFormat.tsv, label: Text('TSV')),
                ButtonSegment(value: ExportFormat.json, label: Text('JSON')),
              ],
              selected: {_format},
              onSelectionChanged: (Set<ExportFormat> newSelection) {
                setState(() {
                  _format = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _filenameController.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(
              ExportSettings(fileName: name, format: _format),
            );
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
