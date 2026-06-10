import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/taxon/species.dart';

class RandomMilCarousel extends ConsumerStatefulWidget {
  const RandomMilCarousel({super.key});

  @override
  ConsumerState<RandomMilCarousel> createState() => _RandomMilCarouselState();
}

class _RandomMilCarouselState extends ConsumerState<RandomMilCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 1000);
    _currentPage = 1000;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 2000),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milDataAsync = ref.watch(randomMilImagesProvider);

    return milDataAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final dataIndex = index % data.length;
              final item = data[dataIndex];
              return _buildCarouselItem(context, item, index);
            },
          ),
        );
      },
      loading: () => const SizedBox(
          height: 250, child: Center(child: SimpleLoadingOnly())),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, RandomMilImagesWithTaxonomyResult item, int index) {
    return CarouselItemWidget(
      item: item,
      isCenter: _currentPage == index,
    );
  }
}

class CarouselItemWidget extends ConsumerWidget {
  const CarouselItemWidget({
    super.key,
    required this.item,
    required this.isCenter,
  });

  final RandomMilImagesWithTaxonomyResult item;
  final bool isCenter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double scale = isCenter ? 1.0 : 0.8;
    double opacity = isCenter ? 1.0 : 0.5;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: scale, end: scale),
      duration: const Duration(milliseconds: 350),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          ref.read(currentMddIDProvider.notifier).setMddID(item.mddId);
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const SpeciesPage(),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/mil-images/${item.milId}.webp',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child:
                        const Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.genus} ${item.specificEpithet}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            if (item.mainCommonName != null && item.mainCommonName!.isNotEmpty)
              Text(
                item.mainCommonName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
