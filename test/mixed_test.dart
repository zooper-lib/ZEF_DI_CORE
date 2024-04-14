import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zef_di_core/zef_di_core.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/services.dart';

class MockWalkService extends Mock implements WalkService {}

class MockEatingService extends Mock implements EatingService {}

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAllSync();
  });

  group('Combined Registrations |', () {
    test('Singleton, Transient, and Lazy | Mix Registration Types | Should Resolve Correctly', () {
      // Arrange - Singleton
      final singletonService = Marble();
      ServiceLocator.I.registerSingletonSync(singletonService);

      // Arrange - Transient
      ServiceLocator.I.registerTransientSync<WalkService>(
        (locator, namedArgs) => WalkService(),
      );

      // Arrange - Lazy
      final lazyService = Lazy<EatingService>(factory: () => EatingService());
      ServiceLocator.I.registerLazySync<EatingService>(lazyService);

      // Act & Assert - Singleton
      final resolvedSingleton = ServiceLocator.I.resolveSync<Marble>();
      expect(resolvedSingleton, isNotNull);
      expect(resolvedSingleton, isA<Marble>());

      // Act & Assert - Transient
      final resolvedTransientService = ServiceLocator.I.resolveSync<WalkService>();
      expect(resolvedTransientService, isNotNull);
      expect(resolvedTransientService, isA<WalkService>());

      // Act & Assert - Lazy
      final resolvedLazyService = ServiceLocator.I.resolveSync<EatingService>();
      expect(resolvedLazyService, isNotNull);
      expect(resolvedLazyService, isA<EatingService>());
    });

    test('Singleton and Lazy | Register Both | Should Resolve First Registered', () {
      // Arrange - Singleton
      final singletonService = Granite();
      ServiceLocator.I.registerSingletonSync(singletonService);

      // Arrange - Lazy
      final lazyService = Lazy<Granite>(factory: () => Granite());
      ServiceLocator.I.registerLazySync<Granite>(lazyService);

      // Act
      final resolvedService = ServiceLocator.I.resolveSync<Granite>();

      // Assert
      expect(resolvedService, isNotNull);
      expect(resolvedService, isA<Granite>());
      // Ensure the resolved instance is the singleton, not the lazy-initialized one
      expect(identical(resolvedService, singletonService), isTrue);
    });

    test('Transient and Lazy | Combine for Dynamic Resolution | Should Resolve Both Correctly', () {
      // Arrange - Transient
      ServiceLocator.I.registerTransientSync<FlightService>(
        (locator, namedArgs) => FlightService(),
      );

      // Arrange - Lazy
      final lazyService = Lazy<SwimService>(factory: () => SwimService());
      ServiceLocator.I.registerLazySync<SwimService>(lazyService);

      // Act & Assert - Transient
      final resolvedTransientService = ServiceLocator.I.resolveSync<FlightService>();
      expect(resolvedTransientService, isNotNull);
      expect(resolvedTransientService, isA<FlightService>());

      // Act & Assert - Lazy
      final resolvedLazyService = ServiceLocator.I.resolveSync<SwimService>();
      expect(resolvedLazyService, isNotNull);
      expect(resolvedLazyService, isA<SwimService>());
    });
  });

  group('Recursive Service Resolution |', () {
    test('Resolve Service with Dependencies | Different Registration Types | Should Invoke Dependency Methods', () {
      // Arrange - Mocked services
      final mockWalkService = MockWalkService();
      final mockEatingService = MockEatingService();

      // Arrange - Register mocked services
      ServiceLocator.I.registerSingletonSync<MovementService>(mockWalkService);
      ServiceLocator.I.registerLazySync<EatingService>(Lazy<EatingService>(factory: () => mockEatingService));

      // Arrange - Transient for Chicken that depends on both MovementService and EatingService
      ServiceLocator.I.registerTransientSync<Chicken>(
        (locator, namedArgs) => Chicken(
          locator.resolveSync<MovementService>(),
          locator.resolveSync<EatingService>(),
        ),
      );

      // Act
      final chicken = ServiceLocator.I.resolveSync<Chicken>();
      chicken.doSomething();
      chicken.doSomethingElse();

      // Assert
      verify(mockWalkService.move()).called(1);
      verify(mockEatingService.eat()).called(1);
    });
  });
}
