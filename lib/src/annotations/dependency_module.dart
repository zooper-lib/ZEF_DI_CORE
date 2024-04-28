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
