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
      factory(args) async => SimpleService();

      // Assert
      expect(
        () async => await ServiceLocator.I.registerSingletonFactory(factory),
        returnsNormally,
      );
    });
  });

  group('Resolution', () {
    test('Should Resolve', () async {
      // Arrange
      factory(args) async => SimpleService();
      await ServiceLocator.I.registerSingletonFactory(factory);

      // Act
      final instance = await ServiceLocator.I.resolve<SimpleService>();

      // Assert
      expect(instance, isA<SimpleService>());
    });
  });
}
