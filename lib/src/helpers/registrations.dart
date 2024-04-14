import 'package:any_of/any_of.dart';
import 'package:zef_di_core/zef_di_core.dart';
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

  /// Resolves and returns the service instance associated with this registration.
  ///
  /// The [serviceLocator] parameter is used to resolve any dependencies the service might have.
  //T resolve(ServiceLocator serviceLocator);

  /// Creates a singleton registration with the specified details.
  ///
  /// A singleton registration ensures that only one instance of the service is created and returned for all resolutions.
  factory Registration.singleton({
    required T instance,
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  }) {
    return SyncSingletonRegistration(
      instance: instance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );
  }

  /// Creates a factory registration with the specified details.
  ///
  /// A factory registration uses the provided factory function to create a new instance of the service each time it is resolved.
  factory Registration.transient({
    required T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory,
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  }) {
    return SyncTransientRegistration(
      factory: factory,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );
  }

  /// Creates a new registration based on an existing one, but with a new value (either instance or factory function) provided by [newValue].
  ///
  /// Throws a [StateError] if the type of registration is unknown.
  factory Registration.from(
    Registration registration,
    Doublet<
            T,
            T Function(
              ServiceLocator serviceLocator,
              Map<String, dynamic> namedArgs,
            )>
        newValue,
  ) {
    if (registration is SyncSingletonRegistration) {
      return SyncSingletonRegistration.from(registration, newValue.first);
    } else if (registration is SyncTransientRegistration) {
      return SyncTransientRegistration.from(registration, newValue.second);
    }

    throw StateError('Unknown registration type');
  }
}

mixin AsyncRegistration<T extends Object> on Registration<T> {}

mixin AsyncSimpleRegistration<T extends Object> on Registration<T> implements AsyncRegistration<T> {
  Future<T> resolve(ServiceLocator serviceLocator);
}

mixin AsyncParameterizedRegistration<T extends Object> on Registration<T> implements AsyncRegistration<T> {
  Future<T> resolve(ServiceLocator serviceLocator, Map<String, dynamic> namedArgs);
}

mixin SyncRegistration<T extends Object> on Registration<T> {}

mixin SyncSimpleRegistration<T extends Object> on Registration<T> implements SyncRegistration<T> {
  T resolve(ServiceLocator serviceLocator);
}

mixin SyncParameterizedRegistration<T extends Object> on Registration<T> implements SyncRegistration<T> {
  T resolve(ServiceLocator serviceLocator, Map<String, dynamic> namedArgs);
}

/// A concrete implementation of [Registration] for singleton services.
///
/// This registration type ensures that a single instance of the service is used throughout the application.
class SyncSingletonRegistration<T extends Object> extends Registration<T> with SyncSimpleRegistration<T> {
  /// The singleton instance of the service.
  final T _instance;

  /// Creates a singleton registration with the specified instance and details.
  SyncSingletonRegistration({
    required T instance,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : _instance = instance;

  /// Creates a new [SyncSingletonRegistration] from an existing registration, replacing the instance with [newInstance].
  factory SyncSingletonRegistration.from(SyncSingletonRegistration registration, T newInstance) {
    return SyncSingletonRegistration(
      instance: newInstance,
      interfaces: registration.interfaces,
      name: registration.name,
      key: registration.key,
      environment: registration.environment,
    );
  }

  /// Returns the singleton instance of the service.
  @override
  T resolve(ServiceLocator serviceLocator) => _instance;
}

class AsyncTransientRegistration<T extends Object> extends Registration<T> with AsyncParameterizedRegistration<T> {
  final Future<T> Function(
    ServiceLocator serviceLocator,
    Map<String, dynamic> namedArgs,
  ) _factory;

  AsyncTransientRegistration({
    required Future<T> Function(ServiceLocator, Map<String, dynamic> namedArgs) factory,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : _factory = factory;

  @override
  Future<T> resolve(ServiceLocator serviceLocator, Map<String, dynamic> namedArgs) {
    return _factory(serviceLocator, namedArgs);
  }

  factory AsyncTransientRegistration.from(
      AsyncTransientRegistration registration,
      Future<T> Function(
        ServiceLocator serviceLocator,
        Map<String, dynamic> namedArgs,
      ) newFactory) {
    return AsyncTransientRegistration(
      factory: newFactory,
      interfaces: registration.interfaces,
      name: registration.name,
      key: registration.key,
      environment: registration.environment,
    );
  }
}

/// A concrete implementation of [Registration] for transient services.
///
/// This registration type allows for a new instance of the service to be created each time it is resolved.
class SyncTransientRegistration<T extends Object> extends Registration<T> with SyncParameterizedRegistration<T> {
  /// The factory function used to create new instances of the service.
  final T Function(
    ServiceLocator serviceLocator,
    Map<String, dynamic> namedArgs,
  ) _factory;

  /// Creates a factory registration with the specified factory function and details.
  SyncTransientRegistration({
    required T Function(ServiceLocator, Map<String, dynamic> namedArgs) factory,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : _factory = factory;

  @override
  T resolve(ServiceLocator serviceLocator, Map<String, dynamic> namedArgs) {
    // Invoke the factory function with both the service locator and optional named parameters
    return _factory(serviceLocator, namedArgs);
  }

  /// Creates a new [SyncTransientRegistration] from an existing registration, replacing the factory function with [newFactory].
  factory SyncTransientRegistration.from(
      SyncTransientRegistration registration,
      T Function(
        ServiceLocator serviceLocator,
        Map<String, dynamic> namedArgs,
      ) newFactory) {
    return SyncTransientRegistration(
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
class SyncLazyRegistration<T extends Object> extends Registration<T> with SyncSimpleRegistration<T> {
  final Lazy<T> lazyInstance;

  SyncLazyRegistration({
    required this.lazyInstance,
    required super.interfaces,
    required super.name,
    required super.key,
    required super.environment,
  }) : super();

  @override
  T resolve(ServiceLocator serviceLocator) {
    return lazyInstance.value;
  }
}
