import 'package:zef_di_core/src/annotations/dependency_registration.dart';

/// Indicates a factory registration for dynamic service creation within the service locator.
///
/// Inherits from [DependencyRegistration], retaining identification and management attributes while focusing
/// on factory-based service instantiation. This registration type enables dynamic, on-demand creation
/// of service instances, allowing for flexibility and customization in service provisioning.
class RegisterTransient extends DependencyRegistration {
  /// Initiates a factory registration with modifiable service identification and management settings.
  const RegisterTransient({super.name, super.key, super.environment});
}
