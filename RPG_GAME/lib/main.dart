import 'game.dart';

void main() async {
  print('=== RPG 게임에 오신 것을 환영합니다! ===');
  print('승리조건 : 몬스터 3마리 처치');
  
  final game = Game(3);
  await game.startGame();
} 