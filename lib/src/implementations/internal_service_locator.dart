import 'package:zef_di_core/src/abstractions/service_locator.dart';
import 'package:zef_di_core/src/abstractions/service_locator_adapter.dart';
import 'package:zef_di_core/src/helpers/service_locator_config.dart';
import 'package:zef_di_core/src/helpers/user_messages.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';
import 'package:zef_log_core/zef_log_core.dart';

class InternalServiceLocator implements ServiceLocator {
  InternalServiceLocator({
    required ServiceLocatorAdapter adapter,
    ServiceLocatorConfig? config,
  })  : _adapter = adapter,
        _config = config ?? const ServiceLocatorConfig();
  final ServiceLocatorAdapter _adapter;
  final ServiceLocatorConfig _config;

  @override
  void registerSingleton<T extends Object>(
    T instance, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.registerSingleton<T>(
      instance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
      allowMultipleInstances: _config.allowMultipleInstances,
    );

    // On conflict
    if (response.isSecond) {
      if (_config.throwErrors) {
        throw StateError(registrationAlreadyExistsForType(T));
      } else {
        Logger.I.warning(message: registrationAlreadyExistsForType(T));
        return;
      }
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.third.message));
    }
  }

  @override
  void registerSingletonFactory<T extends Object>(
    T Function(ServiceLocator serviceLocator) factory, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  }) {
    // Resolve the Singleton
    final instance = factory(ServiceLocator.I);

    return registerSingleton(
      instance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );
  }

  @override
  void registerTransient<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.registerTransient<T>(
      factory,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
      allowMultipleInstances: _config.allowMultipleInstances,
    );

    // On conflict
    if (response.isSecond) {
      if (_config.throwErrors) {
        throw StateError(registrationAlreadyExistsForType(T));
      } else {
        Logger.I.warning(message: registrationAlreadyExistsForType(T));
        return;
      }
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.third.message));
    }
  }

  @override
  void registerLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.registerLazy<T>(
      lazyInstance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
      allowMultipleInstances: _config.allowMultipleInstances,
    );

    // On conflict
    if (response.isSecond) {
      if (_config.throwErrors) {
        throw StateError(registrationAlreadyExistsForType(T));
      } else {
        Logger.I.warning(message: registrationAlreadyExistsForType(T));
        return;
      }
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.third.message));
    }
  }

  @override
  T resolve<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
    bool resolveFirst = true,
  }) {
    final response = _adapter.resolve<T>(
      name: name,
      key: key,
      environment: environment,
      namedArgs: namedArgs ?? {},
      resolveFirst: resolveFirst,
    );

    // On not found
    if (response.isSecond) {
      // No need to check if throwErrors is true, as we cannot return null here
      throw StateError(noRegistrationFoundForType(T));
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.third.message));
    }

    return response.first;
  }

  @override
  T? resolveOrNull<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
    bool resolveFirst = true,
  }) {
    final response = _adapter.resolve<T>(
      name: name,
      key: key,
      environment: environment,
      namedArgs: namedArgs ?? {},
      resolveFirst: resolveFirst,
    );

    // On not found
    if (response.isSecond) {
      if (_config.throwErrors) {
        throw StateError(noRegistrationFoundForType(T));
      } else {
        Logger.I.warning(message: noRegistrationFoundForType(T));
        return null;
      }
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.third.message));
    }

    return response.first;
  }

  @override
  Set<T> resolveAll<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
  }) {
    final response = _adapter.resolveAll<T>(
      name: name,
      key: key,
      environment: environment,
      namedArgs: namedArgs ?? {},
    );

    // On not found
    if (response.isSecond) {
      if (_config.throwErrors) {
        throw StateError(noRegistrationFoundForType(T));
      } else {
        Logger.I.warning(message: noRegistrationFoundForType(T));
        return {};
      }
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.third.message));
    }

    return response.first;
  }

  @override
  void overrideWithSingleton<T extends Object>(
    T instance, {
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.overrideWithSingleton<T>(
      instance,
      name: name,
      key: key,
      environment: environment,
    );

    // On internal error
    if (response.isSecond) {
      throw StateError(internalErrorOccurred(response.second.message));
    }
  }

  @override
  void overrideWithTransient<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.overrideWithTransient<T>(
      factory,
      name: name,
      key: key,
      environment: environment,
    );

    // On internal error
    if (response.isSecond) {
      throw StateError(internalErrorOccurred(response.second.message));
    }
  }

  @override
  void overrideWithLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.overrideWithLazy<T>(
      lazyInstance,
      name: name,
      key: key,
      environment: environment,
    );

    // On internal error
    if (response.isSecond) {
      throw StateError(internalErrorOccurred(response.second.message));
    }
  }

  @override
  void unregister<T extends Object>({
    String? name,
    dynamic key,
    String? environment,
  }) {
    final response = _adapter.unregister<T>(
      name: name,
      key: key,
      environment: environment,
    );

    // On not found
    if (response.isSecond) {
      if (_config.throwErrors) {
        throw StateError(noRegistrationFoundForType(T));
      } else {
        Logger.I.warning(message: noRegistrationFoundForType(T));
        return;
      }
    }

    // On internal error
    if (response.isThird) {
      throw StateError(internalErrorOccurred(response.second.message));
    }
  }

  @override
  void unregisterAll() {
    final response = _adapter.unregisterAll();

    // On internal error
    if (response.isSecond) {
      throw StateError(internalErrorOccurred(response.second.message));
    }
  }
}
