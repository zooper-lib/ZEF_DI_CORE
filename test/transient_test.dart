import 'package:test/test.dart';
import 'package:zef_di_core/zef_di_core.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/interfaces.dart';
import 'test_classes/services.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAllSync();
  });

  group('Async Transient Registration |', () {
    test('Register Transient | Eagle | Should Resolve Eagle Instance', () async {
      // Arrange
      await ServiceLocator.I.registerSingleton<FlightService>(FlightService(), interfaces: {MovementService});
      await ServiceLocator.I.registerSingleton<EatingService>(EatingService());

      // Act
      await ServiceLocator.I.registerTransient<Eagle>(
        (serviceLocator, namedArgs) async => Eagle(
          serviceLocator.resolveSync<FlightService>(),
          serviceLocator.resolveSync<EatingService>(),
        ),
        interfaces: {Bird, Animal, Thing},
      );

      final eagleInstances = await ServiceLocator.I.resolveAll<Eagle>();

      // Assert
      expect(eagleInstances, isNotNull);
      expect(eagleInstances.length, 1);
    });

    test('Register Transient | InvalidThing | Should Warn About Injection', () async {
      // Arrange
      await ServiceLocator.I.registerTransient<InvalidThing>(
        (serviceLocator, namedArgs) {
          throw Exception('Dependency Injection failed for InvalidThing.');
        },
        interfaces: {Thing},
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolve<InvalidThing>(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Sync Transient Registration |', () {
    test('Register Transient | Eagle | Should Resolve Eagle Instance', () {
      // Arrange
      ServiceLocator.I.registerSingletonSync<FlightService>(FlightService(), interfaces: {MovementService});
      ServiceLocator.I.registerSingletonSync<EatingService>(EatingService());

      // Act
      ServiceLocator.I.registerTransientSync<Eagle>(
        (serviceLocator, namedArgs) => Eagle(
          serviceLocator.resolveSync<FlightService>(),
          serviceLocator.resolveSync<EatingService>(),
        ),
        interfaces: {Bird, Animal, Thing},
      );

      final eagleInstances = ServiceLocator.I.resolveAllSync<Eagle>();

      // Assert
      expect(eagleInstances, isNotNull);
      expect(eagleInstances.length, 1);
    });

    test('Register Transient | InvalidThing | Should Warn About Injection', () {
      // Arrange
      ServiceLocator.I.registerTransientSync<InvalidThing>(
        (serviceLocator, namedArgs) {
          throw Exception('Dependency Injection failed for InvalidThing.');
        },
        interfaces: {Thing},
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolveSync<InvalidThing>(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Sync Transient Resolution |', () {
    test('Resolve Transient | MovementService | Should Resolve WalkService', () {
      // Arrange
      ServiceLocator.I.registerSingletonSync<WalkService>(WalkService(), interfaces: {MovementService});

      // Act
      final walkService = ServiceLocator.I.resolveSync<MovementService>();

      // Assert
      expect(walkService, isA<WalkService>());
    });

    test('Resolve Transient With Parameters | ServiceWithParameters | Should Resolve Correctly', () {
      // Arrange
      ServiceLocator.I.registerSingletonSync<WalkService>(WalkService(), interfaces: {MovementService});
      ServiceLocator.I.registerTransientSync<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolveSync<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act
      final serviceWithParameters = ServiceLocator.I.resolveSync<ServiceWithParameters>(
        namedArgs: {'passedParam': 'exampleValue'},
      );

      // Assert
      expect(serviceWithParameters, isNotNull);
      expect(serviceWithParameters.passedParam, equals('exampleValue'));
    });

    test('Resolve Transient With Excess Parameters | ServiceWithParameters | Should Still Resolve', () {
      // Arrange
      ServiceLocator.I.registerSingletonSync<WalkService>(WalkService(), interfaces: {MovementService});
      ServiceLocator.I.registerTransientSync<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolveSync<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolveSync<ServiceWithParameters>(
          namedArgs: {'passedParam': 'exampleValue', 'tooMany': 'extraValue'},
        ),
        returnsNormally,
      );
    });

    test('Resolve Transient With Incorrect Parameters | ServiceWithParameters | Should Throw TypeError', () {
      // Arrange
      ServiceLocator.I.registerSingletonSync<WalkService>(WalkService(), interfaces: {MovementService});
      ServiceLocator.I.registerTransientSync<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolveSync<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolveSync<ServiceWithParameters>(
          namedArgs: {'wrongParameter': 'exampleValue'},
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
