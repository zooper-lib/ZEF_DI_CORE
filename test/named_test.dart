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
    test('Should Register', () async {
      // Arrange
      final instance = NoDependencies();

      // Act
      await ServiceLocator.I.registerSingleton(instance, name: 'one');
      final resolvedInstance = await ServiceLocator.I.resolve<NoDependencies>();

      // Assert
      expect(resolvedInstance, isA<NoDependencies>());
    });

    test('Different Names | Should Respect Names', () async {
      // Arrange
      final instanceOne = NoDependencies();
      final instanceTwo = NoDependencies();

      // Act
      await ServiceLocator.I.registerSingleton(instanceOne, name: 'one');
      await ServiceLocator.I.registerSingleton(instanceTwo, name: 'two');
      final resolvedInstanceOne =
          await ServiceLocator.I.resolve<NoDependencies>(name: 'one');
      final resolvedInstanceTwo =
          await ServiceLocator.I.resolve<NoDependencies>(name: 'two');

      // Assert
      expect(resolvedInstanceOne, isA<NoDependencies>());
      expect(resolvedInstanceTwo, isA<NoDependencies>());
    });

    test('One named Instance | Should Return One Instance', () async {
      // Arrange
      final unnamedInstance = NoDependencies();
      final namedInstance = NoDependencies();

      // Act
      await ServiceLocator.I.registerSingleton(unnamedInstance);
      await ServiceLocator.I.registerSingleton(namedInstance, name: 'named');

      final allInstances = await ServiceLocator.I.resolveAll<NoDependencies>();
      final namedInstances =
          await ServiceLocator.I.resolveAll<NoDependencies>(name: 'named');

      // Assert
      expect(allInstances, hasLength(2));
      expect(namedInstances, hasLength(1));
    });

    test('Multiple With Same Name | Should Resolve All', () async {
      // Arrange
      final instanceOne = NoDependencies();
      final instanceTwo = NoDependencies();

      // Act
      await ServiceLocator.I.registerSingleton(instanceOne, name: 'instance');
      await ServiceLocator.I.registerSingleton(instanceTwo, name: 'instance');
      final instances =
          await ServiceLocator.I.resolveAll<NoDependencies>(name: 'instance');

      // Assert
      expect(instances, hasLength(2));
    });
  });
}
