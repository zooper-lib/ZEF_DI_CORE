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
