import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/database.dart';

class ReleaseNotesPage extends ConsumerWidget {
  const ReleaseNotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Release Notes'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ReleaseNotesContent(),
      ),
    );
  }
}

class ReleaseNotesContent extends ConsumerWidget {
  const ReleaseNotesContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mddInfoAsync = ref.watch(mddInfoProvider);

    return Column(
      children: [
        mddInfoAsync.when(
          data: (MddInfoData mddInfo) =>
              ReleaseNotesDetailsCard(mddInfo: mddInfo),
          loading: () => const Center(child: SimpleLoadingMessages()),
          error: (Object error, StackTrace? stackTrace) => Center(
            child: Text('Error loading release notes: $error'),
          ),
        ),
      ],
    );
  }
}

class ReleaseNotesDetailsCard extends StatelessWidget {
  const ReleaseNotesDetailsCard({
    super.key,
    required this.mddInfo,
  });

  final MddInfoData mddInfo;

  @override
  Widget build(BuildContext context) {
    final remarks = mddInfo.remarks;
    final doi = mddInfo.doi;
    final version = mddInfo.version ?? 'Unknown';
    final releaseDate = mddInfo.releaseDate ?? 'Unknown';
    final milVersion = mddInfo.milVersion;

    return CommonCard(
      title: 'MDD Database Release $version',
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InfoRow(label: 'Version:', value: version),
            const SizedBox(height: 8),
            InfoRow(label: 'Release Date:', value: releaseDate),
            if (milVersion != null && milVersion.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              InfoRow(label: 'MIL Version:', value: milVersion),
            ],
            if (remarks != null && remarks.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Remarks',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                remarks,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (doi != null && doi.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'DOI Citation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              DoiLinkTile(doi: doi),
            ],
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class DoiLinkTile extends StatelessWidget {
  const DoiLinkTile({
    super.key,
    required this.doi,
  });

  final String doi;

  @override
  Widget build(BuildContext context) {
    final String url = doi.startsWith('http') ? doi : 'https://doi.org/$doi';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.link),
      title: Text(
        doi,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => launchURL(url),
    );
  }
}
