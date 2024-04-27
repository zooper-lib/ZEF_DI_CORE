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
      final instance = NoDepencenciesWithInterface();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceOne});

      final resolvedInstance =
          await ServiceLocator.I.resolve<NoDepencenciesWithInterface>();

      // Assert
      expect(resolvedInstance, isA<NoDepencenciesWithInterface>());
    });

    test('Not Implementing Interface | Should Resolve', () async {
      // Arrange
      final instance = NoDepencenciesWithInterface();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceTwo});

      final resolvedInstance =
          await ServiceLocator.I.resolve<NoDepencenciesWithInterface>();

      // Assert
      expect(resolvedInstance, isA<NoDepencenciesWithInterface>());
    });

    test('Multiple Interfaces | Should Resolve', () async {
      // Arrange
      final instance = NoDepencenciesWithMultipleInterfaces();

      // Act
      ServiceLocator.I.registerSingleton(instance,
          interfaces: {InterfaceOne, InterfaceTwo});

      final resolvedInstance = await ServiceLocator.I
          .resolve<NoDepencenciesWithMultipleInterfaces>();

      // Assert
      expect(resolvedInstance, isA<NoDepencenciesWithMultipleInterfaces>());
    });
  });

  group('Interface Resolution', () {
    test('Single Interface | Should Resolve', () async {
      // Arrange
      final instance = NoDepencenciesWithInterface();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceOne});

      final resolvedInstance = await ServiceLocator.I.resolve<InterfaceOne>();

      // Assert
      expect(resolvedInstance, isA<NoDepencenciesWithInterface>());
    });

    test('Not Implementing Interface | Should Not Resolve', () async {
      // Arrange
      final instance = NoDepencenciesWithInterface();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceTwo});

      final resolvedInstance =
          await ServiceLocator.I.resolveOrNull<InterfaceOne>();

      // Assert
      expect(resolvedInstance, isNull);
    });

    test('Not Implementing Interface | Should Throw Error', () async {
      // Arrange
      final instance = NoDepencenciesWithInterface();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {InterfaceOne});

      // Assert
      expect(() async => await ServiceLocator.I.resolve<InterfaceTwo>(),
          throwsA(isA<StateError>()));
    });

    test('Multiple Interfaces | Should Resolve', () async {
      // Arrange
      final instance = NoDepencenciesWithMultipleInterfaces();

      // Act
      ServiceLocator.I.registerSingleton(instance,
          interfaces: {InterfaceOne, InterfaceTwo});

      final resolvedInstance = await ServiceLocator.I.resolve<InterfaceOne>();

      // Assert
      expect(resolvedInstance, isA<NoDepencenciesWithMultipleInterfaces>());
    });

    test('Multiple Registered Concretes | Should Resolve All By Interface',
        () async {
      // Arrange
      final instanceOne = NoDepencenciesWithMultipleInterfaces();
      final instanceTwo = NoDepencenciesWithMultipleInterfaces();

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
      final instanceOne = NoDepencenciesWithMultipleInterfaces();
      final instanceTwo = NoDepencenciesWithMultipleInterfaces();

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
