import 'package:zef_di_core/zef_di_core.dart';

import 'test_classes/implementations/index.dart';
import 'test_classes/interfaces/index.dart';

void main() {
  // Build the ServiceLocator
  ServiceLocatorBuilder().build();

  // Register an Singleton
  ServiceLocator.I.registerSingletonSync(
    Dolphin(),
    interfaces: {Animal, Fish},
  );

  // Register another Singleton
  ServiceLocator.I.registerSingletonSync(
    Dolphin(),
    interfaces: {Animal, Fish},
  );

  // Register a Transient
  ServiceLocator.I.registerTransientSync(
    (serviceLocator, namedArgs) => Whale(),
  );

  // Retrieve the Singleton
  final instance = ServiceLocator.I.resolveSync<Dolphin>();

  // Retrieve the instance via the interface
  final interfaceInstance = ServiceLocator.I.resolveSync<Animal>();

  // Do something with the instances
  print(instance.runtimeType); // Output: Dolphin
  print(interfaceInstance.runtimeType); // Output: Dolphin
}
