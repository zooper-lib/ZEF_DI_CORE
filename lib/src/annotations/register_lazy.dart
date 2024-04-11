import 'package:zef_di_core/src/annotations/dependency_registration.dart';

/// Denotes a registration for lazy initialization of services within the service locator.
///
/// Builds upon [DependencyRegistration], incorporating attributes for service identification and management
/// with an emphasis on lazy initialization. This approach delays service instantiation until its
/// first use, optimizing resource consumption and potentially improving application startup performance.
class RegisterLazy extends DependencyRegistration {
  /// Sets up a lazy service registration with configurable identification and management options.
  const RegisterLazy({super.name, super.key, super.environment});
}
