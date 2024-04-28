import 'package:test/test.dart';
import 'package:zef_di_core/src/abstractions/service_locator.dart';

import 'setup.dart';
import 'test_classes/classes.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() async {
    await ServiceLocator.I.unregisterAll();
  });

  group('Concrete Resolution', () {
    test('Single Interface | Should Resolve', () async {
      // Arrange
      final instance = InterfaceOneImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceOne});

      final resolvedInstance =
          await ServiceLocator.I.resolve<InterfaceOneImplementer>();

      // Assert
      expect(resolvedInstance, isA<InterfaceOneImplementer>());
    });

    test('Not Implementing Interface | Should Resolve', () async {
      // Arrange
      final instance = InterfaceOneImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceTwo});

      final resolvedInstance =
          await ServiceLocator.I.resolve<InterfaceOneImplementer>();

      // Assert
      expect(resolvedInstance, isA<InterfaceOneImplementer>());
    });

    test('Multiple Interfaces | Should Resolve', () async {
      // Arrange
      final instance = MultiInterfaceImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance,
          interfaces: {InterfaceOne, InterfaceTwo});

      final resolvedInstance =
          await ServiceLocator.I.resolve<MultiInterfaceImplementer>();

      // Assert
      expect(resolvedInstance, isA<MultiInterfaceImplementer>());
    });
  });

  group('Interface Resolution', () {
    test('Single Interface | Should Resolve', () async {
      // Arrange
      final instance = InterfaceOneImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceOne});

      final resolvedInstance = await ServiceLocator.I.resolve<InterfaceOne>();

      // Assert
      expect(resolvedInstance, isA<InterfaceOneImplementer>());
    });

    test('Not Implementing Interface | Should Throw StateError', () async {
      // Arrange
      final instance = InterfaceOneImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceTwo});

      final resolvedInstance =
          await ServiceLocator.I.resolveOrNull<InterfaceOne>();

      // Assert
      expect(resolvedInstance, isNull);
    });

    test('Not Implementing Interface | Should Throw Error', () async {
      // Arrange
      final instance = InterfaceOneImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceOne});

      // Assert
      expect(() async => await ServiceLocator.I.resolve<InterfaceTwo>(),
          throwsA(isA<StateError>()));
    });

    test('Multiple Interfaces | Should Resolve', () async {
      // Arrange
      final instance = MultiInterfaceImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instance,
          interfaces: {InterfaceOne, InterfaceTwo});

      final resolvedInstance = await ServiceLocator.I.resolve<InterfaceOne>();

      // Assert
      expect(resolvedInstance, isA<MultiInterfaceImplementer>());
    });

    test('Multiple Registered Concretes | Should Resolve All By Interface',
        () async {
      // Arrange
      final instanceOne = MultiInterfaceImplementer();
      final instanceTwo = MultiInterfaceImplementer();

      // Act
      ServiceLocator.I.registerSingleton(instanceOne,
          interfaces: {InterfaceOne, InterfaceTwo});
      ServiceLocator.I.registerSingleton(instanceTwo,
          interfaces: {InterfaceOne, InterfaceTwo});

      final resolvedInstancesOne =
          await ServiceLocator.I.resolveAll<InterfaceOne>();
      final resolvedInstancesTwo =
          await ServiceLocator.I.resolveAll<InterfaceTwo>();

      // Assert
      expect(resolvedInstancesOne.length, 2);
      expect(resolvedInstancesTwo.length, 2);
    });

    test('Multiple Registered Interfaces | Should Resolve Correct', () async {
      // Arrange
      final instanceOne = MultiInterfaceImplementer();
      final instanceTwo = MultiInterfaceImplementer();

      // Act
      ServiceLocator.I
          .registerSingleton(instanceOne, interfaces: {InterfaceOne});
      ServiceLocator.I.registerSingleton(instanceTwo,
          interfaces: {InterfaceOne, InterfaceTwo});

      final resolvedInstancesOne =
          await ServiceLocator.I.resolveAll<InterfaceOne>();
      final resolvedInstancesTwo =
          await ServiceLocator.I.resolveAll<InterfaceTwo>();

      // Assert
      expect(resolvedInstancesOne.length, 2);
      expect(resolvedInstancesTwo.length, 1);
    });
  });
}
