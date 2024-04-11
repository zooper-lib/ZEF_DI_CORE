import 'package:zef_di_core/src/abstractions/service_locator.dart';

/// Configuration settings for customizing the behavior of the [ServiceLocator].
///
/// This class encapsulates the configurable aspects of the [ServiceLocator], allowing clients to tailor
/// its behavior according to the needs of their application. It provides options to control error handling
/// and the registration of multiple instances of the same type.
class ServiceLocatorConfig {
  const ServiceLocatorConfig({
    this.throwErrors = false,
    this.allowMultipleInstances = true,
  });

  /// Determines the error handling behavior of the [ServiceLocator].
  ///
  /// When set to `true`, the [ServiceLocator] will actively throw errors encountered during service
  /// registration, resolution, or unregistration. This can be helpful for debugging and ensuring that
  /// service misconfigurations are surfaced immediately.
  ///
  /// Conversely, when set to `false`, the [ServiceLocator] will log errors without throwing, allowing
  /// the application to continue running. This might be preferred in production environments where
  /// resilience is prioritized over immediate error reporting.
  final bool throwErrors;

  /// Controls whether the [ServiceLocator] permits the registration of multiple instances of the same type.
  ///
  /// By default, set to `true`, allowing multiple instances of the same service type to be registered,
  /// potentially under different names or keys. This supports use cases where variations of a service
  /// are needed, each with its own specific configuration or state.
  ///
  /// Setting this to `false` enforces a stricter policy where only one instance of each service type
  /// is allowed. Attempting to register additional instances will result in an error. This strictness
  /// can help prevent unintended service duplications and encourage a more consistent service landscape.
  final bool allowMultipleInstances;
}
