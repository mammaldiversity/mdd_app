import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/data_update_provider.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/screens/shared/card.dart';

class DataUpdatePage extends StatelessWidget {
  const DataUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Update'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isWide) ...[
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _MddUpdateSection()),
                    SizedBox(width: 16),
                    Expanded(child: _MilUpdateSection()),
                  ],
                ),
              ] else ...[
                const _MddUpdateSection(),
                const SizedBox(height: 24),
                const _MilUpdateSection(),
              ],
              const _UpdateProgress(forReset: false), // Progress for MDD/MIL
              const SizedBox(height: 24),
              const _ResetDatabaseSection(),
              const _UpdateProgress(forReset: true), // Progress for Reset DB
            ],
          ),
        ),
      ),
    );
  }
}

class _MddUpdateSection extends ConsumerWidget {
  const _MddUpdateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dataUpdateProvider);
    final isLoading = status.state == UpdateState.downloading ||
        status.state == UpdateState.extracting ||
        status.state == UpdateState.updating;
    final isWide = MediaQuery.of(context).size.width > 600;

    return _DataUpdateSection(
      title: 'Mammal Diversity Database (MDD)',
      description:
          'Download the latest MDD taxonomy data or import it from a local file. This process replaces the current local database.',
      downloadLabel: 'Download MDD.zip',
      importLabel: 'Import local MDD.zip',
      isLoading: isLoading,
      height: isWide ? 320 : null,
      content: Center(
        child: Image.asset(
          'assets/icons/favicon512.png',
          width: 120,
          height: 120,
        ),
      ),
      onDownload: () {
        ref.read(dataUpdateProvider.notifier).downloadAndUpdateMdd();
      },
      onImport: () {
        ref.read(dataUpdateProvider.notifier).importLocalMdd();
      },
    );
  }
}

class _MilUpdateSection extends ConsumerWidget {
  const _MilUpdateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dataUpdateProvider);
    final isLoading = status.state == UpdateState.downloading ||
        status.state == UpdateState.extracting ||
        status.state == UpdateState.updating;
    final isWide = MediaQuery.of(context).size.width > 600;

    return _DataUpdateSection(
      title: 'Mammal Images Library (MIL)',
      description:
          'Download the latest MIL photo dataset or import it from a local file.',
      downloadLabel: 'Download MIL.tar.gz',
      importLabel: 'Import local MIL file',
      isLoading: isLoading,
      height: isWide ? 320 : null,
      content: const MilUpdatePreview(),
      onDownload: () {
        ref.read(dataUpdateProvider.notifier).downloadAndUpdateMil();
      },
      onImport: () {
        ref.read(dataUpdateProvider.notifier).importLocalMil();
      },
    );
  }
}

class _UpdateProgress extends ConsumerWidget {
  const _UpdateProgress({required this.forReset});

  final bool forReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dataUpdateProvider);

    if (status.state == UpdateState.idle) return const SizedBox.shrink();
    if (status.isReset != forReset) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        LinearProgressIndicator(
            value: status.progress > 0 ? status.progress : null),
        const SizedBox(height: 16),
        SelectableText(
          status.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: status.state == UpdateState.error
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        ),
        if (status.state == UpdateState.downloading) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Download'),
              onPressed: () {
                ref.read(dataUpdateProvider.notifier).cancel();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
        if (status.state == UpdateState.error ||
            status.state == UpdateState.success) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Dismiss'),
              onPressed: () {
                ref.read(dataUpdateProvider.notifier).reset();
              },
            ),
          ),
        ],
      ],
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
    this.height,
    this.content,
  });

  final String title;
  final String description;
  final String downloadLabel;
  final String importLabel;
  final VoidCallback onDownload;
  final VoidCallback onImport;
  final bool isLoading;
  final double? height;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment:
            height != null ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (content != null) ...[
            content!,
            if (height != null) const Spacer() else const SizedBox(height: 16),
          ] else if (height != null) ...[
            const Spacer(),
          ],
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
    );

    final card = CommonCard(
      title: title,
      description: description,
      child: height != null ? Expanded(child: cardChild) : cardChild,
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: card,
      );
    }
    return card;
  }
}

class _ResetDatabaseSection extends ConsumerWidget {
  const _ResetDatabaseSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dataUpdateProvider);
    final isLoading = status.state == UpdateState.downloading ||
        status.state == UpdateState.extracting ||
        status.state == UpdateState.updating;

    return CommonCard(
      title: 'Reset to Default Bundle DB',
      description:
          'Discard any downloaded or imported database updates and reset to the original default database bundled with the app.',
      child: Container(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Reset Database'),
              onPressed: isLoading
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Database'),
                          content: const Text(
                              'Are you sure you want to reset the database to the default bundle version? This will discard all downloaded/imported updates.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref
                            .read(dataUpdateProvider.notifier)
                            .resetToDefaultDatabase();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MilUpdatePreview extends ConsumerWidget {
  const MilUpdatePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milDataAsync = ref.watch(randomMilImagesProvider);

    return milDataAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: Icon(Icons.image_not_supported, size: 48),
            ),
          );
        }

        // Take the first 3 images.
        final items = data.take(3).toList();

        return SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final item in items)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/mil-images/${item.milId}.webp',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 32),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) => const SizedBox(
        height: 120,
        child: Center(
          child: Icon(Icons.broken_image, size: 48),
        ),
      ),
    );
  }
}
