import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/home/stats.dart';
import 'package:mdd/screens/search/page.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/database.dart';

class DatabaseSearch extends ConsumerWidget {
  const DatabaseSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [
        HomeSearchBar(),
        SizedBox(height: 8),
        SpeciesCount(),
        SizedBox(height: 16),
        DatabaseInfo(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search database',
        hintStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primaryContainer.withAlpha(24),
        ),
        side: WidgetStateProperty.all(
          BorderSide(
            color:
                Theme.of(context).colorScheme.primaryContainer.withAlpha(180),
            width: 2,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return SearchDatabasePage(
                    controller: _searchController,
                  );
                },
              ),
            );
          }
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return SearchDatabasePage(
                  controller: _searchController,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DatabaseInfo extends ConsumerWidget {
  const DatabaseInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(mddInfoProvider).when(
          data: (MddInfoData mddInfo) {
            return Text(
                'Database version\nv${mddInfo.version}, '
                'released ${mddInfo.releaseDate}.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center);
          },
          loading: () => const SimpleLoadingMessages(),
          error: (Object error, StackTrace? stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}
