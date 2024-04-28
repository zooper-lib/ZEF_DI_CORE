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
        (args) async => ParameterizedService(
          name: args['name'],
          age: args['age'],
        ),
      );
      final resolvedInstance =
          await ServiceLocator.I.resolve<ParameterizedService>(
        args: {
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
        (args) async => ParameterizedService(
          name: args['name'],
          age: args['age'],
        ),
      );
      await ServiceLocator.I.registerTransient(
        (args) async => WrapperService(
          await ServiceLocator.I.resolve<ParameterizedService>(
            args: args,
          ),
        ),
      );
      final resolvedInstance = await ServiceLocator.I.resolve<WrapperService>(
        args: {
          'name': name,
          'age': age,
        },
      );

      // Assert
      expect(resolvedInstance.args.name, name);
      expect(resolvedInstance.args.age, age);
    });
  });

  group('Singleton Factory', () {
    test('Should Pass Arguments', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;

      // Act
      await ServiceLocator.I.registerSingletonFactory(
        (args) async => ParameterizedService(
          name: args['name'],
          age: args['age'],
        ),
        args: {
          'name': name,
          'age': age,
        },
      );
      final resolvedInstance =
          await ServiceLocator.I.resolve<ParameterizedService>();

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
        (args) async => ParameterizedService(
          name: args['name'],
          age: args['age'],
        ),
        args: {
          'name': name,
          'age': age,
        },
      );
      await ServiceLocator.I.registerSingletonFactory(
        (args) async => WrapperService(
          await ServiceLocator.I.resolve<ParameterizedService>(),
        ),
      );
      final resolvedInstance = await ServiceLocator.I.resolve<WrapperService>();

      // Assert
      expect(resolvedInstance.args.name, name);
      expect(resolvedInstance.args.age, age);
    });
  });

  group('Lazy', () {
    test('Should Pass Arguments', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;
      await ServiceLocator.I.registerLazy(
        Lazy<ParameterizedService>(
          factory: () => ParameterizedService(
            name: name,
            age: age,
          ),
        ),
      );

      // Act
      final resolvedInstance =
          await ServiceLocator.I.resolve<ParameterizedService>();

      // Assert
      expect(resolvedInstance.name, name);
      expect(resolvedInstance.age, age);
    });

    test('Should Pass Arguments To Injected Dependency', () async {
      // Arrange
      final String name = 'John Doe';
      final int age = 10;
      await ServiceLocator.I.registerLazy(
        Lazy<ParameterizedService>(
          factory: () => ParameterizedService(
            name: name,
            age: age,
          ),
        ),
      );
      await ServiceLocator.I.registerLazy(
        Lazy<WrapperService>(
          factory: () async => WrapperService(
            await ServiceLocator.I.resolve<ParameterizedService>(),
          ),
        ),
      );

      // Act
      final resolvedInstance = await ServiceLocator.I.resolve<WrapperService>();

      // Assert
      expect(resolvedInstance.args.name, name);
      expect(resolvedInstance.args.age, age);
    });
  });
}
