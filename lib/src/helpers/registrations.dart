import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

/// A base class for managing service registrations within a dependency injection framework.
/// This class allows for the registration of services either as singletons or factories,
/// optionally associated with interfaces, a name, a key, or an environment.
abstract class Registration<T extends Object> {
  /// The Set of interfaces that the registered service implements.
  final Set<Type>? interfaces;

  /// An optional name for the registration, used for named registrations.
  final String? name;

  /// A key associated with the registration, allowing for additional indexing or categorization.
  final dynamic key;

  /// The environment in which the registration is valid, used for environment-specific registrations.
  final String? environment;

  /// The date and time the registration was registered.
  /// This is used for getting the first or last registration.
  final DateTime registeredOn;

  /// Creates a new registration with the given details.
  Registration({
    required this.interfaces,
    required this.name,
    required this.key,
    required this.environment,
  }) : registeredOn = DateTime.now().toUtc();
}

abstract class BasicRegistration<T extends Object> extends Registration<T> {
  BasicRegistration({
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  });

  Future<T> resolve();
}

abstract class ParameterizedRegistration<T extends Object>
    extends Registration<T> {
  ParameterizedRegistration({
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  });

  Future<T> resolve(Map<String, dynamic> namedArgs);
}

class SingletonRegistration<T extends Object>
    extends ParameterizedRegistration<T> {
  final T _instance;

  SingletonRegistration({
    required T instance,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : _instance = instance;

  /// Creates a new [SingletonRegistration] from an existing registration, replacing the instance with [newInstance].
  factory SingletonRegistration.from(
      SingletonRegistration registration, T newInstance) {
    return SingletonRegistration(
      instance: newInstance,
      interfaces: registration.interfaces,
      name: registration.name,
      key: registration.key,
      environment: registration.environment,
    );
  }

  @override
  Future<T> resolve(Map<String, dynamic> namedArgs) => Future.value(_instance);
}

class TransientRegistration<T extends Object>
    extends ParameterizedRegistration<T> {
  final Future<T> Function(Map<String, dynamic> namedArgs) _factory;

  TransientRegistration({
    required Future<T> Function(Map<String, dynamic> namedArgs) factory,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : _factory = factory;

  @override
  Future<T> resolve(Map<String, dynamic> namedArgs) {
    return _factory(namedArgs);
  }

  factory TransientRegistration.from(TransientRegistration registration,
      Future<T> Function(Map<String, dynamic> namedArgs) newFactory) {
    return TransientRegistration(
      factory: newFactory,
      interfaces: registration.interfaces,
      name: registration.name,
      key: registration.key,
      environment: registration.environment,
    );
  }
}

/// A concrete implementation of [Registration] for lazy services.
///
/// This registration type allows for a lazy instance to be created each time it is resolved.
class LazyRegistration<T extends Object> extends ParameterizedRegistration<T> {
  final Lazy<T> lazyInstance;

  LazyRegistration({
    required this.lazyInstance,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  });

  @override
  Future<T> resolve(Map<String, dynamic> namedArgs) async {
    return await Future.value(lazyInstance.value);
  }
}

class LazyFactoryRegistration<T extends Object>
    extends ParameterizedRegistration<Lazy<T>> {
  final Future<Lazy<T>> Function(Map<String, dynamic> namedArgs) _factory;

  LazyFactoryRegistration({
    required Future<Lazy<T>> Function(Map<String, dynamic>) factory,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : _factory = factory;

  @override
  Future<Lazy<T>> resolve(Map<String, dynamic> namedArgs) {
    return _factory(namedArgs);
  }
}
