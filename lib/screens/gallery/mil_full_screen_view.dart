import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/taxon/species.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/essential_url.dart';
import 'package:mdd/services/providers/species.dart';

class MilFullScreenView extends ConsumerStatefulWidget {
  const MilFullScreenView({super.key, required this.milItem});

  final RandomMilImagesWithTaxonomyResult milItem;

  @override
  ConsumerState<MilFullScreenView> createState() => _MilFullScreenViewState();
}

class _MilFullScreenViewState extends ConsumerState<MilFullScreenView> {
  bool _showMetadata = true;
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        launchURL(milUrl);
      };
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.milItem;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final scientificName =
        '${item.genus ?? ''} ${item.specificEpithet ?? ''}'.trim();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          scientificName.isNotEmpty ? scientificName : 'MIL Image',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showMetadata ? Icons.info : Icons.info_outline,
            ),
            tooltip: _showMetadata ? 'Hide Details' : 'Show Details',
            onPressed: () {
              setState(() {
                _showMetadata = !_showMetadata;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showMetadata = !_showMetadata;
                });
              },
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    'assets/mil-images/${item.milId}.webp',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 80,
                            color: colorScheme.onSurfaceVariant.withAlpha(128),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Image not available',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showMetadata)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.48,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(
                          theme.brightness == Brightness.dark ? 120 : 30,
                        ),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scientificName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.mainCommonName != null &&
                                      item.mainCommonName!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.mainCommonName!,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                              icon: const Icon(Icons.pets, size: 18),
                              label: const Text(
                                'View Species',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                ref
                                    .read(currentMddIDProvider.notifier)
                                    .setMddID(item.mddId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const SpeciesPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Divider(color: colorScheme.outlineVariant, height: 24),
                        _buildInfoRow(
                            'Photographer', item.photographer, colorScheme),
                        _buildInfoRow('Location', item.location, colorScheme),
                        _buildInfoRow(
                            'Date taken', item.dateTaken, colorScheme),
                        _buildInfoRow(
                            'Description', item.description, colorScheme),
                        _buildInfoRow(
                            'Distribution', item.distribution, colorScheme),
                        _buildInfoRow('MIL ID', item.milId, colorScheme),
                        if (item.isUncertainIdentification == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: colorScheme.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Uncertain identification',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(text: 'Image courtesy of the '),
                              TextSpan(
                                text: 'ASM Mammal Images Library',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: _tapGestureRecognizer,
                              ),
                              TextSpan(
                                text: ' · MIL ID: ${item.milId}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, ColorScheme colorScheme) {
    if (value == null || value.trim().isEmpty || value.toUpperCase() == 'NA') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
