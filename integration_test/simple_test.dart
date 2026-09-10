import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/src/rust/api/parser.dart';
import 'package:mdd/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  test('Can call Rust function', () async {
    final version = await MilHelper.extractMilVersion(
      path: 'mil-v2026-09-10.tar.gz',
    );
    expect(version, 'mil-v2026-09-10');
  });
}
