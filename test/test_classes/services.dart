abstract class MovementService {
  void move();
}

class WalkService extends MovementService {
  void walk() {
    print("Walking on the ground with the help of legs.");
  }

  @override
  void move() => walk();
}

class SwimService extends MovementService {
  void swim() {
    print("Swimming in the water with the help of fins.");
  }

  @override
  void move() => swim();
}

class FlightService extends MovementService {
  void fly() {
    print("Soaring high in the sky with powerful wings.");
  }

  @override
  void move() => fly();
}

class EatingService {
  void eat() {
    print('Eating');
  }
}

//* This Service cannot be injected, it is not registered with the ServiceLocator
class NonInjectableService {}
