import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/taxon/species.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/essential_url.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/providers/species.dart';

class MilFullScreenView extends ConsumerStatefulWidget {
  const MilFullScreenView({
    super.key,
    required this.milItem,
    this.initialImages,
  });

  final RandomMilImagesWithTaxonomyResult milItem;
  final List<RandomMilImagesWithTaxonomyResult>? initialImages;

  @override
  ConsumerState<MilFullScreenView> createState() => _MilFullScreenViewState();
}

class _MilFullScreenViewState extends ConsumerState<MilFullScreenView> {
  late List<RandomMilImagesWithTaxonomyResult> _images;
  late int _currentIndex;
  late PageController _pageController;
  late TransformationController _transformationController;
  late TapGestureRecognizer _tapGestureRecognizer;

  bool _showMetadata = true;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _images = widget.initialImages != null && widget.initialImages!.isNotEmpty
        ? widget.initialImages!
        : [widget.milItem];

    final foundIndex = _images.indexWhere(
      (item) => item.milId == widget.milItem.milId,
    );
    _currentIndex = foundIndex >= 0 ? foundIndex : 0;
    _pageController = PageController(initialPage: _currentIndex);

    _transformationController = TransformationController()
      ..addListener(_onTransformationChanged);

    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        launchURL(milUrl);
      };

    if (widget.initialImages == null) {
      _loadSpeciesImages();
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _pageController.dispose();
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.05;
    if (isZoomed != _isZoomed) {
      setState(() {
        _isZoomed = isZoomed;
      });
    }
  }

  Future<void> _loadSpeciesImages() async {
    try {
      final db = ref.read(databaseProvider);
      final query = MddQuery(db);
      final speciesImages =
          await query.getMilImagesForSpecies(widget.milItem.mddId);
      if (mounted && speciesImages.isNotEmpty) {
        final newIndex = speciesImages.indexWhere(
          (item) => item.milId == widget.milItem.milId,
        );
        setState(() {
          _images = speciesImages;
          _currentIndex = newIndex >= 0 ? newIndex : 0;
        });
        if (newIndex >= 0 && _pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      }
    } catch (_) {
      // Database unavailable or error during load fallback
    }
  }

  void _nextPage() {
    if (_currentIndex < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _images[_currentIndex];
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
              child: PageView.builder(
                controller: _pageController,
                physics: _isZoomed
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: _images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _transformationController.value = Matrix4.identity();
                  });
                },
                itemBuilder: (context, index) {
                  final currentItem = _images[index];
                  return Center(
                    child: InteractiveViewer(
                      transformationController: index == _currentIndex
                          ? _transformationController
                          : null,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.asset(
                        'assets/mil-images/${currentItem.milId}.webp',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 80,
                                color:
                                    colorScheme.onSurfaceVariant.withAlpha(128),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_images.length > 1) ...[
              if (_currentIndex > 0)
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: _showMetadata ? 180 : 0,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.85),
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: _previousPage,
                        tooltip: 'Previous Image',
                      ),
                    ),
                  ),
                ),
              if (_currentIndex < _images.length - 1)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: _showMetadata ? 180 : 0,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.85),
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: _nextPage,
                        tooltip: 'Next Image',
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: _showMetadata ? 190 : 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withAlpha(140),
                    ),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${_images.length}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
            if (_showMetadata)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.52,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurfaceVariant.withAlpha(80),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scientificName,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (item.mainCommonName != null &&
                                            item.mainCommonName!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.mainCommonName!,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
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
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(Icons.pets, size: 18),
                                    label: const Text(
                                      'View Species',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                              Divider(
                                color:
                                    colorScheme.outlineVariant.withAlpha(140),
                                height: 24,
                              ),
                              _InfoRow(
                                label: 'Photographer',
                                value: item.photographer,
                                colorScheme: colorScheme,
                                icon: Icons.camera_alt_outlined,
                              ),
                              _InfoRow(
                                label: 'Location',
                                value: item.location,
                                colorScheme: colorScheme,
                                icon: Icons.location_on_outlined,
                              ),
                              _InfoRow(
                                label: 'Date taken',
                                value: item.dateTaken,
                                colorScheme: colorScheme,
                                icon: Icons.calendar_today_outlined,
                              ),
                              _InfoRow(
                                label: 'Description',
                                value: item.description,
                                colorScheme: colorScheme,
                                icon: Icons.notes_outlined,
                              ),
                              _InfoRow(
                                label: 'Distribution',
                                value: item.distribution,
                                colorScheme: colorScheme,
                                icon: Icons.map_outlined,
                              ),
                              _InfoRow(
                                label: 'MIL ID',
                                value: item.milId,
                                colorScheme: colorScheme,
                                icon: Icons.tag,
                              ),
                              if (item.isUncertainIdentification == 1)
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 8, bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer
                                        .withAlpha(120),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colorScheme.error.withAlpha(100),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: colorScheme.error,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Uncertain identification',
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
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
                                    const TextSpan(
                                      text: 'Image courtesy of the ',
                                    ),
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
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.icon,
  });

  final String label;
  final String? value;
  final ColorScheme colorScheme;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (value == null ||
        value!.trim().isEmpty ||
        value!.toUpperCase() == 'NA') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value!,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
