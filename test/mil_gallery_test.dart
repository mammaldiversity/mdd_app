import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/gallery/mil_full_screen_view.dart';
import 'package:mdd/services/database/mdd_query.dart';

void main() {
  final sampleMilItem = RandomMilImagesWithTaxonomyResult(
    milId: 'MIL_001',
    mddId: 100001,
    description: 'Adult male in habitat',
    photographer: 'Jane Doe',
    location: 'Gorongosa National Park, Mozambique',
    distribution: 'Southern Africa',
    dateTaken: '2023-05-15',
    orientation: 'landscape',
    isUncertainIdentification: 0,
    genus: 'Panthera',
    specificEpithet: 'leo',
    mainCommonName: 'Lion',
  );

  testWidgets('MilFullScreenView displays metadata and attribution correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MilFullScreenView(milItem: sampleMilItem),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and species name
    expect(find.text('Panthera leo'), findsWidgets);
    expect(find.text('Lion'), findsOneWidget);

    // Verify metadata fields
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Gorongosa National Park, Mozambique'), findsOneWidget);
    expect(find.text('2023-05-15'), findsOneWidget);
    expect(find.text('Adult male in habitat'), findsOneWidget);
    expect(find.text('Southern Africa'), findsOneWidget);
    expect(find.text('MIL_001'), findsWidgets);

    // Verify attribution text
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('ASM Mammal Images Library'),
      ),
      findsOneWidget,
    );

    // Verify button to view species
    expect(find.text('View Species'), findsOneWidget);
  });
}
