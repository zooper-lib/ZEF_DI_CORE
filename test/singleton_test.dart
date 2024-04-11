import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:zef_di_core/zef_di_core.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/interfaces.dart';
import 'test_classes/services.dart';

class MockMovementService extends Mock implements MovementService {}

class MockEatingService extends Mock implements EatingService {}

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAll();
  });

  group('Singleton Registration |', () {
    test('Register Singleton | No Previous Registration | Should Return Empty Set', () {
      // Act
      final result = ServiceLocator.I.resolveAll();

      // Assert
      expect(result, isEmpty);
    });

    test('Register Singleton | Single Instance | Should Return One Instance', () {
      // Arrange
      final instance = Marble();

      // Act
      ServiceLocator.I.registerSingleton(instance);
      final instances = ServiceLocator.I.resolveAll<Marble>();

      // Assert
      expect(instances.length, 1);
    });

    test('Register Singleton | With Interface | Should Resolve By Interface', () {
      // Arrange
      final instance = Marble();

      // Act
      ServiceLocator.I.registerSingleton(instance, interfaces: {Stone, Thing});
      final marbleInstances = ServiceLocator.I.resolveAll<Marble>();
      final stoneInstances = ServiceLocator.I.resolveAll<Stone>();
      final thingInstances = ServiceLocator.I.resolveAll<Thing>();

      // Assert
      expect(marbleInstances.length, 1);
      expect(stoneInstances.length, 1);
      expect(thingInstances.length, 1);
    });

    test('Register Singleton | Duplicate Instances | Should Return Multiple Instances', () {
      // Arrange
      final instance1 = Marble();
      final instance2 = Marble();

      // Act
      ServiceLocator.I.registerSingleton(instance1, interfaces: {Stone, Thing});
      ServiceLocator.I.registerSingleton(instance2, interfaces: {Stone, Thing});
      final instances = ServiceLocator.I.resolveAll<Marble>();

      // Assert
      expect(instances.length, 2);
    });

    test('Register Singleton | Multiple Different Instances | Should Return All Instances', () {
      // Arrange
      final marble = Marble();
      final granite = Granite();

      // Act
      ServiceLocator.I.registerSingleton(marble, interfaces: {Stone, Thing});
      ServiceLocator.I.registerSingleton(granite, interfaces: {Stone, Thing});
      final stoneInstances = ServiceLocator.I.resolveAll<Stone>();
      final thingInstances = ServiceLocator.I.resolveAll<Thing>();

      // Assert
      expect(stoneInstances.length, 2);
      expect(thingInstances.length, 2);
    });

    test('Register Singleton | Named Instances | Should Respect Names', () {
      // Arrange
      final marble = Marble();
      final granite = Granite();

      // Act
      ServiceLocator.I.registerSingleton(marble, name: 'marble');
      ServiceLocator.I.registerSingleton(granite, name: 'granite');
      final marbleInstance = ServiceLocator.I.resolve<Marble>(name: 'marble');
      final graniteInstance = ServiceLocator.I.resolve<Granite>(name: 'granite');

      // Assert
      expect(marbleInstance, isA<Marble>());
      expect(graniteInstance, isA<Granite>());
    });

    test('Register Singleton | Named Instances Same Name | Should Return Multiple Instances', () {
      // Arrange
      final marble1 = Marble();
      final marble2 = Marble();

      // Act
      ServiceLocator.I.registerSingleton(marble1, interfaces: {Stone, Thing}, name: 'marble');
      ServiceLocator.I.registerSingleton(marble2, interfaces: {Stone, Thing}, name: 'marble');
      final instances = ServiceLocator.I.resolveAll<Marble>(name: 'marble');

      // Assert
      expect(instances, isNotNull);
      expect(instances.length, 2);
    });

    test('Register Singleton | Named Instances Different Names | Should Return Multiple Unique Instances', () {
      // Arrange
      final marble1 = Marble();
      final marble2 = Marble();

      // Act
      ServiceLocator.I.registerSingleton(marble1, interfaces: {Stone, Thing}, name: 'marble1');
      ServiceLocator.I.registerSingleton(marble2, interfaces: {Stone, Thing}, name: 'marble2');
      final instancesMarble1 = ServiceLocator.I.resolveAll<Marble>(name: 'marble1');
      final instancesMarble2 = ServiceLocator.I.resolveAll<Marble>(name: 'marble2');

      // Assert
      expect(instancesMarble1, isNotNull);
      expect(instancesMarble2, isNotNull);
      expect(instancesMarble1.length, isNot(0));
      expect(instancesMarble2.length, isNot(0));
      expect(instancesMarble1.first, isNot(same(instancesMarble2.first)));
    });
  });

  group('Singleton Resolution |', () {
    test('Resolve Instance | Unregistered Service | Should Throw StateError', () {
      // Act & Assert
      expect(() => ServiceLocator.I.resolve<Spider>(), throwsA(isA<StateError>()));
    });

    test('Resolve Instance | Unregistered Service | Should Return Null', () {
      // Act
      final instance = ServiceLocator.I.resolveOrNull<Spider>();

      // Assert
      expect(instance, isNull);
    });

    test('Resolve Instance | Registered Chicken | Should Return Chicken', () {
      // Arrange
      final walkService = WalkService();
      final eatingService = EatingService();
      ServiceLocator.I.registerSingleton(Chicken(walkService, eatingService));

      // Act
      final instance = ServiceLocator.I.resolve<Chicken>();

      // Assert
      expect(instance, isA<Chicken>());
    });

    test('Resolve Multiple Instances | Animals and Fish | Should Return Correct Counts', () {
      // Arrange
      final walkService = WalkService();
      final eatingService = EatingService();

      ServiceLocator.I.registerSingleton(Chicken(walkService, eatingService), interfaces: {Bird, Animal});
      ServiceLocator.I.registerSingleton(Dolphin(SwimService(), eatingService), interfaces: {Animal, Fish});
      ServiceLocator.I.registerSingleton(Eagle(FlightService(), eatingService), interfaces: {Bird, Animal});
      ServiceLocator.I.registerSingleton(Shark(SwimService(), eatingService), interfaces: {Animal, Fish});
      ServiceLocator.I.registerSingleton(Whale(SwimService(), eatingService), interfaces: {Animal, Fish});

      // Act
      final animalInstances = ServiceLocator.I.resolveAll<Animal>();
      final fishInstances = ServiceLocator.I.resolveAll<Fish>();

      // Assert
      expect(animalInstances, isA<Set<Animal>>());
      expect(animalInstances.length, 5); // Update the count based on the actual number of Animal registrations
      expect(fishInstances, isA<Set<Fish>>());
      expect(fishInstances.length, 3); // Update the count based on the actual number of Fish registrations
    });
  });
}
