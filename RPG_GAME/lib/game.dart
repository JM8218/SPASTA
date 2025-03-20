import 'dart:io';
import 'dart:math';
import 'character.dart';
import 'monster.dart';

class Game {
  Character? character;
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  final int requiredDefeats;
  
  // 전투 기록 관련 속성 추가
  int totalBattles = 0;
  DateTime? gameStartTime;
  List<String> defeatedMonsterNames = [];

  Game(this.requiredDefeats);

  Future<void> loadCharacterStats() async {
    try {
      final file = File('data/characters.txt');
      final contents = await file.readAsString();
      final stats = contents.split(',');
      
      if (stats.length != 3) {
        throw FormatException('캐릭터 파일을 확인해주세요.');
      }

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      String name = await getCharacterName();
      character = Character(name, health, attack, defense);
    } catch (e) {
      print('캐릭터 데이터에 오류가 있습니다.: $e');
      exit(1);
    }
  }

  Future<String> getCharacterName() async {
    while (true) {
      print('닉네임 설정 (한글 또는 영문):');
      String name = stdin.readLineSync() ?? '';
      
      if (name.isEmpty) {
        print('닉네임을 설정해주세요.');
        continue;
      }

      if (!RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
        print('이름에는 특수문자나 숫자를 포함할 수 없습니다.');
        continue;
      }

      return name;
    }
  }

  Future<void> loadMonsterStats() async {
    try {
      final file = File('data/monsters.txt');
      final contents = await file.readAsString();
      final lines = contents.split('\n');

      for (var line in lines) {
        if (line.isEmpty) continue;
        final stats = line.split(',');
        if (stats.length != 3) continue;

        String name = stats[0];
        int health = int.parse(stats[1]);
        int maxAttack = int.parse(stats[2]);

        monsters.add(Monster(name, health, maxAttack));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  Monster getRandomMonster() {
    if (monsters.isEmpty) {
      throw Exception('다 잡았네요 ?');
    }
    Random random = Random();
    return monsters[random.nextInt(monsters.length)];
  }

  Future<void> battle() async {
    if (character == null) return;

    totalBattles++;  // 전투 횟수 증가
    Monster currentMonster = getRandomMonster();
    print('\n=== 전투 시작! ===');
    print('현재 상대: ${currentMonster.name}');

    while (currentMonster.health > 0 && character!.health > 0) {
      character!.showStatus();
      currentMonster.showStatus();

      print('\n행동을 선택하세요:');
      print('1. 공격하기');
      print('2. 방어하기');
      
      String? choice = stdin.readLineSync();
      
      if (choice == '1') {
        character!.attackMonster(currentMonster);
      } else if (choice == '2') {
        character!.defend();
      } else {
        print('잘못된 선택입니다. 공격을 실행합니다.');
        character!.attackMonster(currentMonster);
      }

      if (currentMonster.health > 0) {
        currentMonster.attackCharacter(character!);
      }
    }

    if (currentMonster.health <= 0) {
      print('\n${currentMonster.name}을(를) 처치했습니다!');
      defeatedMonsterNames.add(currentMonster.name);  // 처치한 몬스터 이름 기록
      monsters.remove(currentMonster);
      defeatedMonsters++;
    }
  }

  Future<void> startGame() async {
    gameStartTime = DateTime.now();  // 게임 시작 시간 기록
    await loadCharacterStats();
    await loadMonsterStats();

    while (character!.health > 0 && defeatedMonsters < requiredDefeats) {
      await battle();

      if (character!.health <= 0) {
        print('\n게임 오버! 캐릭터가 사망했습니다.');
        break;
      }

      if (defeatedMonsters >= requiredDefeats) {
        print('\n축하합니다! 게임에서 승리했습니다!');
        break;
      }

      if (monsters.isEmpty) {
        print('\n더 이상 몬스터가 없습니다!');
        break;
      }

      print('\n다음 몬스터와 대결하시겠습니까? (y/n)');
      String? choice = stdin.readLineSync();
      if (choice?.toLowerCase() != 'y') {
        print('\n게임을 종료합니다.');
        break;
      }
    }

    await saveResult();
  }

  Future<void> saveResult() async {
    if (character == null) return;

    print('\n결과를 저장하시겠습니까? (y/n)');
    String? choice = stdin.readLineSync();
    
    if (choice?.toLowerCase() == 'y') {
      try {
        final now = DateTime.now();
        final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        
        // 게임 진행 시간 계산
        final gameDuration = now.difference(gameStartTime!);
        final minutes = gameDuration.inMinutes;
        final seconds = gameDuration.inSeconds % 60;
        
        final file = File('data/result.txt');
        final result = defeatedMonsters >= requiredDefeats ? '승리' : '패배';
        
        // 결과 데이터 구성
        final resultData = [
          '===================================',
          '게임 결과 기록',
          '===================================',
          '날짜: $formattedDate',
          '시간: $formattedTime',
          '-----------------------------------',
          '캐릭터 정보',
          '이름: ${character!.name}',
          '남은 체력: ${character!.health}',
          '공격력: ${character!.attack}',
          '방어력: ${character!.defense}',
          '-----------------------------------',
          '전투 기록',
          '총 전투 횟수: $totalBattles회',
          '게임 진행 시간: ${minutes}분 ${seconds}초',
          '처치한 몬스터 수: $defeatedMonsters',
          '처치한 몬스터: ${defeatedMonsterNames.join(", ")}',
          '-----------------------------------',
          '최종 결과: $result',
          '===================================\n'
        ];

        // 파일에 결과 저장
        await file.writeAsString(resultData.join('\n'), mode: FileMode.append);
        print('결과가 저장되었습니다.');
        
        // 결과 파일 위치 안내
        print('결과는 data/result.txt 파일에서 확인하실 수 있습니다.');
      } catch (e) {
        print('결과 저장에 실패했습니다: $e');
      }
    }
  }
} 