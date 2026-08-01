import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/gallery/mil_full_screen_view.dart';
import 'package:mdd/services/database/mdd_query.dart';

void main() {
  final sampleMilItem1 = RandomMilImagesWithTaxonomyResult(
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

  final sampleMilItem2 = RandomMilImagesWithTaxonomyResult(
    milId: 'MIL_002',
    mddId: 100001,
    description: 'Female lion hunting in grassland',
    photographer: 'John Smith',
    location: 'Serengeti National Park, Tanzania',
    distribution: 'East Africa',
    dateTaken: '2022-08-20',
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
          home: MilFullScreenView(milItem: sampleMilItem1),
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

  testWidgets(
    'MilFullScreenView supports scrolling to next images of same species',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MilFullScreenView(
              milItem: sampleMilItem1,
              initialImages: [sampleMilItem1, sampleMilItem2],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify page counter badge displays 1 / 2
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.byTooltip('Next Image'), findsOneWidget);

      // Tap next image chevron button
      await tester.tap(find.byTooltip('Next Image'));
      await tester.pumpAndSettle();

      // Verify counter badge updates to 2 / 2 and metadata updates
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Serengeti National Park, Tanzania'), findsOneWidget);
      expect(find.byTooltip('Previous Image'), findsOneWidget);

      // Tap previous image chevron button
      await tester.tap(find.byTooltip('Previous Image'));
      await tester.pumpAndSettle();

      // Verify back to first image
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    },
  );
}
