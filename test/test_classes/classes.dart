// ignore_for_file: unused_field

/// A class with no dependencies
class SimpleService {
  const SimpleService();
}

/// A class with one dependency
class ServiceWithDependency {
  final SimpleService noDependencies;

  ServiceWithDependency(this.noDependencies);
}

/// A class with two dependencies
class ServiceWithTwoDependencies {
  final SimpleService _noDependencies;
  final ServiceWithDependency _oneDependency;

  ServiceWithTwoDependencies(
    this._noDependencies,
    this._oneDependency,
  );
}

/// A class with a parameterized constructor
class ParameterizedService {
  final String name;
  final int age;

  ParameterizedService({
    required this.name,
    required this.age,
  });
}

/// A class with a dependency that has a parameterized constructor
class WrapperService {
  final ParameterizedService args;

  WrapperService(this.args);
}

abstract class InterfaceOne {}

abstract class InterfaceTwo {}

/// A class that implements an interface
class InterfaceOneImplementer implements InterfaceOne {
  const InterfaceOneImplementer();
}

/// A class that implements two interfaces
class MultiInterfaceImplementer implements InterfaceOne, InterfaceTwo {
  const MultiInterfaceImplementer();
}

/// A class that implements two interfaces and has a dependency
class DependentMultiInterfaceService implements InterfaceOne, InterfaceTwo {
  final MultiInterfaceImplementer dependency;

  DependentMultiInterfaceService(this.dependency);
}

/// A class that implements two interfaces and has a parameterized constructor
class ParameterizedMultiInterfaceService implements InterfaceOne, InterfaceTwo {
  final String name;
  final int age;

  ParameterizedMultiInterfaceService({
    required this.name,
    required this.age,
  });
}
