import 'package:test/test.dart';
import 'package:zef_di_core/zef_di_core.dart';

import 'setup.dart';
import 'test_classes/classes.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() async {
    await ServiceLocator.I.unregisterAll();
  });

  group('Registration', () {
    test('Should Register', () async {
      // Arrange
      final instance = SimpleService();

      // Assert
      expect(
        () async => await ServiceLocator.I.registerSingleton(instance),
        returnsNormally,
      );
    });
  });

  group('Resolution', () {
    test('Should Resolve', () async {
      // Arrange
      final instance = SimpleService();
      await ServiceLocator.I.registerSingleton(instance);

      // Act
      final resolvedInstance = await ServiceLocator.I.resolve<SimpleService>();

      // Assert
      expect(resolvedInstance, isA<SimpleService>());
    });
  });
}
