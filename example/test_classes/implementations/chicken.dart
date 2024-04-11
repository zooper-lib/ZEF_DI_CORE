import '../interfaces/bird.dart';

class Chicken implements Bird {
  @override
  void fly() {
    print('I am a chicken, I cannot fly');
  }

  @override
  void eat() {
    print('I am a chicken, I eat grains');
  }

  @override
  void move() {
    print('I am a chicken, I walk');
  }

  @override
  void sleep() {
    print('I am a chicken, I sleep');
  }
}
