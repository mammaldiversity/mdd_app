import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:mdd/screens/home/search.dart' show HeroTitle;

/// First-run screen shown while the local database is populated. Styled
/// like the home hero so the hand-off to the home screen feels continuous.
class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  /// Wider than this, the photo sits beside the text instead of above it.
  static const double _splitMinWidth = 720;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _splitMinWidth;
                  return Container(
                    padding: EdgeInsets.all(wide ? 28 : 20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(110),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withAlpha(90),
                        width: 1,
                      ),
                    ),
                    child: wide
                        ? const Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child: SetupImage(height: 420),
                              ),
                              SizedBox(width: 28),
                              Expanded(flex: 11, child: SetupContent()),
                            ],
                          )
                        : const Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              HeroTitle(logoSize: 52),
                              SizedBox(height: 16),
                              SetupImage(height: 220),
                              SizedBox(height: 16),
                              SetupContent(showTitle: false),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cross-fades through a random selection of bundled MIL photos.
class SetupImage extends StatefulWidget {
  const SetupImage({super.key, required this.height});

  final double height;

  @override
  State<SetupImage> createState() => _SetupImageState();
}

class _SetupImageState extends State<SetupImage> {
  List<String> _imagePaths = [];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allImages = manifest
          .listAssets()
          .where((path) => path.startsWith('assets/mil-images/'))
          .toList();
      allImages.shuffle();
      if (mounted) {
        setState(() {
          _imagePaths = allImages.take(50).toList();
        });

        if (_imagePaths.isNotEmpty) {
          _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
            if (mounted) {
              setState(() {
                _currentIndex = (_currentIndex + 1) % _imagePaths.length;
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading images: $e');
      if (mounted) {
        setState(() {
          _imagePaths = ['assets/mil-images/1139.webp'];
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        color: colorScheme.surface.withAlpha(160),
        // The status card already shows progress, so an empty frame is
        // enough while the asset manifest loads.
        child: _imagePaths.isEmpty
            ? null
            : AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildPhoto(_imagePaths[_currentIndex], colorScheme),
              ),
      ),
    );
  }

  /// Shows the whole photo, so credits burned into a corner stay visible.
  /// A blurred, cropped copy fills the space the photo leaves.
  Widget _buildPhoto(String path, ColorScheme colorScheme) {
    return Stack(
      key: ValueKey<String>(path),
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          // Mirror keeps the blur solid to the frame edges instead of
          // fading out to transparent.
          imageFilter: ImageFilter.blur(
            sigmaX: 24,
            sigmaY: 24,
            tileMode: TileMode.mirror,
          ),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
        Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class SetupContent extends StatelessWidget {
  const SetupContent({super.key, this.showTitle = true});

  /// The narrow layout places the title above the photo instead.
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          const HeroTitle(logoSize: 72),
          const SizedBox(height: 16),
        ],
        Text(
          'Promoting rigorous study of mammal diversity worldwide.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const SetupFeatures(),
        const SizedBox(height: 16),
        const SetupStatus(),
      ],
    );
  }
}

class SetupFeatures extends StatelessWidget {
  const SetupFeatures({super.key});

  static const List<(IconData, String)> _features = [
    (Icons.cloud_off_outlined, 'Works offline'),
    (Icons.manage_search_rounded, 'Advanced search'),
    (Icons.file_download_outlined, 'Data export'),
    (Icons.analytics_outlined, 'Diversity statistics'),
  ];

  @override
  Widget build(BuildContext context) {
    const double spacing = 8;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (icon, label) in _features)
              SizedBox(
                width: tileWidth,
                child: _FeatureTile(icon: icon, label: label),
              ),
          ],
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(160),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Setup has no measurable progress, so the bar runs indeterminately.
class SetupStatus extends StatelessWidget {
  const SetupStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setting up the offline database',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: colorScheme.primary,
            backgroundColor: colorScheme.primaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            'Loading the mammal data so you can use it without a connection. '
            'This can take a few minutes. Keep the app open until it '
            'finishes.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
