import '../interfaces/animal.dart';

class Dolphin extends Animal {
  @override
  void eat() {
    print('I am a dolphin, I eat fish');
  }

  @override
  void move() {
    print('I am a dolphin, I swim');
  }

  @override
  void sleep() {
    print('I am a dolphin, I sleep');
  }

  void swim() {
    print('I am a dolphin, I swim');
  }
}
