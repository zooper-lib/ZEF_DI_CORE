import 'interfaces.dart';
import 'services.dart';

class Chicken implements Bird {
  final MovementService _movementService;
  final EatingService _eatingService;

  Chicken(
    this._movementService,
    this._eatingService,
  );

  @override
  void doSomething() => _movementService.move();

  @override
  void doSomethingElse() => _eatingService.eat();
}

class Dolphin extends Fish {
  final MovementService _movementService;
  final EatingService _eatingService;

  Dolphin(
    this._movementService,
    this._eatingService,
  );

  @override
  void doSomething() => _movementService.move();

  @override
  void doSomethingElse() => _eatingService.eat();
}

class Eagle implements Bird {
  final MovementService _movementService;
  final EatingService _eatingService;

  Eagle(
    this._movementService,
    this._eatingService,
  );

  @override
  void doSomething() => _movementService.move();

  @override
  void doSomethingElse() => _eatingService.eat();
}

class Shark extends Fish {
  final MovementService _movementService;
  final EatingService _eatingService;

  Shark(
    this._movementService,
    this._eatingService,
  );

  @override
  void doSomething() => _movementService.move();

  @override
  void doSomethingElse() => _eatingService.eat();
}

class Spider extends Insect {
  final MovementService _movementService;
  final EatingService _eatingService;

  Spider(
    this._movementService,
    this._eatingService,
  );

  @override
  void doSomething() => _movementService.move();

  @override
  void doSomethingElse() => _eatingService.eat();
}

class Whale extends Fish {
  final MovementService _movementService;
  final EatingService _eatingService;

  Whale(
    this._movementService,
    this._eatingService,
  );

  @override
  void doSomething() => _movementService.move();

  @override
  void doSomethingElse() => _eatingService.eat();
}

class Granite extends Stone {
  @override
  void doSomething() => print('Exists');

  @override
  void doSomethingElse() => print('Still exists');
}

class Marble extends Stone {
  @override
  void doSomething() => print('Exists');

  @override
  void doSomethingElse() => print('Still exists');
}

//* This class is invalid because it has a non-injectable service as a dependency
class InvalidThing implements Thing {
  // ignore: unused_field
  final NonInjectableService _nonInjectableService;

  InvalidThing(this._nonInjectableService);

  @override
  void doSomething() => throw UnimplementedError();

  @override
  void doSomethingElse() => throw UnimplementedError();
}

class ServiceWithParameters {
  /// This service should be injected
  final WalkService _injectedService;

  /// This parameter should be passed
  final String passedParam;

  ServiceWithParameters(this._injectedService, {required this.passedParam});

  void doSomething() => _injectedService.walk();
  void doSomethingElse() => print(passedParam);
}
