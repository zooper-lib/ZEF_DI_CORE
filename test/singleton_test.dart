import 'package:test/test.dart';
import 'package:zef_di_core/zef_di_core.dart';

import 'setup.dart';
import 'test_classes/classes.dart';
import 'test_classes/implementations.dart';
import 'test_classes/interfaces.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() async {
    await ServiceLocator.I.unregisterAll();
  });

  group('Concrete', () {
    test('No Previous Registration | Should Return Empty Set', () async {
      // Act
      final result = await ServiceLocator.I.resolveAll();

      // Assert
      expect(result, isEmpty);
    });

    test('Single Instance | Should Return One Instance', () async {
      // Arrange
      final instance = NoDependencies();

      // Act
      await ServiceLocator.I.registerSingleton(instance);
      final instances = await ServiceLocator.I.resolveAll<NoDependencies>();

      // Assert
      expect(instances, hasLength(1));
    });

    test(
        'Register Singleton | Duplicate Instances | Should Return Multiple Instances',
        () async {
      // Arrange
      final instance1 = NoDependencies();
      final instance2 = NoDependencies();

      // Act
      await ServiceLocator.I.registerSingleton(instance1);
      await ServiceLocator.I.registerSingleton(instance2);
      final instances = await ServiceLocator.I.resolveAll<NoDependencies>();

      // Assert
      expect(instances, hasLength(2));
    });
  });

  group('Singleton Factory Registration |', () {
    test(
        'Register Singleton Factory | No Previous Registration | Should Return Empty Set',
        () async {
      // Act
      final result = await ServiceLocator.I.resolveAll();

      // Assert
      expect(result, isEmpty);
    });

    test(
        'Register Singleton Factory | Single Instance | Should Return One Instance',
        () async {
      // Arrange
      factory(Map<String, dynamic> namedArgs) async => Marble();

      // Act
      await ServiceLocator.I.registerSingletonFactory(factory);
      final instances = await ServiceLocator.I.resolveAll<Marble>();

      // Assert
      expect(instances, hasLength(1));
    });

    test(
        'Register Singleton Factory | With Interface | Should Resolve By Interface',
        () async {
      // Arrange
      factory(Map<String, dynamic> namedArgs) async => Marble();

      // Act
      await ServiceLocator.I
          .registerSingletonFactory(factory, interfaces: {Stone, Thing});
      final marbleInstances = await ServiceLocator.I.resolveAll<Marble>();
      final stoneInstances = await ServiceLocator.I.resolveAll<Stone>();
      final thingInstances = await ServiceLocator.I.resolveAll<Thing>();

      // Assert
      expect(marbleInstances, hasLength(1));
      expect(stoneInstances, hasLength(1));
      expect(thingInstances, hasLength(1));
    });

    test(
        'Register Singleton Factory | Duplicate Instances | Should Return Multiple Instances',
        () async {
      // Arrange
      factory(Map<String, dynamic> namedArgs) async => Marble();

      // Act
      await ServiceLocator.I
          .registerSingletonFactory(factory, interfaces: {Stone, Thing});
      await ServiceLocator.I
          .registerSingletonFactory(factory, interfaces: {Stone, Thing});
      final instances = await ServiceLocator.I.resolveAll<Marble>();

      // Assert
      expect(instances, hasLength(2));
    });

    test(
        'Register Singleton Factory | Multiple Different Instances | Should Return All Instances',
        () async {
      // Arrange
      marbleFactory(Map<String, dynamic> namedArgs) async => Marble();
      graniteFactory(Map<String, dynamic> namedArgs) async => Granite();

      // Act
      await ServiceLocator.I
          .registerSingletonFactory(marbleFactory, interfaces: {Stone, Thing});
      await ServiceLocator.I
          .registerSingletonFactory(graniteFactory, interfaces: {Stone, Thing});

      final stoneInstances = await ServiceLocator.I.resolveAll<Stone>();
      final thingInstances = await ServiceLocator.I.resolveAll<Thing>();

      // Assert
      expect(stoneInstances, hasLength(2));
      expect(thingInstances, hasLength(2));
    });
  });
}
