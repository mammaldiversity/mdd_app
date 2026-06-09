import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdd/screens/shared/loadings.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isDesktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: SetupImage()),
                        SizedBox(width: 48),
                        Expanded(child: SetupContent()),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SetupImage(),
                        SizedBox(height: 32),
                        SetupContent(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SetupImage extends StatefulWidget {
  const SetupImage({super.key});

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
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final allImages = manifestMap.keys
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: _imagePaths.isEmpty
            ? const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            : AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  _imagePaths[_currentIndex],
                  key: ValueKey<String>(_imagePaths[_currentIndex]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, size: 64))),
                ),
              ),
      ),
    );
  }
}

class SetupContent extends StatelessWidget {
  const SetupContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SetupHeadline(),
        const SizedBox(height: 16),
        const OtherFeatures(),
        const SizedBox(height: 40),
        const SimpleLoadingOnly(),
        const SizedBox(height: 24),
        Text(
          '⏳ Setting up MDD...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'We are populating the local database so that you can access all the mammal data completely offline. '
            'This may take a several minutes.\n\nKeep this app open until setup is complete.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class SetupHeadline extends StatelessWidget {
  const SetupHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'MDD is aimed to promote rigorous study of mammal diversity worldwide.',
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );
  }
}

class OtherFeatures extends StatelessWidget {
  const OtherFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'App Features:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Offline access • Advanced search • Partial data export • Mammal diversity statistics',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
