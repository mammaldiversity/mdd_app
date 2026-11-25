import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mdd/services/providers/navigation.dart';

/// App bar action that returns to the home screen from any pushed page.
///
/// Higher taxon pages, species pages, and tables link to each other, so a
/// user can end up many routes deep. This pops every route above the main
/// screen and selects its Home destination in one tap.
class HomeButton extends ConsumerWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: 'Home',
    icon: const Icon(Icons.home_outlined),
    onPressed: () {
      ref.read(selectedPageProvider.notifier).select(0);
      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    },
  );
}
