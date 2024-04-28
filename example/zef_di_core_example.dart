import 'package:zef_di_core/zef_di_core.dart';

import 'test_classes/implementations/index.dart';
import 'test_classes/interfaces/index.dart';

void main() async {
  // Build the ServiceLocator
  ServiceLocatorBuilder().build();

  // Register an Singleton
  await ServiceLocator.I.registerSingleton(
    Dolphin(),
    interfaces: {Animal, Fish},
  );

  // Register another Singleton
  await ServiceLocator.I.registerSingleton(
    Dolphin(),
    interfaces: {Animal, Fish},
  );

  // Register a Transient
  await ServiceLocator.I.registerTransient(
    (args) async => Whale(),
  );

  // Retrieve the Singleton
  final instance = await ServiceLocator.I.resolve<Dolphin>();

  // Retrieve the instance via the interface
  final interfaceInstance = await ServiceLocator.I.resolve<Animal>();

  // Do something with the instances
  print(instance.runtimeType); // Output: Dolphin
  print(interfaceInstance.runtimeType); // Output: Dolphin
}
