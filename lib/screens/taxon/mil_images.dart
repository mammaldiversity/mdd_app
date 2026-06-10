import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/screens/shared/loadings.dart';

class MilImagesWidget extends ConsumerWidget {
  const MilImagesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(milDataProvider).when(
          data: (List<MilDataData> data) {
            if (data.isEmpty) return const SizedBox.shrink();
            return MilImagesViewer(data: data);
          },
          loading: () => const SimpleLoadingOnly(),
          error: (error, stackTrace) => Text('Error loading images: $error'),
        );
  }
}

class MilImagesViewer extends StatefulWidget {
  const MilImagesViewer({super.key, required this.data});
  final List<MilDataData> data;

  @override
  State<MilImagesViewer> createState() => _MilImagesViewerState();
}

class _MilImagesViewerState extends State<MilImagesViewer> {
  int _currentIndex = 0;

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.data.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1) % widget.data.length;
      if (_currentIndex < 0) _currentIndex += widget.data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mil = widget.data[_currentIndex];

    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                MilImage(mil: mil),
                if (widget.data.length > 1) ...[
                  Positioned(
                    left: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: _prevImage,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        onPressed: _nextImage,
                      ),
                    ),
                  ),
                ],
                if (widget.data.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainer
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.data.length}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
            MilMetadataView(mil: mil),
          ],
        ));
  }
}

class MilImage extends StatelessWidget {
  const MilImage({super.key, required this.mil});
  final MilDataData mil;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: Image.asset(
        'assets/mil-images/${mil.milId}.webp',
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
            height: 300,
            child: Center(child: Icon(Icons.broken_image, size: 64))),
      ),
    );
  }
}

class MilMetadataView extends StatelessWidget {
  const MilMetadataView({super.key, required this.mil});
  final MilDataData mil;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withAlpha(32),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MilMetadataRow(label: 'Location', value: mil.location),
          MilMetadataRow(label: 'Date taken', value: mil.dateTaken),
          MilMetadataRow(label: 'Description', value: mil.description),
          MilMetadataRow(label: 'Distribution', value: mil.distribution),
          const SizedBox(height: 12),
          Text(
            'Image courtesy of the ASM Mammal Images Library · MIL ID: ${mil.milId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class MilMetadataRow extends StatelessWidget {
  const MilMetadataRow({super.key, required this.label, required this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty || value!.toUpperCase() == 'NA') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
                text: '$label : ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
