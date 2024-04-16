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

  tearDown(() async {
    await ServiceLocator.I.unregisterAll();
  });

  group('Async Singleton Registration |', () {
    test(
        'Register Singleton | No Previous Registration | Should Return Empty Set',
        () async {
      // Act
      final result = await ServiceLocator.I.resolveAll();

      // Assert
      expect(result, isEmpty);
    });

    test('Register Singleton | Single Instance | Should Return One Instance',
        () async {
      // Arrange
      final instance = Marble();

      // Act
      await ServiceLocator.I.registerSingleton(instance);
      final instances = await ServiceLocator.I.resolveAll<Marble>();

      // Assert
      expect(instances, hasLength(1));
    });

    test('Register Singleton | With Interface | Should Resolve By Interface',
        () async {
      // Arrange
      final instance = Marble();

      // Act
      await ServiceLocator.I
          .registerSingleton(instance, interfaces: {Stone, Thing});
      final marbleInstances = await ServiceLocator.I.resolveAll<Marble>();
      final stoneInstances = await ServiceLocator.I.resolveAll<Stone>();
      final thingInstances = await ServiceLocator.I.resolveAll<Thing>();

      // Assert
      expect(marbleInstances, hasLength(1));
      expect(stoneInstances, hasLength(1));
      expect(thingInstances, hasLength(1));
    });

    test(
        'Register Singleton | Duplicate Instances | Should Return Multiple Instances',
        () async {
      // Arrange
      final instance1 = Marble();
      final instance2 = Marble();

      // Act
      await ServiceLocator.I
          .registerSingleton(instance1, interfaces: {Stone, Thing});
      await ServiceLocator.I
          .registerSingleton(instance2, interfaces: {Stone, Thing});
      final instances = await ServiceLocator.I.resolveAll<Marble>();

      // Assert
      expect(instances, hasLength(2));
    });

    test(
        'Register Singleton | Multiple Different Instances | Should Return All Instances',
        () async {
      // Arrange
      final marble = Marble();
      final granite = Granite();

      // Act
      await ServiceLocator.I
          .registerSingleton(marble, interfaces: {Stone, Thing});
      await ServiceLocator.I
          .registerSingleton(granite, interfaces: {Stone, Thing});
      final stoneInstances = await ServiceLocator.I.resolveAll<Stone>();
      final thingInstances = await ServiceLocator.I.resolveAll<Thing>();

      // Assert
      expect(stoneInstances, hasLength(2));
      expect(thingInstances, hasLength(2));
    });

    test('Register Singleton | Named Instances | Should Respect Names',
        () async {
      // Arrange
      final marble = Marble();
      final granite = Granite();

      // Act
      await ServiceLocator.I.registerSingleton(marble, name: 'marble');
      await ServiceLocator.I.registerSingleton(granite, name: 'granite');
      final marbleInstance =
          await ServiceLocator.I.resolve<Marble>(name: 'marble');
      final graniteInstance =
          await ServiceLocator.I.resolve<Granite>(name: 'granite');

      // Assert
      expect(marbleInstance, isA<Marble>());
      expect(graniteInstance, isA<Granite>());
    });

    test(
        'Register Singleton | Named Instances Same Name | Should Return Multiple Instances',
        () async {
      // Arrange
      final marble1 = Marble();
      final marble2 = Marble();

      // Act
      await ServiceLocator.I.registerSingleton(marble1,
          interfaces: {Stone, Thing}, name: 'marble');
      await ServiceLocator.I.registerSingleton(marble2,
          interfaces: {Stone, Thing}, name: 'marble');
      final instances =
          await ServiceLocator.I.resolveAll<Marble>(name: 'marble');

      // Assert
      expect(instances, isNotNull);
      expect(instances, hasLength(2));
    });

    test(
        'Register Singleton | Named Instances Different Names | Should Return Multiple Unique Instances',
        () async {
      // Arrange
      final marble1 = Marble();
      final marble2 = Marble();

      // Act
      await ServiceLocator.I.registerSingleton(marble1,
          interfaces: {Stone, Thing}, name: 'marble1');
      await ServiceLocator.I.registerSingleton(marble2,
          interfaces: {Stone, Thing}, name: 'marble2');
      final instancesMarble1 =
          await ServiceLocator.I.resolveAll<Marble>(name: 'marble1');
      final instancesMarble2 =
          await ServiceLocator.I.resolveAll<Marble>(name: 'marble2');

      // Assert
      expect(instancesMarble1, isNotNull);
      expect(instancesMarble2, isNotNull);
      expect(instancesMarble1, hasLength(isNot(0)));
      expect(instancesMarble2, hasLength(isNot(0)));
      expect(instancesMarble1, isNot(same(instancesMarble2)));
    });
  });

  group('Async Singleton Resolution |', () {
    test('Resolve Instance | Unregistered Service | Should Throw StateError',
        () {
      // Act & Assert
      expect(() async => await ServiceLocator.I.resolve<Spider>(),
          throwsA(isA<StateError>()));
    });

    test('Resolve Instance | Unregistered Service | Should Return Null',
        () async {
      // Act
      final instance = await ServiceLocator.I.resolveOrNull<Spider>();

      // Assert
      expect(instance, isNull);
    });

    test('Resolve Instance | Registered Chicken | Should Return Chicken',
        () async {
      // Arrange
      final walkService = WalkService();
      final eatingService = EatingService();
      await ServiceLocator.I
          .registerSingleton(Chicken(walkService, eatingService));

      // Act
      final instance = await ServiceLocator.I.resolve<Chicken>();

      // Assert
      expect(instance, isA<Chicken>());
    });

    test(
        'Resolve Multiple Instances | Animals and Fish | Should Return Correct Counts',
        () async {
      // Arrange
      final walkService = WalkService();
      final eatingService = EatingService();

      await ServiceLocator.I.registerSingleton(
          Chicken(walkService, eatingService),
          interfaces: {Bird, Animal});
      await ServiceLocator.I.registerSingleton(
          Dolphin(SwimService(), eatingService),
          interfaces: {Animal, Fish});
      await ServiceLocator.I.registerSingleton(
          Eagle(FlightService(), eatingService),
          interfaces: {Bird, Animal});
      await ServiceLocator.I.registerSingleton(
          Shark(SwimService(), eatingService),
          interfaces: {Animal, Fish});
      await ServiceLocator.I.registerSingleton(
          Whale(SwimService(), eatingService),
          interfaces: {Animal, Fish});

      // Act
      final animalInstances = await ServiceLocator.I.resolveAll<Animal>();
      final fishInstances = await ServiceLocator.I.resolveAll<Fish>();

      // Assert
      expect(animalInstances, isA<Set<Animal>>());
      expect(
          animalInstances,
          hasLength(
              5)); // Update the count based on the actual number of Animal registrations
      expect(fishInstances, isA<Set<Fish>>());
      expect(
          fishInstances,
          hasLength(
              3)); // Update the count based on the actual number of Fish registrations
    });
  });
}
