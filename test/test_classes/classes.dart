// ignore_for_file: unused_field

class NoDependencies {
  const NoDependencies();
}

class OneDependency {
  final NoDependencies noDependencies;

  OneDependency(this.noDependencies);
}

class TwoDependencies {
  final NoDependencies _noDependencies;
  final OneDependency _oneDependency;

  TwoDependencies(this._noDependencies, this._oneDependency);
}

class NamedArgs {
  final String name;
  final int age;

  NamedArgs({
    required this.name,
    required this.age,
  });
}

class NamedArgsWrapper {
  final NamedArgs namedArgs;

  NamedArgsWrapper(this.namedArgs);
}

abstract class InterfaceOne {}

abstract class InterfaceTwo {}

class NoDepencenciesWithInterface implements InterfaceOne {
  const NoDepencenciesWithInterface();
}

class NoDepencenciesWithMultipleInterfaces
    implements InterfaceOne, InterfaceTwo {
  const NoDepencenciesWithMultipleInterfaces();
}

class OneDependencyWithMultipleInterfaces
    implements InterfaceOne, InterfaceTwo {
  final NoDepencenciesWithMultipleInterfaces _noDepencenciesWithInterfaces;

  OneDependencyWithMultipleInterfaces(this._noDepencenciesWithInterfaces);
}

class NamedArgsWithMultipleInterfaces implements InterfaceOne, InterfaceTwo {
  final String name;
  final int age;

  NamedArgsWithMultipleInterfaces({
    required this.name,
    required this.age,
  });
}
