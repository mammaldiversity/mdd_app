import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/data_update_provider.dart';
import 'package:mdd/screens/shared/card.dart';

class DataUpdatePage extends ConsumerWidget {
  const DataUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dataUpdateProvider);
    final isLoading = status.state == UpdateState.downloading ||
        status.state == UpdateState.extracting ||
        status.state == UpdateState.updating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Update'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _DataUpdateSection(
            title: 'Mammal Diversity Database (MDD)',
            description:
                'Download the latest MDD taxonomy data or import it from a local file. This process replaces the current local database.',
            downloadLabel: 'Download MDD.zip',
            importLabel: 'Import local MDD.zip',
            isLoading: isLoading,
            onDownload: () {
              ref.read(dataUpdateProvider.notifier).downloadAndUpdateMdd();
            },
            onImport: () {
              ref.read(dataUpdateProvider.notifier).importLocalMdd();
            },
          ),
          // const SizedBox(height: 24),
          // _DataUpdateSection(
          //   title: 'Mammal Images Library (MIL)',
          //   description:
          //       'Download the latest MIL photo dataset or import it from a local file.',
          //   downloadLabel: 'Download MIL.tar.gz',
          //   importLabel: 'Import local MIL file',
          //   isLoading: isLoading,
          //   onDownload: () {
          //     ref.read(dataUpdateProvider.notifier).downloadAndUpdateMil();
          //   },
          //   onImport: () {
          //     ref.read(dataUpdateProvider.notifier).importLocalMil();
          //   },
          // ),
          // const SizedBox(height: 32),
          // if (status.state != UpdateState.idle) ...[
          //   LinearProgressIndicator(
          //       value: status.progress > 0 ? status.progress : null),
          //   const SizedBox(height: 16),
          //   SelectableText(
          //     status.message,
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       color: status.state == UpdateState.error
          //           ? Theme.of(context).colorScheme.error
          //           : null,
          //     ),
          //   ),
          //   if (status.state == UpdateState.downloading) ...[
          //     const SizedBox(height: 16),
          //     Center(
          //       child: FilledButton.icon(
          //         icon: const Icon(Icons.cancel),
          //         label: const Text('Cancel Download'),
          //         onPressed: () {
          //           ref.read(dataUpdateProvider.notifier).cancel();
          //         },
          //         style: FilledButton.styleFrom(
          //           backgroundColor: Theme.of(context).colorScheme.error,
          //           foregroundColor: Theme.of(context).colorScheme.onError,
          //         ),
          //       ),
          //     ),
          //   ],
          //   if (status.state == UpdateState.error ||
          //       status.state == UpdateState.success) ...[
          //     const SizedBox(height: 16),
          //     Center(
          //       child: TextButton.icon(
          //         icon: const Icon(Icons.clear),
          //         label: const Text('Dismiss'),
          //         onPressed: () {
          //           ref.read(dataUpdateProvider.notifier).reset();
          //         },
          //       ),
          //     ),
          // ],
        ]
                // ],
                ),
      ),
    );
  }
}

class _DataUpdateSection extends StatelessWidget {
  const _DataUpdateSection({
    required this.title,
    required this.description,
    required this.downloadLabel,
    required this.importLabel,
    required this.onDownload,
    required this.onImport,
    required this.isLoading,
  });

  final String title;
  final String description;
  final String downloadLabel;
  final String importLabel;
  final VoidCallback onDownload;
  final VoidCallback onImport;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: title,
      description: description,
      child: Container(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.cloud_download),
              label: Text(downloadLabel),
              onPressed: isLoading ? null : onDownload,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(importLabel),
              onPressed: isLoading ? null : onImport,
            ),
          ],
        ),
      ),
    );
  }
}
