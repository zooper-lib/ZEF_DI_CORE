import 'package:zef_di_abstractions/zef_di_abstractions.dart';
import 'package:any_of/any_of.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

abstract class ServiceLocatorAdapter {
  /// Registers an instance of type [T].
  Triplet<Success, Conflict, InternalError> registerSingleton<T extends Object>(
    T instance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Registers a factory for type [T].
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
  });

  Triplet<Success, Conflict, InternalError> registerLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Retrieves an instance of type [T].
  Triplet<T, NotFound, InternalError> resolve<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
    required bool resolveFirst,
  });

  /// Retrieves a Set of instances of type [T].
  Triplet<Set<T>, NotFound, InternalError> resolveAll<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
  });

  /// Overrides an existing registration with a new `Singleton` of type [T].
  Doublet<Success, InternalError> overrideWithSingleton<T extends Object>(
    T instance, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Overrides an existing registration with a new `Transient` of type [T].
  Doublet<Success, InternalError> overrideWithTransient<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Overrides an existing registration with a new `Lazy` of type [T].
  Doublet<Success, InternalError> overrideWithLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Unregisters an instance of type [T].
  Triplet<Success, NotFound, InternalError> unregister<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Clears all registered instances.
  Doublet<Success, InternalError> unregisterAll();
}
