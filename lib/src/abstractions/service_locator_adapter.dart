import 'package:any_of/any_of.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

abstract class ServiceLocatorAdapter {
  /// Asynchronously registers an instance of type [T].
  Future<Triplet<Success, Conflict, InternalError>>
      registerSingleton<T extends Object>(
    T instance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Asynchronously registers a transient factory for type [T].
  Future<Triplet<Success, Conflict, InternalError>>
      registerTransient<T extends Object>(
    Future<T> Function(Map<String, dynamic> args) factory, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Asynchronously registers a lazy instance of type [T].
  Future<Triplet<Success, Conflict, InternalError>>
      registerLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Asynchronously retrieves an instance of type [T].
  Future<Triplet<T, NotFound, InternalError>> resolve<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> args,
    required bool resolveFirst,
  });

  /// Asynchronously retrieves a Set of instances of type [T].
  Future<Triplet<Set<T>, NotFound, InternalError>>
      resolveAll<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> args,
  });

  /// Asynchronously overrides an existing registration with a new `Singleton` of type [T].
  Future<Doublet<Success, InternalError>>
      overrideWithSingleton<T extends Object>(
    T instance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously overrides an existing registration with a new `Transient` of type [T].
  Future<Doublet<Success, InternalError>>
      overrideWithTransient<T extends Object>(
    Future<T> Function(Map<String, dynamic> args) factory, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously overrides an existing registration with a new `Lazy` of type [T].
  Future<Doublet<Success, InternalError>> overrideWithLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously unregisters an instance of type [T].
  Future<Triplet<Success, NotFound, InternalError>>
      unregister<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously unregisters all instances of type [T].
  Future<Doublet<Success, InternalError>> unregisterAll();
}
