import 'package:flutter/material.dart';

/// Zoom in, zoom out and recenter buttons overlaid on a map.
class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom in',
          visualDensity: VisualDensity.compact,
          onPressed: onZoomIn,
          icon: const Icon(Icons.add),
        ),
        IconButton(
          tooltip: 'Zoom out',
          visualDensity: VisualDensity.compact,
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          tooltip: 'Recenter map',
          visualDensity: VisualDensity.compact,
          onPressed: onReset,
          icon: const Icon(Icons.center_focus_strong_outlined),
        ),
      ],
    ),
  );
}

/// Tells the reader how to bring the data back into view.
class RecenterHint extends StatelessWidget {
  const RecenterHint({super.key, this.subject = 'Range'});

  /// What may be out of view, e.g. "Range" or "Records".
  final String subject;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: color);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '$subject not showing? Tap '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.center_focus_strong_outlined,
              size: 16,
              color: color,
            ),
          ),
          const TextSpan(text: ' to recenter the map.'),
        ],
      ),
    );
  }
}
