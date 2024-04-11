import '../interfaces/animal.dart';

class Whale extends Animal {
  @override
  void eat() {
    print('I am a whale, I eat fish');
  }

  @override
  void move() {
    print('I am a whale, I swim');
  }

  @override
  void sleep() {
    print('I am a whale, I sleep');
  }

  void swim() {
    print('I am a whale, I swim');
  }
}
