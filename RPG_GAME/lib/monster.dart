import 'dart:math';
import 'character.dart';

class Monster {
  final String name;
  int health;
  late int attack;
  final int defense = 0;

  Monster(this.name, this.health, int maxAttack) {
    // 캐릭터의 방어력보다 작지 않도록 공격력 설정
    Random random = Random();
    this.attack = maxAttack + random.nextInt(10);
  }

  void attackCharacter(Character character) {
    int damage = attack - character.defense;
    if (damage < 0) damage = 0;
    character.health -= damage;
    print('$name이(가) $damage의 데미지를 입혔습니다!');
  }

  void showStatus() {
    print('\n=== $name의 상태 ===');
    print('체력: $health');
    print('공격력: $attack');
    print('방어력: $defense');
    print('==================\n');
  }
} 