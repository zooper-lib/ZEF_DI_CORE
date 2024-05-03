import 'package:zef_di_core/zef_di_core.dart';

/// Denotes a parameter that is injected into a service constructor.
class Injected extends DependencyRegistration {
  const Injected({super.name, super.key, super.environment});
}
