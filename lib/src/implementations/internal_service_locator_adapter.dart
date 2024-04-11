import 'package:any_of/any_of.dart';
import 'package:zef_di_core/src/helpers/registrations.dart';
import 'package:zef_di_core/zef_di_core.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

class InternalServiceLocatorAdapter implements ServiceLocatorAdapter {
  final Map<Type, Set<Registration>> _registrations = {};

  @override
  Triplet<Success, Conflict, InternalError> registerSingleton<T extends Object>(
    T instance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  }) {
    // Check if there is already a registration
    if (allowMultipleInstances == false &&
        _isInstanceRegistered(
          T,
          name: name,
          key: key,
          environment: environment,
        )) {
      return Triplet.second(
        Conflict('Registration already exists for type $T. Skipping registration.'),
      );
    }

    // Create a registration
    var registration = SingletonRegistration<T>(
      instance: instance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );

    // Register the instance
    _registrations[T] ??= {};
    _registrations[T]!.add(registration);

    return Triplet.first(Success());
  }

  @override
  Triplet<Success, Conflict, InternalError> registerTransient<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  }) {
    if (allowMultipleInstances == false && _isInstanceRegistered(T, name: name, key: key, environment: environment)) {
      return Triplet.second(
        Conflict('Registration already exists for type $T. Skipping registration.'),
      );
    }

    // Create a registration
    var registration = FactoryRegistration<T>(
      factory: factory,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );

    // Register the instance
    _registrations[T] ??= {};
    _registrations[T]!.add(registration);

    return Triplet.first(Success());
  }

  @override
  Triplet<Success, Conflict, InternalError> registerLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  }) {
    // Check if there is already a registration
    if (allowMultipleInstances == false &&
        _isInstanceRegistered(
          T,
          name: name,
          key: key,
          environment: environment,
        )) {
      return Triplet.second(
        Conflict('$Registration already exists for type $T. Skipping registration.'),
      );
    }

    var registration = LazyRegistration<T>(
      lazyInstance: lazyInstance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );

    // Register the lazy instance
    _registrations[T] ??= {};
    _registrations[T]!.add(registration);

    return Triplet.first(Success());
  }

  @override
  Triplet<T, NotFound, InternalError> resolve<T extends Object>({
    required String? name,
    required key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
    required bool resolveFirst,
  }) {
    // Filter the registrations
    var matchedRegistrations = _filterRegistrations<T>(
      name: name,
      key: key,
      environment: environment,
    );

    // Check if there are any registrations
    if (matchedRegistrations.isEmpty) {
      return Triplet.second(NotFound('No registration found for type $T.'));
    }

    // Get the first registration
    final registration = matchedRegistrations.first;

    // Create the instance based on the type of registration
    final instance = _resolveRegistration<T>(registration, namedArgs);

    return Triplet.first(instance);
  }

  @override
  Triplet<Set<T>, NotFound, InternalError> resolveAll<T extends Object>({
    required String? name,
    required key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
  }) {
    // Filter the registrations
    var matchedRegistrations = _filterRegistrations<T>(
      name: name,
      key: key,
      environment: environment,
    );

    // Check if there are any registrations
    if (matchedRegistrations.isEmpty) {
      return Triplet.second(NotFound('No registration found for type $T.'));
    }

    // Resolve the instances
    var resolvedInstances = matchedRegistrations.map((registration) {
      if (registration is FactoryRegistration<T>) {
        // For factory registrations, pass the named arguments
        return registration.resolve(ServiceLocator.I, namedArgs);
      } else if (registration is SingletonRegistration<T>) {
        // For singleton registrations, ignore the named arguments
        return registration.resolve(ServiceLocator.I);
      } else {
        throw Exception("Unsupported registration type for $T");
      }
    }).toSet();

    return Triplet.first(resolvedInstances);
  }

  @override
  Doublet<Success, InternalError> overrideWithSingleton<T extends Object>(
    T instance, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var registration = _registrations.entries.where((element) => element.key == T).firstOrNull?.value.firstOrNull;

    // If there is no registration, return an error
    if (registration == null) {
      return Doublet.second(InternalError('No registration found for type $T'));
    }

    // Remove the old registration
    _registrations[T]?.remove(registration);

    // Register the new Singleton
    registerSingleton(
      instance,
      interfaces: null,
      name: name,
      key: key,
      environment: environment,
      allowMultipleInstances: true,
    );

    return Doublet.first(Success());
  }

  @override
  Doublet<Success, InternalError> overrideWithTransient<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var registration = _registrations.entries.where((element) => element.key == T).firstOrNull?.value.firstOrNull;

    // If there is no registration, return an error
    if (registration == null) {
      return Doublet.second(InternalError('No registration found for type $T'));
    }

    // Remove the old registration
    _registrations[T]?.remove(registration);

    // Add the new registration
    registerTransient(
      factory,
      interfaces: null,
      name: name,
      key: key,
      environment: environment,
      allowMultipleInstances: true,
    );

    return Doublet.first(Success());
  }

  @override
  Doublet<Success, InternalError> overrideWithLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var registration = _registrations.entries.where((element) => element.key == T).firstOrNull?.value.firstOrNull;

    // If there is no registration, return an error
    if (registration == null) {
      return Doublet.second(InternalError('No registration found for type $T'));
    }

    // Remove the old registration
    _registrations[T]?.remove(registration);

    // Add the new registration
    registerLazy(
      lazyInstance,
      interfaces: null,
      name: name,
      key: key,
      environment: environment,
      allowMultipleInstances: true,
    );

    return Doublet.first(Success());
  }

  @override
  Triplet<Success, NotFound, InternalError> unregister<T extends Object>({
    required String? name,
    required key,
    required String? environment,
  }) {
    _registrations[T]?.removeWhere((registration) {
      return registration.name == name && registration.key == key && registration.environment == environment;
    });

    return Triplet.first(Success());
  }

  @override
  Doublet<Success, InternalError> unregisterAll() {
    _registrations.clear();

    return Doublet.first(Success());
  }

  bool _isInstanceRegistered(
    Type type, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var allRegistrations = _registrations[type] ?? {};

    // Check if there are any registrations
    if (allRegistrations.isEmpty) {
      return false;
    }

    // Filter by the name
    if (name != null) {
      allRegistrations = allRegistrations.where((registration) {
        return registration.name == name;
      }).toSet();
    }

    // Filter by the key
    allRegistrations = allRegistrations.where((registration) {
      return registration.key == key;
    }).toSet();

    // Filter by the environment
    if (environment != null) {
      allRegistrations = allRegistrations.where((registration) {
        return registration.environment == environment;
      }).toSet();
    }

    return allRegistrations.isNotEmpty;
  }

  List<Registration<T>> _filterRegistrations<T extends Object>({
    required String? name,
    required key,
    required String? environment,
  }) {
    // Filter by the types
    List<Registration<T>> matchedRegistrations = _registrations.entries
        .expand((entry) {
          // Check if the registration key (the concrete class) is T
          bool isConcreteMatch = entry.key == T;

          // Filter registrations where T is an interface or the concrete class itself
          return entry.value.where((registration) {
            return isConcreteMatch || (registration.interfaces?.contains(T) ?? false);
          });
        })
        .cast<Registration<T>>()
        .toList();

    // Filter by the name
    if (name != null) {
      matchedRegistrations = matchedRegistrations.where((registration) {
        return registration.name == name;
      }).toList();
    }

    // Filter by the key
    matchedRegistrations = matchedRegistrations.where((registration) {
      return registration.key == key;
    }).toList();

    // Filter by the environment
    if (environment != null) {
      matchedRegistrations = matchedRegistrations.where((registration) {
        return registration.environment == environment;
      }).toList();
    }

    // Sort the registrations by registration time
    matchedRegistrations.sort(
      (a, b) => a.registeredOn.compareTo(b.registeredOn),
    );

    return matchedRegistrations;
  }

  T _resolveRegistration<T extends Object>(Registration<T> registration, Map<String, dynamic> namedArgs) {
    if (registration is FactoryRegistration<T>) {
      return registration.resolve(ServiceLocator.I, namedArgs);
    } else if (registration is SingletonRegistration<T>) {
      return registration.resolve(ServiceLocator.I);
    } else if (registration is LazyRegistration<T>) {
      return registration.resolve(ServiceLocator.I);
    } else {
      throw Exception("Unsupported registration type for type $T.");
    }
  }
}
