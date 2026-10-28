import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the MIL image gallery among the main screen's destinations.
const int galleryPageIndex = 2;

/// The main screen's selected destination. Shared so content inside a
/// page, such as a home screen tile, can switch to another destination.
final selectedPageProvider = NotifierProvider<SelectedPage, int>(
  () => SelectedPage(),
);

class SelectedPage extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    state = index;
  }
}
