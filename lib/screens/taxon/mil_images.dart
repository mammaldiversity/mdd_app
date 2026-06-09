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

  Widget _buildMetadataRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty || value == 'NA') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mil = widget.data[_currentIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'MIL Images',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Image.asset(
                'assets/mil-images/${mil.milId}.webp',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, size: 64))),
              ),
            ),
            if (widget.data.length > 1) ...[
              Positioned(
                left: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: _prevImage,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: _nextImage,
                  ),
                ),
              ),
            ],
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '© ${mil.photographer ?? 'Unknown'} / ASM-MIL',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            if (widget.data.length > 1)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.data.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetadataRow(context, 'Location', mil.location),
              _buildMetadataRow(context, 'Date taken', mil.dateTaken),
              _buildMetadataRow(context, 'Description', mil.description),
              _buildMetadataRow(context, 'Distribution', mil.distribution),
              const SizedBox(height: 12),
              Text(
                'Image courtesy of the ASM Mammal Images Library · MIL ID: ${mil.milId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
