import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/game_state.dart'; // имя пакета: первая строка name: в pubspec.yaml

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<GameState> fresh() async {
    final s = GameState();
    await s.load();
    return s;
  }

  test('без опыта старт с 1 уровня и титул «Новобранец»', () async {
    final s = await fresh();
    await s.saveExperience({}, first: true);
    expect(s.level, 1);
    expect(s.titles, ['Новобранец']);
  });

  test('стартовый уровень и титулы зависят от опыта', () async {
    final s = await fresh();
    await s.saveExperience({'swim': 48, 'box': 9}, first: true);
    expect(s.level, 8); // 7 за стаж > 3 лет + 1 за второй вид спорта
    expect(s.titles, ['Воин моря', 'Гладиатор']);
    expect(s.mainTitle, 'Воин моря');
  });

  test('опыт начисляется за объём', () async {
    final s = await fresh();
    await s.addVolume(tasks[0], 10); // 10 отжиманий x 1.5
    expect(s.xp, 15);
  });

  test('одна вредная еда: небольшой штраф к опыту', () async {
    final s = await fresh();
    final y = todayNum() - 1;
    s.level = 3;
    s.xp = 200;
    s.lastCheck = y;
    s.trainedDays.add(y);
    s.meals.add(Meal(y, 'Бургер', true));
    s.rollDay(todayNum());
    expect(s.level, 3);
    expect(s.xp, 155); // −10% от 450
  });

  test('много вредной еды за день: теряется уровень', () async {
    final s = await fresh();
    final y = todayNum() - 1;
    s.level = 3;
    s.xp = 200;
    s.lastCheck = y;
    s.trainedDays.add(y);
    for (int i = 0; i < 4; i++) {
      s.meals.add(Meal(y, 'Пицца', true));
    }
    s.rollDay(todayNum());
    expect(s.level, 2);
    expect(s.xp, 50);
  });

  test('частая вредная еда усиливает штраф', () async {
    final s = await fresh();
    final y = todayNum() - 1;
    for (int d = y - 4; d <= y; d++) {
      s.meals.add(Meal(d, 'Бургер', true));
    }
    expect(s.junkSeverity(y - 4), 1);
    expect(s.junkSeverity(y), 3);
  });

  test('достижения: берпи и марафонец', () async {
    final s = await fresh();
    await s.addVolume(tasks[3], 1000); // берпи
    await s.addVolume(tasks[6], 100); // бег
    expect(s.unlocked.containsKey('burpee'), true);
    expect(s.unlocked.containsKey('marathon'), true);
    expect(s.unlocked.containsKey('squat'), false);
  });
}
