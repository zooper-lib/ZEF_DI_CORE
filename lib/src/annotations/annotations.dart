/// Base class for defining registration entries within a dependency injection framework.
///
/// Serves as the foundation for various types of service registrations, including singleton instances,
/// factories, lazy services, and factory methods. It standardizes essential attributes for unique
/// service identification and management across different registration types.
abstract class DependencyRegistration {

  /// Initializes a base registration with customizable identification and management attributes.
  ///
  /// - [name]: An optional identifier for named registrations, enabling distinct resolution of services
  ///   sharing the same type but differing in purpose or configuration.
  /// - [key]: An optional specifier offering refined control over registration and resolution, especially
  ///   beneficial in intricate scenarios where simple type and name matching is inadequate.
  /// - [environment]: An optional specifier delineating the registration's applicability to certain runtime
  ///   environments or configurations, supporting tailored service provisioning.
  const DependencyRegistration({String? name, dynamic key, String? environment})
      : _name = name,
        _key = key,
        _environment = environment;
  final String? _name;
  final dynamic _key;
  final String? _environment;

  /// The name associated with the registration, if provided.
  String? get name => _name;

  /// The key associated with the registration, if provided.
  dynamic get key => _key;

  /// The environment tag associated with the registration, if provided.
  String? get environment => _environment;
}

/// Designates a singleton instance registration within the service locator.
///
/// Extends [DependencyRegistration] to include common identification and management attributes, specifically
/// tailored for singleton instance registrations. This type ensures that a single instance of the
/// service is used application-wide, preserving state and consistency.
class RegisterSingleton extends DependencyRegistration {
  /// Establishes a singleton instance registration with customizable attributes.
  const RegisterSingleton({super.name, super.key, super.environment});
}

/// Denotes a registration for lazy initialization of services within the service locator.
///
/// Builds upon [DependencyRegistration], incorporating attributes for service identification and management
/// with an emphasis on lazy initialization. This approach delays service instantiation until its
/// first use, optimizing resource consumption and potentially improving application startup performance.
class RegisterLazy extends DependencyRegistration {
  /// Sets up a lazy service registration with configurable identification and management options.
  const RegisterLazy({super.name, super.key, super.environment});
}

/// Indicates a factory registration for dynamic service creation within the service locator.
///
/// Inherits from [DependencyRegistration], retaining identification and management attributes while focusing
/// on factory-based service instantiation. This registration type enables dynamic, on-demand creation
/// of service instances, allowing for flexibility and customization in service provisioning.
class RegisterTransient extends DependencyRegistration {
  /// Initiates a factory registration with modifiable service identification and management settings.
  const RegisterTransient({super.name, super.key, super.environment});
}

/// Marks a registration that employs a factory method for service instantiation within the service locator.
///
/// This class signifies the use of a factory method for creating service instances, offering a highly
/// dynamic and tailored approach to service instantiation. It underscores the DI framework's capability
/// to adapt to complex service creation scenarios.
class RegisterFactoryMethod {
  /// Constructs a registration entry for a factory method, highlighting its use in service instantiation.
  const RegisterFactoryMethod();
}

/// Marks a class as a dependency registration module within the service locator.
///
/// This annotation is used to designate a class that contains methods or getters annotated
/// with [RegisterSingleton], [RegisterTransient], [RegisterLazy], or [RegisterFactoryMethod],
/// each defining a specific service registration. The `DependencyModule` serves as a container
/// for organizing multiple service registrations in a structured and cohesive manner.
///
/// By grouping service registrations within a module, it promotes a centralized and modular approach
/// to dependency management, making the DI configuration more maintainable and scalable.
///
/// Example usage:
/// ```dart
/// @DependencyModule()
/// class MyAppRegistrationModule {
///   @RegisterSingleton
///   SomeService get someService => SomeServiceImpl();
///
///   @RegisterTransient
///   AnotherService createAnotherService() => AnotherServiceImpl();
/// }
/// ```
class DependencyModule {
  /// Constructs a [DependencyModule] annotation, marking the annotated class as a container for
  /// service registration definitions.
  const DependencyModule();
}
