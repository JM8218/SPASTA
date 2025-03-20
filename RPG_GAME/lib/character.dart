import 'monster.dart';

class Character {
  final String name;
  int health;
  final int attack;
  final int defense;

  Character(this.name, this.health, this.attack, this.defense);

  void attackMonster(Monster monster) {
    int damage = attack - monster.defense;
    if (damage < 0) damage = 0;
    monster.health -= damage;
    print('$name이(가) $damage의 데미지를 입혔습니다!');
  }

  void defend() {
    health += 5;
    print('$name이(가) 방어 성공! hp + 5');
  }

  void showStatus() {
    print('\n=== $name ===');
    print('체력: $health');
    print('공격력: $attack');
    print('방어력: $defense');
    print('==================\n');
  }
} 