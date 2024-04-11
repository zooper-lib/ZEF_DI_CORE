import '../interfaces/fish.dart';

class Shark extends Fish {
  @override
  void move() {
    print('I am a shark, I swim');
  }

  @override
  void eat() {
    print('I am a shark, I eat fish');
  }

  @override
  void sleep() {
    print('I am a shark, I sleep');
  }

  @override
  void swim() {
    print('I am a shark, I swim');
  }
}
