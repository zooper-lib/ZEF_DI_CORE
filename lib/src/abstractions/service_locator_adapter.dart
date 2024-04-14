import 'package:any_of/any_of.dart';
import 'package:zef_di_core/src/abstractions/service_locator.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

abstract class ServiceLocatorAdapter {
  /// Asynchronously registers an instance of type [T].
  Future<Triplet<Success, Conflict, InternalError>> registerSingleton<T extends Object>(
    T instance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Sync version of [registerSingleton].
  Triplet<Success, Conflict, InternalError> registerSingletonSync<T extends Object>(
    T instance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Asynchronously registers a transient factory for type [T].
  Future<Triplet<Success, Conflict, InternalError>> registerTransient<T extends Object>(
    Future<T> Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Sync version of [registerTransient].
  Triplet<Success, Conflict, InternalError> registerTransientSync<T extends Object>(
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

  /// Asynchronously registers a lazy instance of type [T].
  Future<Triplet<Success, Conflict, InternalError>> registerLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required Set<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
    required bool allowMultipleInstances,
  });

  /// Sync version of [registerLazy].
  Triplet<Success, Conflict, InternalError> registerLazySync<T extends Object>(
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
    required Map<String, dynamic> namedArgs,
    required bool resolveFirst,
  });

  /// Sync version of [resolve].
  Triplet<T, NotFound, InternalError> resolveSync<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
    required bool resolveFirst,
  });

  /// Asynchronously retrieves a Set of instances of type [T].
  Future<Triplet<Set<T>, NotFound, InternalError>> resolveAll<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
  });

  /// Sync version of [resolveAll].
  Triplet<Set<T>, NotFound, InternalError> resolveAllSync<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
    required Map<String, dynamic> namedArgs,
  });

  /// Asynchronously overrides an existing registration with a new `Singleton` of type [T].
  Future<Doublet<Success, InternalError>> overrideWithSingleton<T extends Object>(
    T instance, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Sync version of [overrideWithSingleton].
  Doublet<Success, InternalError> overrideWithSingletonSync<T extends Object>(
    T instance, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously overrides an existing registration with a new `Transient` of type [T].
  Future<Doublet<Success, InternalError>> overrideWithTransient<T extends Object>(
    Future<T> Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Sync version of [overrideWithTransient].
  Doublet<Success, InternalError> overrideWithTransientSync<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously overrides an existing registration with a new `Lazy` of type [T].
  Future<Doublet<Success, InternalError>> overrideWithLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Sync version of [overrideWithLazy].
  Doublet<Success, InternalError> overrideWithLazySync<T extends Object>(
    Lazy<T> lazyInstance, {
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously unregisters an instance of type [T].
  Future<Triplet<Success, NotFound, InternalError>> unregister<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Sync version of [unregister].
  Triplet<Success, NotFound, InternalError> unregisterSync<T extends Object>({
    required String? name,
    required dynamic key,
    required String? environment,
  });

  /// Asynchronously unregisters all instances of type [T].
  Future<Doublet<Success, InternalError>> unregisterAll();

  /// Sync version of [unregisterAll].
  Doublet<Success, InternalError> unregisterAllSync();
}
