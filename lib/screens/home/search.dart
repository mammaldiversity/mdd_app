import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/home/mil_carousel.dart';
import 'package:mdd/screens/home/stats.dart' show wideLayoutMinWidth;
import 'package:mdd/screens/menu/release_notes.dart';
import 'package:mdd/screens/search/page.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/database.dart';

/// The banner at the top of the home screen: title and search, with the
/// MIL carousel beside them on wide screens and below them on phones.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= wideLayoutMinWidth;
        final banner = Container(
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
              ? Row(
                  children: [
                    const Expanded(
                      flex: 13,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeroTitle(logoSize: 72),
                          SizedBox(height: 24),
                          HomeSearchBar(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withAlpha(160),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const RandomMilCarousel(),
                      ),
                    ),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroTitle(logoSize: 52),
                    SizedBox(height: 16),
                    HomeSearchBar(),
                  ],
                ),
        );
        if (wide) return banner;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            banner,
            const SizedBox(height: 16),
            const RandomMilCarousel(),
          ],
        );
      },
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle({required this.logoSize});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final large = logoSize > 60;
    return Row(
      children: [
        Image.asset(
          'assets/icons/favicon512.png',
          width: logoSize,
          height: logoSize,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Mammal Diversity Database',
                style: (large ? textTheme.headlineSmall : textTheme.titleLarge)
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'By the American Society of Mammalogists',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _searchController,
      hintText: 'Search species, genus, family, order…',
      leading: const Icon(Icons.search),
      hintStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodyMedium),
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surface,
      ),
      side: WidgetStateProperty.all(
        BorderSide(
          color: Theme.of(context).colorScheme.primary.withAlpha(180),
          width: 2,
        ),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return SearchDatabasePage(controller: _searchController);
              },
            ),
          );
        }
      },
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return SearchDatabasePage(controller: _searchController);
            },
          ),
        );
      },
    );
  }
}

class DatabaseInfo extends ConsumerWidget {
  const DatabaseInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(mddInfoProvider)
        .when(
          data: (MddInfoData mddInfo) {
            final hasMil =
                mddInfo.milVersion != null && mddInfo.milVersion!.isNotEmpty;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  [
                    'MDD ${mddInfo.version} · ${mddInfo.releaseDate}',
                    if (hasMil) 'MIL ${mddInfo.milVersion}',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const ReleaseNotesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notes, size: 16),
                  label: const Text('Release Notes'),
                ),
              ],
            );
          },
          loading: () => const SimpleLoadingMessages(),
          error: (Object error, StackTrace? stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}
