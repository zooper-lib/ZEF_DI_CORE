import '../interfaces/insect.dart';

class Spider extends Insect {
  @override
  void eat() {
    print('I am a spider, I eat insects');
  }

  @override
  void move() {
    print('I am a spider, I crawl');
  }

  @override
  void sleep() {
    print('I am a spider, I sleep');
  }
}
