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

  group('Concrete', () {
    test('Should Resolve', () async {
      // Arrange
      await ServiceLocator.I.registerSingleton(SimpleService());

      // Act
      final resolvedInstance = await ServiceLocator.I.resolve<SimpleService>();

      // Assert
      expect(resolvedInstance, isA<SimpleService>());
    });
  });

  group('Different Registration Types', () {
    test('Should Resolve', () async {
      // Arrange
      await ServiceLocator.I.registerSingleton(SimpleService());
      await ServiceLocator.I.registerTransient<ServiceWithDependency>(
          (args) async =>
              ServiceWithDependency(await ServiceLocator.I.resolve()));

      // Act
      final resolvedServiceWithDependency =
          await ServiceLocator.I.resolve<ServiceWithDependency>();

      // Assert
      expect(resolvedServiceWithDependency, isA<ServiceWithDependency>());
      expect(
          resolvedServiceWithDependency.noDependencies, isA<SimpleService>());
    });
  });
}
