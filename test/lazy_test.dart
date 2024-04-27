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
      await ServiceLocator.I.registerLazy<NoDependencies>(
        Lazy<NoDependencies>(
          factory: () {
            initializationCounter++;
            return NoDependencies();
          },
        ),
      );

      expect(initializationCounter, 0);
    });

    test('Instantiate Service Once', () async {
      var initializationCounter = 0;
      await ServiceLocator.I.registerLazy<NoDependencies>(
        Lazy<NoDependencies>(
          factory: () {
            initializationCounter++;
            return NoDependencies();
          },
        ),
      );

      await ServiceLocator.I.resolve<NoDependencies>();
      expect(initializationCounter, 1);
    });

    test('Should Re-Instantiate Service', () async {
      var initializationCounter = 0;
      await ServiceLocator.I.registerLazy<NoDependencies>(Lazy<NoDependencies>(
        factory: () {
          initializationCounter++;
          return NoDependencies();
        },
        expiryDuration: Duration(milliseconds: 100),
      ));

      await ServiceLocator.I.resolve<NoDependencies>();
      await Future.delayed(Duration(milliseconds: 150));
      await ServiceLocator.I.resolve<NoDependencies>();

      expect(initializationCounter, 2);
    });

    test('Should Throw StateError', () async {
      expect(() async => await ServiceLocator.I.resolve<NoDependencies>(),
          throwsA(isA<StateError>()));
    });

    test('Should Return Same Initialized Instance', () async {
      var lazyService = Lazy<NoDependencies>(factory: () => NoDependencies());
      await ServiceLocator.I.registerLazy<NoDependencies>(lazyService);

      var firstInstance = await ServiceLocator.I.resolve<NoDependencies>();
      var secondInstance = await ServiceLocator.I.resolve<NoDependencies>();

      expect(firstInstance, same(secondInstance),
          reason:
              'Multiple resolves should return the same instance for a lazily registered service.');
    });

    test('Should Inject Dependencies', () async {
      var lazyWithDependency = Lazy<OneDependency>(
        factory: () async => OneDependency(
          await ServiceLocator.I.resolve<NoDependencies>(),
        ),
      );
      await ServiceLocator.I.registerLazy<NoDependencies>(
          Lazy<NoDependencies>(factory: () => NoDependencies()));
      await ServiceLocator.I.registerLazy<OneDependency>(lazyWithDependency);

      var oneDependencyInstance =
          await ServiceLocator.I.resolve<OneDependency>();
      expect(oneDependencyInstance, isNotNull);
      expect(oneDependencyInstance.noDependencies, isNotNull);
    });

    test('Manual Reset | Should Re-Initialize Service', () async {
      var initializationCounter = 0;
      var lazyService = Lazy<NoDependencies>(factory: () {
        initializationCounter++;
        return NoDependencies();
      });

      await ServiceLocator.I.registerLazy<NoDependencies>(lazyService);

      // First resolve to initialize the service
      await ServiceLocator.I.resolve<NoDependencies>();
      expect(initializationCounter, 1);

      // Manually reset or re-initialize the service here
      lazyService.reset();

      // Resolve again and expect the service to re-initialize
      await ServiceLocator.I.resolve<NoDependencies>();
      expect(initializationCounter, 2,
          reason: 'Service should be re-initialized after manual reset.');
    });
  });
}
