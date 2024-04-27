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
    await ServiceLocator.I.unregisterAll();
  });

  group('Transient', () {
    test('Should Pass Arguments', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;

      // Act
      await ServiceLocator.I.registerTransient(
        (namedArgs) async => NamedArgs(
          name: namedArgs['name'],
          age: namedArgs['age'],
        ),
      );
      final resolvedInstance = await ServiceLocator.I.resolve<NamedArgs>(
        namedArgs: {
          'name': name,
          'age': age,
        },
      );

      // Assert
      expect(resolvedInstance.name, name);
      expect(resolvedInstance.age, age);
    });

    test('Should Pass Args To Injected Dependency', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;

      // Act
      await ServiceLocator.I.registerTransient(
        (namedArgs) async => NamedArgs(
          name: namedArgs['name'],
          age: namedArgs['age'],
        ),
      );
      await ServiceLocator.I.registerTransient(
        (namedArgs) async => NamedArgsWrapper(
          await ServiceLocator.I.resolve<NamedArgs>(
            namedArgs: namedArgs,
          ),
        ),
      );
      final resolvedInstance = await ServiceLocator.I.resolve<NamedArgsWrapper>(
        namedArgs: {
          'name': name,
          'age': age,
        },
      );

      // Assert
      expect(resolvedInstance.namedArgs.name, name);
      expect(resolvedInstance.namedArgs.age, age);
    });
  });

  group('Singleton Factory', () {
    test('Should Pass Arguments', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;

      // Act
      await ServiceLocator.I.registerSingletonFactory(
        (namedArgs) async => NamedArgs(
          name: namedArgs['name'],
          age: namedArgs['age'],
        ),
        namedArgs: {
          'name': name,
          'age': age,
        },
      );
      final resolvedInstance = await ServiceLocator.I.resolve<NamedArgs>();

      // Assert
      expect(resolvedInstance.name, name);
      expect(resolvedInstance.age, age);
    });

    test('Should Pass Arguments To Injected Dependency', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;

      // Act
      await ServiceLocator.I.registerSingletonFactory(
        (namedArgs) async => NamedArgs(
          name: namedArgs['name'],
          age: namedArgs['age'],
        ),
        namedArgs: {
          'name': name,
          'age': age,
        },
      );
      await ServiceLocator.I.registerSingletonFactory(
        (namedArgs) async => NamedArgsWrapper(
          await ServiceLocator.I.resolve<NamedArgs>(),
        ),
      );
      final resolvedInstance =
          await ServiceLocator.I.resolve<NamedArgsWrapper>();

      // Assert
      expect(resolvedInstance.namedArgs.name, name);
      expect(resolvedInstance.namedArgs.age, age);
    });
  });

  group('Lazy', () {
    test('Should Pass Arguments', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;
      await ServiceLocator.I.registerLazy(
        Lazy<NamedArgs>(
          factory: () => NamedArgs(
            name: name,
            age: age,
          ),
        ),
      );

      // Act
      final resolvedInstance = await ServiceLocator.I.resolve<NamedArgs>();

      // Assert
      expect(resolvedInstance.name, name);
      expect(resolvedInstance.age, age);
    });

    test('Should Pass Arguments To Injected Dependency', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;
      await ServiceLocator.I.registerLazy(
        Lazy<NamedArgs>(
          factory: () => NamedArgs(
            name: name,
            age: age,
          ),
        ),
      );
      await ServiceLocator.I.registerLazy(
        Lazy<NamedArgsWrapper>(
          factory: () async => NamedArgsWrapper(
            await ServiceLocator.I.resolve<NamedArgs>(),
          ),
        ),
      );

      // Act
      final resolvedInstance =
          await ServiceLocator.I.resolve<NamedArgsWrapper>();

      // Assert
      expect(resolvedInstance.namedArgs.name, name);
      expect(resolvedInstance.namedArgs.age, age);
    });
  });
}
