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

  tearDown(() async {
    ServiceLocator.I.unregisterAll();
  });

  group('registerLazy', () {
    test(
        'registerLazy | Uninstantiated Lazy Service | Should Not Instantiate Service',
        () async {
      var initializationCounter = 0;
      await ServiceLocator.I
          .registerLazy<WalkService>(Lazy<WalkService>(factory: () {
        initializationCounter++;
        return WalkService();
      }));

      expect(initializationCounter, 0);
    });

    test('registerLazy | First Resolve | Should Instantiate Service Once',
        () async {
      var initializationCounter = 0;
      await ServiceLocator.I
          .registerLazy<WalkService>(Lazy<WalkService>(factory: () {
        initializationCounter++;
        return WalkService();
      }));

      await ServiceLocator.I.resolve<WalkService>();
      expect(initializationCounter, 1);
    });

    test('registerLazy | After Expiry | Should Re-Instantiate Service',
        () async {
      var initializationCounter = 0;
      await ServiceLocator.I.registerLazy<WalkService>(Lazy<WalkService>(
        factory: () {
          initializationCounter++;
          return WalkService();
        },
        expiryDuration: Duration(milliseconds: 100),
      ));

      await ServiceLocator.I.resolve<WalkService>();
      await Future.delayed(Duration(milliseconds: 150));
      await ServiceLocator.I.resolve<WalkService>();

      expect(initializationCounter, 2);
    });

    test('registerLazy | Named Registrations | Should Respect Names', () async {
      var lazyMarble = Lazy<Marble>(factory: () => Marble());
      var lazyGranite = Lazy<Granite>(factory: () => Granite());

      await ServiceLocator.I.registerLazy<Marble>(lazyMarble, name: 'marble');
      await ServiceLocator.I
          .registerLazy<Granite>(lazyGranite, name: 'granite');

      var marbleInstance =
          await ServiceLocator.I.resolve<Marble>(name: 'marble');
      var graniteInstance =
          await ServiceLocator.I.resolve<Granite>(name: 'granite');

      expect(marbleInstance, isA<Marble>());
      expect(graniteInstance, isA<Granite>());
    });

    test('resolve | Unregistered Service | Should Throw StateError', () {
      expect(() async => await ServiceLocator.I.resolve<NonInjectableService>(),
          throwsA(isA<StateError>()));
    });

    test(
        'registerLazy | Resolve Multiple Instances | Should Return Same Initialized Instance',
        () async {
      var lazyService = Lazy<WalkService>(factory: () => WalkService());
      await ServiceLocator.I.registerLazy<WalkService>(lazyService);

      var firstInstance = await ServiceLocator.I.resolve<WalkService>();
      var secondInstance = await ServiceLocator.I.resolve<WalkService>();

      expect(firstInstance, same(secondInstance),
          reason:
              'Multiple resolves should return the same instance for a lazily registered service.');
    });

    // TODO: Reimplement this test
    /* test(
        'registerLazy | Resolve Service with Dependencies | Should Inject Dependencies',
        () async {
      var lazyChicken = Lazy<Chicken>(
        factory: () => Chicken(
          ServiceLocator.I.resolve<WalkService>(),
          ServiceLocator.I.resolve<EatingService>(),
        ),
      );
      await ServiceLocator.I.registerLazy<WalkService>(
          Lazy<WalkService>(factory: () => WalkService()));
      await ServiceLocator.I.registerLazy<EatingService>(
          Lazy<EatingService>(factory: () => EatingService()));
      await ServiceLocator.I.registerLazy<Chicken>(lazyChicken);

      var chickenInstance = await ServiceLocator.I.resolve<Chicken>();
      expect(chickenInstance, isNotNull);
      expect(() => chickenInstance.doSomething(), returnsNormally);
      expect(() => chickenInstance.doSomethingElse(), returnsNormally);
    }); */

    test('registerLazy | Manual Reset | Should Re-Initialize Service',
        () async {
      var initializationCounter = 0;
      var lazyService = Lazy<WalkService>(factory: () {
        initializationCounter++;
        return WalkService();
      });

      await ServiceLocator.I.registerLazy<WalkService>(lazyService);

      // First resolve to initialize the service
      await ServiceLocator.I.resolve<WalkService>();
      expect(initializationCounter, 1);

      // Manually reset or re-initialize the service here
      lazyService.reset();

      // Resolve again and expect the service to re-initialize
      await ServiceLocator.I.resolve<WalkService>();
      expect(initializationCounter, 2,
          reason: 'Service should be re-initialized after manual reset.');
    });
  });

  group('Lazy registrations with mocked dependencies', () {
    test(
        'resolve | With Mocked Dependencies | Chicken Should Utilize Mocked Services',
        () async {
      // Set up mock expectations
      when(mockMovementService.move()).thenReturn(null);
      when(mockEatingService.eat()).thenReturn(null);

      var lazyChicken = Lazy<Chicken>(
          factory: () => Chicken(mockMovementService, mockEatingService));
      ServiceLocator.I.registerLazy<Chicken>(lazyChicken,
          interfaces: null, name: null, key: null, environment: null);

      var chickenInstance = await ServiceLocator.I.resolve<Chicken>();
      expect(chickenInstance, isNotNull);

      chickenInstance.doSomething();
      verify(mockMovementService.move()).called(1);

      chickenInstance.doSomethingElse();
      verify(mockEatingService.eat()).called(1);
    });
  });
}
