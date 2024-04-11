import 'package:zef_di_core/src/annotations/dependency_registration.dart';

/// Designates a singleton instance registration within the service locator.
///
/// Extends [DependencyRegistration] to include common identification and management attributes, specifically
/// tailored for singleton instance registrations. This type ensures that a single instance of the
/// service is used application-wide, preserving state and consistency.
class RegisterSingleton extends DependencyRegistration {
  /// Establishes a singleton instance registration with customizable attributes.
  const RegisterSingleton({super.name, super.key, super.environment});
}
