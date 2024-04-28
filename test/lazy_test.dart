import 'package:test/test.dart';
import 'package:zef_di_core/zef_di_core.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';
import 'setup.dart';
import 'test_classes/classes.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() async {
    ServiceLocator.I.unregisterAll();
  });

  group('Lazy', () {
    test('Should Not Instantiate Service', () async {
      var initializationCounter = 0;
      await ServiceLocator.I.registerLazy<SimpleService>(
        Lazy<SimpleService>(
          factory: () {
            initializationCounter++;
            return SimpleService();
          },
        ),
      );

      expect(initializationCounter, 0);
    });

    test('Instantiate Service Once', () async {
      var initializationCounter = 0;
      await ServiceLocator.I.registerLazy<SimpleService>(
        Lazy<SimpleService>(
          factory: () {
            initializationCounter++;
            return SimpleService();
          },
        ),
      );

      await ServiceLocator.I.resolve<SimpleService>();
      expect(initializationCounter, 1);
    });

    test('Should Re-Instantiate Service', () async {
      var initializationCounter = 0;
      await ServiceLocator.I.registerLazy<SimpleService>(Lazy<SimpleService>(
        factory: () {
          initializationCounter++;
          return SimpleService();
        },
        expiryDuration: Duration(milliseconds: 100),
      ));

      await ServiceLocator.I.resolve<SimpleService>();
      await Future.delayed(Duration(milliseconds: 150));
      await ServiceLocator.I.resolve<SimpleService>();

      expect(initializationCounter, 2);
    });

    test('Should Throw StateError', () async {
      expect(() async => await ServiceLocator.I.resolve<SimpleService>(),
          throwsA(isA<StateError>()));
    });

    test('Should Return Same Initialized Instance', () async {
      var lazyService = Lazy<SimpleService>(factory: () => SimpleService());
      await ServiceLocator.I.registerLazy<SimpleService>(lazyService);

      var firstInstance = await ServiceLocator.I.resolve<SimpleService>();
      var secondInstance = await ServiceLocator.I.resolve<SimpleService>();

      expect(firstInstance, same(secondInstance),
          reason:
              'Multiple resolves should return the same instance for a lazily registered service.');
    });

    test('Should Inject Dependencies', () async {
      var lazyWithDependency = Lazy<ServiceWithDependency>(
        factory: () async => ServiceWithDependency(
          await ServiceLocator.I.resolve<SimpleService>(),
        ),
      );
      await ServiceLocator.I.registerLazy<SimpleService>(
          Lazy<SimpleService>(factory: () => SimpleService()));
      await ServiceLocator.I
          .registerLazy<ServiceWithDependency>(lazyWithDependency);

      var oneDependencyInstance =
          await ServiceLocator.I.resolve<ServiceWithDependency>();
      expect(oneDependencyInstance, isNotNull);
      expect(oneDependencyInstance.noDependencies, isNotNull);
    });

    test('Manual Reset | Should Re-Initialize Service', () async {
      var initializationCounter = 0;
      var lazyService = Lazy<SimpleService>(factory: () {
        initializationCounter++;
        return SimpleService();
      });

      await ServiceLocator.I.registerLazy<SimpleService>(lazyService);

      // First resolve to initialize the service
      await ServiceLocator.I.resolve<SimpleService>();
      expect(initializationCounter, 1);

      // Manually reset or re-initialize the service here
      lazyService.reset();

      // Resolve again and expect the service to re-initialize
      await ServiceLocator.I.resolve<SimpleService>();
      expect(initializationCounter, 2,
          reason: 'Service should be re-initialized after manual reset.');
    });
  });
}
