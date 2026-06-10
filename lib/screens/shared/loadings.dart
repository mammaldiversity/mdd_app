import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/settings.dart';
import 'package:mdd/services/providers/species.dart';

class LoadingCarousel extends ConsumerStatefulWidget {
  const LoadingCarousel({super.key});

  @override
  ConsumerState<LoadingCarousel> createState() => _LoadingCarouselState();
}

class _LoadingCarouselState extends ConsumerState<LoadingCarousel> {
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
    final milDataAsync = ref.watch(milJsonCarouselProvider);

    return milDataAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return PageView.builder(
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemBuilder: (context, index) {
            final dataIndex = index % data.length;
            final item = data[dataIndex];
            final milId = item['milId'] as String;
            
            double scale = _currentPage == index ? 1.0 : 0.8;
            double opacity = _currentPage == index ? 1.0 : 0.5;

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/mil-images/$milId.webp',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: SimpleLoadingOnly()),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class DataLoadingMessages extends ConsumerWidget {
  const DataLoadingMessages({super.key, required this.isSimple});

  final bool isSimple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ref.watch(isFirstRunProvider).when(
            data: (isFirstRun) {
              if (isFirstRun) {
                return isSimple
                    ? const SimpleLoadingMessages()
                    : const FirstRunLoadingMessages();
              } else {
                return const SimpleLoadingMessages();
              }
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
    );
  }
}

class FirstRunLoadingMessages extends StatelessWidget {
  const FirstRunLoadingMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              child: LoadingCarousel(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Retrieving and parsing MDD data... ⏳',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'These may take several minutes. '
              'We are making sure you can access the data offline'
              ' from anywhere in the world. 🌍',
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

class SimpleLoadingMessages extends StatelessWidget {
  const SimpleLoadingMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              child: LoadingCarousel(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Retrieving MDD data... ⏳',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleLoadingOnly extends StatelessWidget {
  const SimpleLoadingOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary.withAlpha(80),
        ),
      ),
    );
  }
}
