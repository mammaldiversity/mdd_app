import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/gallery/mil_full_screen_view.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/services/database/database.dart'
    hide RandomMilImagesWithTaxonomyResult;
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';

class MilGalleryPage extends ConsumerStatefulWidget {
  const MilGalleryPage({super.key});

  @override
  ConsumerState<MilGalleryPage> createState() => _MilGalleryPageState();
}

class _MilGalleryPageState extends ConsumerState<MilGalleryPage> {
  static const int _pageSize = 36;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<RandomMilImagesWithTaxonomyResult> _items = [];
  int _totalCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _items = [];
      _hasMore = true;
    });

    final AppDatabase db = ref.read(databaseProvider);
    final MddQuery query = MddQuery(db);

    try {
      final total = await query.getMilImagesCount(searchQuery: _searchQuery);
      final initialItems = await query.getMilImagesPaginated(
        limit: _pageSize,
        offset: 0,
        searchQuery: _searchQuery,
      );

      if (mounted) {
        setState(() {
          _totalCount = total;
          _items = initialItems;
          _isLoading = false;
          _hasMore = initialItems.length < total;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final AppDatabase db = ref.read(databaseProvider);
    final MddQuery query = MddQuery(db);

    try {
      final nextItems = await query.getMilImagesPaginated(
        limit: _pageSize,
        offset: _items.length,
        searchQuery: _searchQuery,
      );

      if (mounted) {
        setState(() {
          _items.addAll(nextItems);
          _isLoading = false;
          _hasMore = _items.length < _totalCount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (_searchQuery != query) {
        _searchQuery = query;
        _loadInitialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              (constraints.maxWidth / 160).floor().clamp(2, 6);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoCard(
                        text:
                            'Browse photographs of mammals from the ASM Mammal Images Library (MIL). Tap any photo to view full metadata, photographer credit, and species details.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText:
                              'Search species, common name, photographer, location...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withAlpha(128),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Found $_totalCount results'
                                : 'Showing $_totalCount MIL Images',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (_items.isNotEmpty)
                            Text(
                              'Loaded ${_items.length} of $_totalCount',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_items.isEmpty && !_isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No MIL images found matching "$_searchQuery"'
                              : 'No MIL images available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _items[index];
                        return _MilGalleryCard(item: item);
                      },
                      childCount: _items.length,
                    ),
                  ),
                ),
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MilGalleryCard extends StatelessWidget {
  const _MilGalleryCard({required this.item});

  final RandomMilImagesWithTaxonomyResult item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sciName = '${item.genus ?? ''} ${item.specificEpithet ?? ''}'.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => MilFullScreenView(milItem: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/mil-images/${item.milId}.webp',
                    fit: BoxFit.cover,
                    cacheWidth: 350,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 36, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (item.photographer != null &&
                      item.photographer!.isNotEmpty)
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt,
                                size: 10, color: Colors.white70),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                item.photographer!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sciName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (item.mainCommonName != null &&
                      item.mainCommonName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.mainCommonName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
