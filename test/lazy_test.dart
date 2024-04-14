import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zef_di_core/zef_di_core.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/services.dart';

// Create Mock classes
class MockMovementService extends Mock implements MovementService {}

class MockEatingService extends Mock implements EatingService {}

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  late MockMovementService mockMovementService;
  late MockEatingService mockEatingService;

  setUp(() {
    mockMovementService = MockMovementService();
    mockEatingService = MockEatingService();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAllSync();
  });

  group('registerLazy', () {
    test('registerLazy | Uninstantiated Lazy Service | Should Not Instantiate Service', () {
      var initializationCounter = 0;
      ServiceLocator.I.registerLazySync<WalkService>(Lazy<WalkService>(factory: () {
        initializationCounter++;
        return WalkService();
      }));

      expect(initializationCounter, 0);
    });

    test('registerLazy | First Resolve | Should Instantiate Service Once', () {
      var initializationCounter = 0;
      ServiceLocator.I.registerLazySync<WalkService>(Lazy<WalkService>(factory: () {
        initializationCounter++;
        return WalkService();
      }));

      ServiceLocator.I.resolveSync<WalkService>();
      expect(initializationCounter, 1);
    });

    test('registerLazy | After Expiry | Should Re-Instantiate Service', () async {
      var initializationCounter = 0;
      ServiceLocator.I.registerLazySync<WalkService>(Lazy<WalkService>(
        factory: () {
          initializationCounter++;
          return WalkService();
        },
        expiryDuration: Duration(milliseconds: 100),
      ));

      ServiceLocator.I.resolveSync<WalkService>();
      await Future.delayed(Duration(milliseconds: 150));
      ServiceLocator.I.resolveSync<WalkService>();

      expect(initializationCounter, 2);
    });

    test('registerLazy | Named Registrations | Should Respect Names', () {
      var lazyMarble = Lazy<Marble>(factory: () => Marble());
      var lazyGranite = Lazy<Granite>(factory: () => Granite());

      ServiceLocator.I.registerLazySync<Marble>(lazyMarble, name: 'marble');
      ServiceLocator.I.registerLazySync<Granite>(lazyGranite, name: 'granite');

      var marbleInstance = ServiceLocator.I.resolveSync<Marble>(name: 'marble');
      var graniteInstance = ServiceLocator.I.resolveSync<Granite>(name: 'granite');

      expect(marbleInstance, isA<Marble>());
      expect(graniteInstance, isA<Granite>());
    });

    test('resolve | Unregistered Service | Should Throw StateError', () {
      expect(() => ServiceLocator.I.resolveSync<NonInjectableService>(), throwsA(isA<StateError>()));
    });

    test('registerLazy | Resolve Multiple Instances | Should Return Same Initialized Instance', () {
      var lazyService = Lazy<WalkService>(factory: () => WalkService());
      ServiceLocator.I.registerLazySync<WalkService>(lazyService);

      var firstInstance = ServiceLocator.I.resolveSync<WalkService>();
      var secondInstance = ServiceLocator.I.resolveSync<WalkService>();

      expect(firstInstance, same(secondInstance), reason: 'Multiple resolves should return the same instance for a lazily registered service.');
    });

    test('registerLazy | Resolve Service with Dependencies | Should Inject Dependencies', () {
      var lazyChicken = Lazy<Chicken>(factory: () => Chicken(ServiceLocator.I.resolveSync<WalkService>(), ServiceLocator.I.resolveSync<EatingService>()));
      ServiceLocator.I.registerLazySync<WalkService>(Lazy<WalkService>(factory: () => WalkService()));
      ServiceLocator.I.registerLazySync<EatingService>(Lazy<EatingService>(factory: () => EatingService()));
      ServiceLocator.I.registerLazySync<Chicken>(lazyChicken);

      var chickenInstance = ServiceLocator.I.resolveSync<Chicken>();
      expect(chickenInstance, isNotNull);
      expect(() => chickenInstance.doSomething(), returnsNormally);
      expect(() => chickenInstance.doSomethingElse(), returnsNormally);
    });

    test('registerLazy | Manual Reset | Should Re-Initialize Service', () {
      var initializationCounter = 0;
      var lazyService = Lazy<WalkService>(factory: () {
        initializationCounter++;
        return WalkService();
      });

      ServiceLocator.I.registerLazySync<WalkService>(lazyService);

      // First resolve to initialize the service
      ServiceLocator.I.resolveSync<WalkService>();
      expect(initializationCounter, 1);

      // Manually reset or re-initialize the service here
      lazyService.reset();

      // Resolve again and expect the service to re-initialize
      ServiceLocator.I.resolveSync<WalkService>();
      expect(initializationCounter, 2, reason: 'Service should be re-initialized after manual reset.');
    });
  });

  group('Lazy registrations with mocked dependencies', () {
    test('resolve | With Mocked Dependencies | Chicken Should Utilize Mocked Services', () {
      // Set up mock expectations
      when(mockMovementService.move()).thenReturn(null);
      when(mockEatingService.eat()).thenReturn(null);

      var lazyChicken = Lazy<Chicken>(factory: () => Chicken(mockMovementService, mockEatingService));
      ServiceLocator.I.registerLazySync<Chicken>(lazyChicken, interfaces: null, name: null, key: null, environment: null);

      var chickenInstance = ServiceLocator.I.resolveSync<Chicken>();
      expect(chickenInstance, isNotNull);

      chickenInstance.doSomething();
      verify(mockMovementService.move()).called(1);

      chickenInstance.doSomethingElse();
      verify(mockEatingService.eat()).called(1);
    });
  });
}
