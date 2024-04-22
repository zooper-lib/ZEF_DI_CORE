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

  tearDown(() async {
    await ServiceLocator.I.unregisterAll();
  });

  group('Async Transient Registration |', () {
    test('Register Transient | Eagle | Should Resolve Eagle Instance',
        () async {
      // Arrange
      await ServiceLocator.I.registerSingleton<FlightService>(FlightService(),
          interfaces: {MovementService});
      await ServiceLocator.I.registerSingleton<EatingService>(EatingService());

      // Act
      await ServiceLocator.I.registerTransient<Eagle>(
        (namedArgs) async => Eagle(
          await ServiceLocator.I.resolve<FlightService>(),
          await ServiceLocator.I.resolve<EatingService>(),
        ),
        interfaces: {Bird, Animal, Thing},
      );

      final eagleInstances = await ServiceLocator.I.resolveAll<Eagle>();

      // Assert
      expect(eagleInstances, isNotNull);
      expect(eagleInstances.length, 1);
    });

    test('Register Transient | InvalidThing | Should Warn About Injection',
        () async {
      // Arrange
      await ServiceLocator.I.registerTransient<InvalidThing>(
        (namedArgs) {
          throw Exception('Dependency Injection failed for InvalidThing.');
        },
        interfaces: {Thing},
      );

      // Act & Assert
      expect(
        () async => await ServiceLocator.I.resolve<InvalidThing>(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Async Transient Resolution |', () {
    test('Resolve Transient | MovementService | Should Resolve WalkService',
        () async {
      // Arrange
      await ServiceLocator.I.registerSingleton<WalkService>(WalkService(),
          interfaces: {MovementService});

      // Act
      final walkService = await ServiceLocator.I.resolve<MovementService>();

      // Assert
      expect(walkService, isA<WalkService>());
    });

    test(
        'Resolve Transient With Parameters | ServiceWithParameters | Should Resolve Correctly',
        () async {
      // Arrange
      await ServiceLocator.I.registerSingleton<WalkService>(WalkService(),
          interfaces: {MovementService});
      await ServiceLocator.I.registerTransient<ServiceWithParameters>(
        (namedArgs) async => ServiceWithParameters(
          await ServiceLocator.I.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act
      final serviceWithParameters =
          await ServiceLocator.I.resolve<ServiceWithParameters>(
        namedArgs: {'passedParam': 'exampleValue'},
      );

      // Assert
      expect(serviceWithParameters, isNotNull);
      expect(serviceWithParameters.passedParam, equals('exampleValue'));
    });

    test(
        'Resolve Transient With Excess Parameters | ServiceWithParameters | Should Still Resolve',
        () async {
      // Arrange
      await ServiceLocator.I.registerSingleton<WalkService>(WalkService(),
          interfaces: {MovementService});
      await ServiceLocator.I.registerTransient<ServiceWithParameters>(
        (namedArgs) async => ServiceWithParameters(
          await ServiceLocator.I.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act & Assert
      expect(
        () async => await ServiceLocator.I.resolve<ServiceWithParameters>(
          namedArgs: {'passedParam': 'exampleValue', 'tooMany': 'extraValue'},
        ),
        returnsNormally,
      );
    });

    test(
        'Resolve Transient With Incorrect Parameters | ServiceWithParameters | Should Throw TypeError',
        () async {
      // Arrange
      await ServiceLocator.I.registerSingleton<WalkService>(WalkService(),
          interfaces: {MovementService});
      await ServiceLocator.I.registerTransient<ServiceWithParameters>(
        (namedArgs) async => ServiceWithParameters(
          await ServiceLocator.I.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act & Assert
      expect(
        () async => await ServiceLocator.I.resolve<ServiceWithParameters>(
          namedArgs: {'wrongParameter': 'exampleValue'},
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
