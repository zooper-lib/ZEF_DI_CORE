import '../interfaces/bird.dart';

class Eagle implements Bird {
  @override
  void fly() {
    print('I am an eagle, I fly');
  }

  @override
  void eat() {
    print('I am an eagle, I eat meat');
  }

  @override
  void move() {
    print('I am an eagle, I fly');
  }

  @override
  void sleep() {
    print('I am an eagle, I sleep');
  }
}
