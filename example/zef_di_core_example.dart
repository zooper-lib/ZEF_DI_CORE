import 'package:zef_di_core/src/implementations/internal_service_locator_adapter.dart';
import 'package:zef_di_core/zef_di_core.dart';

import 'test_classes/implementations/index.dart';
import 'test_classes/interfaces/index.dart';

void main() {
  // Build the ServiceLocator
  ServiceLocatorBuilder().withAdapter(InternalServiceLocatorAdapter()).build();

  // Register an Singleton
  ServiceLocator.I.registerSingleton(
    Dolphin(),
    interfaces: {Animal, Fish},
  );

  // Register another Singleton
  ServiceLocator.I.registerSingleton(
    Dolphin(),
    interfaces: {Animal, Fish},
  );

  // Register a Transient
  ServiceLocator.I.registerTransient(
    (serviceLocator, namedArgs) => Whale(),
  );

  // Retrieve the Singleton
  final instance = ServiceLocator.I.resolve<Dolphin>();

  // Retrieve the instance via the interface
  final interfaceInstance = ServiceLocator.I.resolve<Animal>();

  // Do something with the instances
  print(instance.runtimeType); // Output: Dolphin
  print(interfaceInstance.runtimeType); // Output: Dolphin
}
