import 'package:zef_di_core/src/abstractions/service_locator_adapter.dart';
import 'package:zef_di_core/src/helpers/service_locator_config.dart';
import 'package:zef_di_core/src/implementations/internal_service_locator.dart';
import 'package:zef_di_core/src/implementations/internal_service_locator_adapter.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

/// Central management hub for dependencies and service instances within a dependency injection (DI) framework.
///
/// This class provides the core functionality for a DI system, including the registration,
/// resolution, and management of service instances. It supports a variety of registration
/// types, including singletons and factories, and allows for services to be retrieved by
/// type, name, key, and environment, offering a comprehensive and flexible approach to
/// dependency management.
///
/// The `ServiceLocator` operates as a singleton itself, ensuring that a single, consistent
/// set of service registrations is available throughout the application lifecycle.
abstract class ServiceLocator {
  static ServiceLocator? _instance;

  /// Retrieves the singleton instance of [ServiceLocator], initializing it if necessary.
  ///
  /// This property ensures that only one instance of the [ServiceLocator] exists within
  /// the application, providing a centralized point of access for all service registrations
  /// and resolutions. It must be initialized through a [ServiceLocatorBuilder] before use,
  /// typically at the application's startup, to configure the necessary services and dependencies.
  ///
  /// Throws [StateError] if accessed before proper initialization, reminding developers to
  /// initialize the [ServiceLocator] as part of the application's setup process. This error
  /// serves as a safeguard against unintentional misuse and helps ensure the DI system is
  /// correctly configured before use.
  static ServiceLocator get instance {
    if (_instance == null) {
      throw StateError(
        '$ServiceLocator must be initialized using the $ServiceLocatorBuilder before accessing the instance.',
      );
    }
    return _instance!;
  }

  /// A convenience getter for accessing the singleton instance of the [ServiceLocator].
  ///
  /// This property provides shorthand access to the [ServiceLocator]'s singleton instance,
  /// making it easier to work with the DI system throughout the application. It delegates
  /// to the [instance] property, ensuring consistent behavior and error handling.
  static ServiceLocator get I => instance;

  /// Asynchronously registers a singleton instance of a service with the locator for immediate and repeated use.
  ///
  /// The singleton instance is created and provided during registration, ensuring that all subsequent
  /// resolutions return this same instance. This approach is beneficial for services that maintain state
  /// or are resource-intensive to create, as it ensures only a single instance is used throughout the application.
  ///
  /// - [instance]: The singleton instance to be registered with the service locator. This instance must
  ///   be a non-null object and will be returned for all future resolutions of type [T].
  /// - [interfaces]: An optional `Set` of interfaces or abstract classes that the singleton instance implements.
  ///   This allows the instance to be resolved not only by its concrete type but also by any of the specified
  ///   interfaces, promoting a more flexible and decoupled design.
  /// - [name]: An optional identifier that can be used to distinguish between multiple registrations
  ///   of the same type or interface within the locator. Useful in scenarios requiring multiple distinct
  ///   instances of the same type to be accessible.
  /// - [key]: An optional parameter providing an additional level of discrimination for registrations,
  ///   complementing the type and name to enable even more specific resolution scenarios.
  /// - [environment]: An optional tag that can be used to limit the availability of the singleton instance
  ///   to specific runtime environments or configurations, enhancing the adaptability of the service locator
  ///   to different application contexts.
  ///
  /// Throws [StateError] if a conflict in registration is detected, helping to prevent accidental overrides
  /// of existing registrations. This error enforcement ensures that each registration is unique based on
  /// the combination of type, interfaces, name, key, and environment, maintaining the integrity of the service
  /// locator's registry.
  /// Further errors might be thrown based on the specific behavior or constraints of the underlying service
  /// locator adapter, particularly when internal validation or consistency checks fail.
  Future<void> registerSingleton<T extends Object>(
    T instance, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [registerSingleton].
  void registerSingletonSync<T extends Object>(
    T instance, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously registers a resolution strategy for a singleton of type [T] using a factory function, enabling custom instantiation logic.
  ///
  /// This method allows the consumer to specify exactly how the singleton instance of [T] should be created, offering
  /// greater control over the instantiation process. The factory function is invoked directly after calling this function.
  ///
  /// - [factory]: A function that takes a [ServiceLocator] as its argument and returns an instance of type [T].
  ///   This function encapsulates the custom logic for creating the singleton instance, leveraging the [ServiceLocator]
  ///   for any necessary dependency resolution. This approach facilitates complex initialization scenarios where
  ///   the instantiation of [T] might depend on other services or configurations managed by the service locator.
  /// - [interfaces]: An optional `Set` of types that the singleton is expected to implement. This allows the singleton
  ///   to be resolved by these interface types as well, promoting a design that favors abstraction over concrete
  ///   implementations.
  /// - [name]: An optional identifier to distinguish between multiple factory registrations for the same type or
  ///   interface within the locator. Useful when the application requires different variations of the same service
  ///   type, identifiable by name.
  /// - [key]: An optional discriminator that provides additional granularity in the resolution process, complementing
  ///   the type and name to facilitate more specific resolution conditions.
  /// - [environment]: An optional tag to restrict the availability of the registered factory to certain runtime
  ///   environments or configurations, aligning the service availability with the application's operational context.
  ///
  /// Throws [StateError] if a registration conflict occurs, safeguarding against unintended duplication or override
  /// of factory registrations based on a combination of type, interfaces, name, key, and environment. The integrity
  /// of the service locator's registry is thus preserved, ensuring consistent and predictable behavior. Additional
  /// validation or constraint-related errors might be thrown by the service locator's implementation, reflecting
  /// specific requirements or conditions enforced by the underlying mechanism.
  Future<void> registerSingletonFactory<T extends Object>(
    Future<T> Function(ServiceLocator serviceLocator) factory, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [registerSingletonFactory].
  void registerSingletonFactorySync<T extends Object>(
    T Function(ServiceLocator serviceLocator) factory, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously registers a factory method with the service locator for transient instance creation.
  ///
  /// The factory method provides a way to instantiate objects of type [T] on demand, offering
  /// more control over the creation process. This is particularly useful for instances that
  /// require fresh or customized creation logic each time they are resolved, such as objects
  /// with runtime parameters or transient dependencies.
  ///
  /// - [factory]: A callback function that is invoked by the service locator to create an instance
  ///   of type [T]. This function can utilize the service locator for resolving dependencies
  ///   and may also use named arguments [namedArgs] passed during resolution for further customization.
  /// - [interfaces]: An optional `Set` of interfaces or abstract classes that the created instances
  ///   are expected to implement. This allows instances to be resolved by their interface types,
  ///   promoting loose coupling and enhancing the flexibility of your application's architecture.
  /// - [name]: An optional identifier for the factory registration, enabling the resolution of
  ///   multiple distinct instances of the same type based on contextual names. This is useful
  ///   in scenarios where different variations or configurations of a type are needed.
  /// - [key]: An optional parameter that provides another layer of specificity to the registration,
  ///   allowing for fine-grained control over instance resolution when type and name alone are insufficient.
  /// - [environment]: An optional tag that specifies the runtime environment or configuration
  ///   under which the factory is applicable. This enables conditional availability of services,
  ///   tailored to different application states or configurations.
  ///
  /// Throws [StateError] when a conflict in registration is detected, safeguarding against
  /// unintended overrides of existing registrations. This behavior ensures the uniqueness and
  /// consistency of registrations based on type, interfaces, name, key, and environment.
  /// Additional errors may be encountered based on the service locator's underlying implementation,
  /// particularly if internal validation fails or if there are issues during the resolution process.
  Future<void> registerTransient<T extends Object>(
    Future<T> Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [registerTransient].
  void registerTransientSync<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously registers a [Lazy<T>] instance with the service locator for lazy initialization and resolution.
  ///
  /// The [Lazy<T>] wrapper facilitates the deferred creation of an instance of type [T], ensuring
  /// that the instance is only instantiated when first accessed. This can improve performance and
  /// resource utilization by delaying expensive initialization until it's actually needed.
  ///
  /// - [lazyInstance]: A [Lazy<T>] instance that encapsulates the logic for creating and managing
  ///   the lazy instance of [T]. The lazy instance will be created upon the first call to `resolve`
  ///   and cached for subsequent calls, adhering to the lazy initialization pattern.
  /// - [interfaces]: An optional `Set` of types (interfaces or abstract classes) that the lazy instance
  ///   implements. This allows for resolving the instance based on its implemented interfaces rather
  ///   than its concrete type, enabling more flexible and decoupled code.
  /// - [name]: An optional identifier that can be used to distinguish between multiple registrations
  ///   of the same type or interface. This is particularly useful when more than one instance of a
  ///   type needs to be available and resolved contextually.
  /// - [key]: An optional parameter that provides an additional layer of discrimination for registrations,
  ///   allowing for even more granular control and resolution of instances beyond type and name.
  /// - [environment]: An optional tag that can be used to restrict the availability of the lazy instance
  ///   to certain runtime environments or configurations, adding another dimension of control for instance
  ///   resolution based on application state or configuration.
  ///
  /// Throws [StateError] if a registration conflict occurs, which helps to prevent unintended overrides
  /// and ensure that each registration is unique based on the combination of type, name, key, and environment.
  /// Further errors may be thrown depending on the underlying service locator's implementation, especially
  /// when internal consistency checks or validations fail.
  Future<void> registerLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [registerLazy].
  void registerLazySync<T extends Object>(
    Lazy<T> lazyInstance, {
    Set<Type>? interfaces,
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously resolves the first registered instance of type `T` that matches the given criteria.
  ///
  /// - `interface`: An optional interface type to filter the instances by the interface they implement.
  /// - `name`: An optional name to filter the instances by their registered name.
  /// - `key`: An optional key to further refine the filtering of instances.
  /// - `environment`: An optional environment tag to filter instances available in the specified environment.
  /// - `namedArgs`: Optional. A map of named arguments that can be passed to the factory function to influence the instantiation
  ///                of the service. This allows for more flexible and context-specific service creation, accommodating various
  ///                dependencies or configuration values needed at runtime.
  ///
  /// Throws [StateError] if no matching instance is found.
  /// Note: It does not consider the settings of the [ServiceLocatorConfig.throwErrors].
  Future<T> resolve<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
    bool resolveFirst = true,
  });

  /// Synchronous version of [resolve].
  T resolveSync<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
    bool resolveFirst = true,
  });

  /// Asynchronously resolves and returns an instance of type `T` based on the specified criteria.
  ///
  /// This method searches for a registered service that matches the type `T` and optionally
  /// additional criteria such as interface, name, key, and environment. It's designed to retrieve
  /// services that have been registered either as singletons or through factory methods, allowing
  /// for dynamic and context-sensitive resolution of dependencies.
  ///
  /// - [interface]: An optional parameter that specifies an interface type. If provided, the method
  ///   will attempt to resolve an instance that implements the given interface, offering a way to
  ///   retrieve services based on contract rather than concrete implementation.
  /// - [name]: An optional identifier used to distinguish between multiple instances of the same type
  ///   or interface. This allows for context-specific resolution where multiple variants of a service
  ///   are needed.
  /// - [key]: An optional parameter that provides an additional level of filtering, useful in complex
  ///   scenarios where type and name alone do not suffice for uniquely identifying a service.
  /// - [environment]: An optional tag that restricts resolution to services registered for a specific
  ///   runtime environment, facilitating environment-specific configurations.
  /// - [namedArgs]: An optional map of named arguments that can be passed to a factory method upon
  ///   resolution. This allows for the creation of instances with specific configurations or dependencies
  ///   that are determined at runtime, enhancing the flexibility of service instantiation.
  /// - [resolveFirst]: A flag indicating whether to resolve the first matching instance or not. By default,
  ///   this is set to `true`, meaning the method will return the first service that matches the given criteria.
  ///
  /// Throws [StateError] when no instances match the specified criteria, ensuring that a clear error is
  /// reported when a required service cannot be resolved. This behavior is in place regardless of the
  /// [ServiceLocatorConfig.throwErrors] setting, which may affect other aspects of service locator behavior.
  ///
  /// This method is central to the dependency injection mechanism, allowing for decoupled and dynamic
  /// resolution of services and their dependencies.
  Future<T?> resolveOrNull<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
  });

  /// Synchronous version of [resolveOrNull].
  T? resolveOrNullSync<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
  });

  /// Asynchronously attempts to resolve an instance of type `T` based on the specified criteria, returning `null` if no match is found.
  ///
  /// This method functions similarly to [resolveSync] but is designed to return `null` instead of throwing an
  /// exception when no matching instance is found. This can be useful in scenarios where the absence of a
  /// service is an acceptable condition and can be gracefully handled within the application logic.
  ///
  /// - [interface]: An optional parameter specifying an interface type that the desired instance should implement.
  ///   This enables resolution based on abstractions, promoting loose coupling between components.
  /// - [name]: An optional identifier that allows for the resolution of named instances. This is particularly
  ///   useful in applications that require multiple variants of the same service type, each configured differently.
  /// - [key]: An optional parameter that offers an additional level of specificity beyond type and name, aiding
  ///   in the resolution of services in more complex scenarios.
  /// - [environment]: An optional tag that limits resolution to services associated with a specific runtime
  ///   environment, facilitating the configuration of services tailored to different contexts or stages of
  ///   deployment.
  /// - [namedArgs]: An optional map of named arguments that, if provided, are passed to the factory method
  ///   responsible for creating the instance. This enables dynamic configuration of services at the point of
  ///   resolution, allowing for a high degree of customization based on runtime conditions.
  ///
  /// In contrast to [resolveSync], this method does not throw a [StateError] when no matching instance is found,
  /// making it suitable for cases where the non-existence of a service is a handled scenario rather than an
  /// exceptional condition. However, if the service locator's configuration is set to throw errors for missing
  /// registrations, a [StateError] may still be thrown, reflecting the locator's configuration.
  ///
  /// This method provides a safe and flexible approach to resolving optional dependencies within an application,
  /// aligning with practices that favor resilience and robustness in service resolution.
  Future<Set<T>> resolveAll<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
  });

  /// Synchronous version of [resolveAll].
  Set<T> resolveAllSync<T extends Object>({
    Type? interface,
    String? name,
    dynamic key,
    String? environment,
    Map<String, dynamic>? namedArgs,
  });

  /// Asynchronously Overrides an existing registration with a new `Singleton`.
  ///
  /// This method allows dynamically updating the service associated with a specific
  /// registration. It's useful in scenarios where the service's state or behavior needs to be
  /// refreshed or replaced during the application's lifecycle.
  ///
  /// - [instance]: The new instance to replace the current registration. This instance will
  ///   be returned for all future resolutions of the type [T].
  /// - [name]: An optional identifier to specify which named registration to override.
  /// - [key]: An optional key to further qualify the targeted registration for overriding.
  /// - [environment]: An optional environment tag to target environment-specific registrations.
  ///
  /// Throws [StateError] if attempting to override a non-existent registration, ensuring
  /// that the integrity of the service registry is maintained.
  Future<void> overrideWithSingleton<T extends Object>(
    T instance, {
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [overrideWithSingleton].
  void overrideWithSingletonSync<T extends Object>(
    T instance, {
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously overrides an existing registration with a new `Transient`.
  ///
  /// Useful for scenarios requiring changes in the instantiation logic of a service, this method
  /// replaces the current registration associated with a type [T] with a new `Transient`. This can
  /// accommodate changes in dependencies or construction logic that may occur over time.
  ///
  /// - [factory]: The new factory method to replace with. Future resolutions of
  ///   type [T] will invoke this factory.
  /// - [name]: An optional identifier to specify the named registration to override.
  /// - [key]: An optional key to provide additional specificity to the registration being overridden.
  /// - [environment]: An optional environment tag for targeting environment-specific factory registrations.
  ///
  /// Throws [StateError] for errors encountered during the override process, such as when
  /// trying to override a non-existent factory registration, to ensure consistent and error-free
  /// service registration.
  Future<void> overrideWithTransient<T extends Object>(
    Future<T> Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [overrideWithTransient].
  void overrideWithTransientSync<T extends Object>(
    T Function(
      ServiceLocator serviceLocator,
      Map<String, dynamic> namedArgs,
    ) factory, {
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously overrides an existing registration with a new `Lazy`.
  ///
  /// This method replaces the current registration associated with a type [T] with a new `Lazy`.
  /// It is useful when the service instantiation logic needs to be deferred until the service is
  /// actually needed, optimizing resource utilization and potentially improving application startup
  /// performance.
  ///
  /// - [lazyInstance]: The new `Lazy` instance to replace the current registration. The lazy instance
  ///  will be created upon the first call to `resolve` and cached for subsequent calls.
  /// - [name]: An optional identifier to specify the named registration to override.
  /// - [key]: An optional key to provide additional specificity to the registration being overridden.
  /// - [environment]: An optional environment tag for targeting environment-specific lazy registrations.
  ///
  /// Throws [StateError] if an internal error occurs during the override process, such as when trying
  /// to override a non-existent service, ensuring that the operation is performed safely and predictably.
  Future<void> overrideWithLazy<T extends Object>(
    Lazy<T> lazyInstance, {
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [overrideWithLazy].
  void overrideWithLazySync<T extends Object>(
    Lazy<T> lazyInstance, {
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously unregisters instances and factories of type `T` matching the specified criteria.
  ///
  /// This method facilitates the removal of specific registrations, aiding in the dynamic
  /// management of services within the application. It can be used for cleanup or for
  /// adjusting the service landscape based on runtime conditions or application state changes.
  ///
  /// - [name]: An optional identifier to target named registrations for unregistration.
  /// - [key]: An optional key to further refine the target registrations for unregistration.
  /// - [environment]: An optional environment tag to target environment-specific registrations.
  ///
  /// Throws [StateError] if an internal error occurs during the unregistration process,
  /// such as when trying to unregister a non-existent service, ensuring that the operation
  /// is performed safely and predictably.
  Future<void> unregister<T extends Object>({
    String? name,
    dynamic key,
    String? environment,
  });

  /// Synchronous version of [unregister].
  void unregisterSync<T extends Object>({
    String? name,
    dynamic key,
    String? environment,
  });

  /// Asynchronously clears all registrations from the service locator.
  ///
  /// This method is utilized for comprehensive cleanup, removing all singleton and factory
  /// registrations and effectively resetting the service locator to its initial state. It's
  /// particularly useful during teardown processes or when reinitializing the service configuration
  /// is necessary.
  ///
  /// Throws [StateError] if an internal error occurs during the unregistration process, guaranteeing
  /// that the operation is conducted securely and without unintended consequences.
  Future<void> unregisterAll();

  /// Synchronous version of [unregisterAll].
  void unregisterAllSync();
}

/// Facilitates the configuration and initialization of a [ServiceLocator] instance using a fluent interface.
///
/// The `ServiceLocatorBuilder` simplifies the setup of the [ServiceLocator], allowing for customization
/// of its underlying adapter and configuration settings. Utilizing the builder pattern, it enables a
/// sequential and readable approach to configuring the [ServiceLocator], ensuring that all necessary
/// components and settings are specified before the [ServiceLocator] is instantiated.
class ServiceLocatorBuilder {
  ServiceLocatorAdapter _adapter = InternalServiceLocatorAdapter();
  ServiceLocatorConfig _config = ServiceLocatorConfig();

  /// Specifies the adapter to be used by the [ServiceLocator].
  ///
  /// The adapter is a crucial component that dictates the mechanism for service registration, resolution,
  /// and lifecycle management within the [ServiceLocator]. It encapsulates the logic for how service instances
  /// are stored, retrieved, and managed throughout their lifecycle.
  ///
  /// - [adapter]: An instance of [ServiceLocatorAdapter] that provides the implementation details for
  ///   managing service instances within the [ServiceLocator].
  ///
  /// Returns the [ServiceLocatorBuilder] instance, supporting method chaining to streamline the configuration process.
  ServiceLocatorBuilder withAdapter(ServiceLocatorAdapter adapter) {
    _adapter = adapter;
    return this;
  }

  /// Defines the configuration settings for the [ServiceLocator].
  ///
  /// Configuration settings influence various operational aspects of the [ServiceLocator], including
  /// but not limited to logging, environment-specific behaviors, and error handling strategies.
  ///
  /// - [config]: An instance of [ServiceLocatorConfig] that contains the desired configuration options
  ///   for the [ServiceLocator].
  ///
  /// Returns the [ServiceLocatorBuilder] instance, enabling further method chaining for additional configurations.
  ServiceLocatorBuilder withConfig(ServiceLocatorConfig config) {
    _config = config;
    return this;
  }

  /// Completes the setup process and initializes the [ServiceLocator] instance with the specified configurations.
  ///
  /// This method finalizes the [ServiceLocator]'s configuration using the previously defined adapter and settings.
  /// It should be invoked once all necessary configurations have been applied to the builder, culminating in the
  /// instantiation of the [ServiceLocator] and assignment to its singleton reference.
  ///
  /// Throws [StateError] if the [ServiceLocator] has already been initialized, enforcing the singleton pattern
  /// and preventing multiple instances of the [ServiceLocator].
  void build() {
    if (ServiceLocator._instance != null) {
      throw StateError(
        '$ServiceLocator has already been initialized and cannot be configured again.',
      );
    }

    // Assigns the newly configured ServiceLocator instance to its singleton reference.
    ServiceLocator._instance = InternalServiceLocator(adapter: _adapter, config: _config);
  }
}
