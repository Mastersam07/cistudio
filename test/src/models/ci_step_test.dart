import 'package:cistudio/src/models/ci_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CIStep Tests', () {
    test('ArgumentError thrown if default property value is not a valid option',
        () {
      expect(
          () => CIStep(name: 'Test Step', position: 1, properties: {
                'binary': ['apk', 'aab']
              }, defaultProperties: {
                'binary': 'bundle'
              }),
          throwsArgumentError);
    });

    test(
        'Default properties are set based on step name for "build-android-app"',
        () {
      final ciStep = CIStep(
        name: 'Build Android App',
        position: 1,
      );

      ciStep.setDefaultProperties();

      expect(ciStep.properties['binary'], ['apk', 'aab']);
      expect(ciStep.defaultProperties['binary'], 'apk');
    });

    test('Default properties are set based on step name for "run-tests"', () {
      final ciStep = CIStep(
        name: 'Run Tests',
        position: 2,
      );

      ciStep.setDefaultProperties();

      expect(ciStep.properties['coverage'], ['with', 'without']);
      expect(ciStep.defaultProperties['coverage'], 'with');
    });

    test(
        'Properties remain empty if step name does not match specific conditions',
        () {
      final ciStep = CIStep(
        name: 'Non-specific Step',
        position: 3,
      );

      ciStep.setDefaultProperties();

      expect(ciStep.properties.isEmpty, true);
      expect(ciStep.defaultProperties.isEmpty, true);
    });
  });
}
