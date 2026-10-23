import 'package:flutter/foundation.dart';
import 'achievements.dart';
import 'body_type.dart';
import 'Experience.dart';
import 'package:shared_preferences/shared_preferences.dart';

int todayNum() {
  final n = DateTime.now();
  return DateTime.utc(n.year, n.month, n.day)
      .difference(DateTime.utc(2020))
      .inDays;
}

class TaskDef {
  final String id, title, unit;
  final double base, step, max, xpPer; // xpPer - опыт за 1 повторение / 1 км
  const TaskDef(this.id, this.title, this.unit, this.base, this.step, this.max,
      this.xpPer);
}

// Цель на день растёт с уровнем: base + step * (level - 1), но не больше max.
// Опыт даётся за каждое выполненное повторение / километр (важен объём).
const tasks = [
  TaskDef('push', 'Отжимания', 'раз', 10, 5, 100, 1.5),
  TaskDef('pull', 'Подтягивания', 'раз', 3, 1, 30, 4),
  TaskDef('squat', 'Приседания', 'раз', 15, 5, 150, 1),
  TaskDef('burpee', 'Берпи', 'раз', 5, 2, 60, 3),
  TaskDef('dips', 'Брусья', 'раз', 5, 2, 40, 3),
  TaskDef('crunch', 'Скручивания на пресс', 'раз', 15, 5, 100, 0.7),
  TaskDef('run', 'Бег', 'км', 2, 1, 10, 20),
];

const rankNames = [
  'Новичок',
  'Любитель',
  'Спортсмен',
  'Атлет',
  'Профи',
  'Мастер',
  'Легенда'
];

class Food {
  final String name;
  final bool fast;
  const Food(this.name, this.fast);
}

const healthyFoods = [
  Food('Салат', false),
  Food('Курица с рисом', false),
  Food('Фрукты', false),
  Food('Омлет', false),
  Food('Овсянка', false),
  Food('Гречка', false),
  Food('Творог', false),
  Food('Рыба на пару', false),
  Food('Йогурт', false),
  Food('Орехи', false),
  Food('Овощи', false),
  Food('Индейка', false),
];

const fastFoods = [
  Food('Бургер', true),
  Food('Пицца', true),
  Food('Картошка фри', true),
  Food('Кола', true),
  Food('Хот-дог', true),
  Food('Наггетсы', true),
  Food('Чипсы', true),
  Food('Шаурма', true),
  Food('Мороженое', true),
  Food('Пончик', true),
  Food('Торт', true),
  Food('Лапша быстрого приготовления', true),
];

class Meal {
  final int day;
  final String name;
  final bool fast;
  final int? ts; // время добавления (мс с 1970), у старых записей может не быть
  Meal(this.day, this.name, this.fast, [this.ts]);

  String get time {
    if (ts == null) return '--:--';
    final d = DateTime.fromMillisecondsSinceEpoch(ts!);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String encode() => '$day|$name|${fast ? 1 : 0}|${ts ?? ''}';
  static Meal decode(String s) {
    final p = s.split('|');
    final t = p.length > 3 ? int.tryParse(p[3]) : null;
    return Meal(int.parse(p[0]), p[1], p[2] == '1', t);
  }
}

class GameState extends ChangeNotifier {
  int level = 1, xp = 0, taskDay = 0, lastCheck = 0;
  Map<String, double> progress = {}; // объём за сегодня по упражнениям
  List<int> trainedDays = []; // дни, когда была хоть какая-то тренировка
  List<Meal> meals = [];
  List<Food> customFoods = [];
  String penaltyMsg = '';
  bool welcomed = false;
  String nickname = '', email = '';
  int avatar = 0, joinDay = 0;
  Map<int, Map<String, double>> history = {}; // день -> упражнение -> объём
  bool setupDone = false;
  bool expDone = false; // пройден ли опрос о спортивном опыте
  Map<String, int> sportExp = {}; // вид спорта -> стаж в месяцах
  Map<String, int> unlocked = {}; // id достижения -> день получения
  List<String> newAchievements = []; // названия, о которых ещё не сказали
  String gender = ''; // 'm' или 'f'
  int age = 25;
  double weight = 70, height = 175;
  BodyType? get bodyType =>
      setupDone ? detectBodyType(gender, age, weight, height) : null;

  int get xpNeed => 150 * level;
  String get rank =>
      rankNames[((level - 1) ~/ 2).clamp(0, rankNames.length - 1)];

  // ---------- Титулы ----------
  List<String> get titles => earnedTitles(sportExp);
  String get mainTitle => mainTitleOf(sportExp);

  // ---------- Штраф за вредную еду ----------
  // Доля от xpNeed, которая сгорает в конце дня, в зависимости от «тяжести».
  static const _lossFraction = [0.0, 0.10, 0.25, 0.50, 1.0, 1.5];

  int junkCount(int day) => meals.where((m) => m.day == day && m.fast).length;

  /// Сколько дней из последних 7 (включая [day]) была вредная еда.
  int junkDaysInWeek(int day) => [
        for (int d = day - 6; d <= day; d++)
          if (junkCount(d) > 0) d
      ].length;

  /// Тяжесть: сколько вредного за день + надбавка, если это происходит часто.
  int junkSeverity(int day) {
    final j = junkCount(day);
    if (j == 0) return 0;
    final f = junkDaysInWeek(day);
    return j + (f >= 3 ? 1 : 0) + (f >= 5 ? 1 : 0);
  }

  int penaltyXp(int severity) => (xpNeed *
          _lossFraction[severity.clamp(0, _lossFraction.length - 1).toInt()])
      .round();

  int get todayJunk => junkCount(todayNum());
  int get todayPenalty => penaltyXp(junkSeverity(todayNum()));
  List<Meal> get todayMeals => meals.where((m) => m.day == todayNum()).toList()
    ..sort((a, b) => (a.ts ?? 0).compareTo(b.ts ?? 0));

  // Вся история питания по дням (новые дни сверху), внутри дня по времени
  Map<int, List<Meal>> get mealsByDay {
    final days = meals.map((m) => m.day).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return {
      for (final d in days)
        d: (meals.where((m) => m.day == d).toList()
          ..sort((a, b) => (a.ts ?? 0).compareTo(b.ts ?? 0)))
    };
  }

  double target(TaskDef t) {
    final v = (t.base + t.step * (level - 1)).clamp(0, t.max).toDouble();
    return t.unit == 'км' ? (v * 10).round() / 10 : v.roundToDouble();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final today = todayNum();
    level = p.getInt('level') ?? 1;
    xp = p.getInt('xp') ?? 0;
    taskDay = p.getInt('taskDay') ?? today;
    lastCheck = p.getInt('lastCheck') ?? today;
    progress = {
      for (final e in (p.getStringList('progress') ?? []))
        e.split(':')[0]: double.parse(e.split(':')[1])
    };
    trainedDays = (p.getStringList('trained') ?? []).map(int.parse).toList();
    meals = (p.getStringList('meals') ?? []).map(Meal.decode).toList();
    customFoods = (p.getStringList('customFoods') ?? []).map((e) {
      final x = e.split('|');
      return Food(x[0], x[1] == '1');
    }).toList();
    welcomed = p.getBool('welcomed') ?? false;
    nickname = p.getString('nick') ?? '';
    email = p.getString('email') ?? '';
    avatar = p.getInt('avatar') ?? 0;
    joinDay = p.getInt('joinDay') ?? today;
    setupDone = p.getBool('setupDone') ?? false;
    expDone = p.getBool('expDone') ?? false;
    sportExp = {
      for (final e in (p.getStringList('sportExp') ?? []))
        e.split(':')[0]: int.parse(e.split(':')[1])
    };
    unlocked = {
      for (final e in (p.getStringList('ach') ?? []))
        e.split(':')[0]: int.parse(e.split(':')[1])
    };
    gender = p.getString('gender') ?? '';
    age = p.getInt('age') ?? 25;
    weight = p.getDouble('weight') ?? 70;
    height = p.getDouble('height') ?? 175;
    for (final e in (p.getStringList('history') ?? [])) {
      final parts = e.split('|');
      history[int.parse(parts[0])] = {
        if (parts.length > 1 && parts[1].isNotEmpty)
          for (final kv in parts[1].split(','))
            kv.split(':')[0]: double.parse(kv.split(':')[1])
      };
    }
    if (progress.isNotEmpty) {
      history.putIfAbsent(taskDay, () => Map.of(progress));
    }
    rollDay(today);
    _checkAchievements();
    await _save();
  }

  Future<void> setWelcomed() async {
    welcomed = true;
    await _save();
    notifyListeners();
  }

  Future<void> saveBody(String g, int a, double w, double h) async {
    gender = g;
    age = a;
    weight = w;
    height = h;
    setupDone = true;
    await _save();
    notifyListeners();
  }

  /// Сохраняет спортивный опыт. При первом заполнении ([first]) ещё и
  /// выставляет стартовый уровень (уровень не понижается).
  Future<void> saveExperience(Map<String, int> exp,
      {bool first = false}) async {
    sportExp = Map.of(exp);
    expDone = true;
    if (first) {
      final sl = startLevel(exp);
      if (sl > level) {
        level = sl;
        xp = 0;
      }
    }
    _checkAchievements();
    await _save();
    notifyListeners();
  }

  Future<void> showWelcomeAgain() async {
    welcomed = false;
    notifyListeners();
  }

  Future<void> saveProfile(String nick, String mail, int av) async {
    nickname = nick;
    email = mail;
    avatar = av;
    await _save();
    notifyListeners();
  }

  void _loseXp(int loss) {
    xp -= loss;
    while (xp < 0) {
      if (level > 1) {
        level--;
        xp += xpNeed; // «занимаем» опыт у предыдущего уровня
      } else {
        xp = 0;
      }
    }
  }

  String _dm(int d) {
    final x = DateTime.utc(2020).add(Duration(days: d));
    return '${x.day.toString().padLeft(2, '0')}.${x.month.toString().padLeft(2, '0')}';
  }

  /// Закрывает прошедшие дни: штраф за пропуск тренировки и за вредную еду.
  void rollDay(int today) {
    final msgs = <String>[];
    final startLvl = level;
    int missed = 0;
    for (int d = lastCheck; d < today; d++) {
      if (!trainedDays.contains(d)) {
        missed++;
        if (level > 1) level--;
        xp = 0;
      }
      final sev = junkSeverity(d);
      if (sev > 0) {
        final loss = penaltyXp(sev);
        _loseXp(loss);
        msgs.add('Вредная еда за ${_dm(d)}: ${junkCount(d)} шт. '
            '(дней за неделю: ${junkDaysInWeek(d)}), штраф −$loss опыта.');
      }
    }
    if (missed > 0) {
      msgs.insert(0, 'Пропущено дней без тренировки: $missed.');
    }
    if (level < startLvl) {
      msgs.add('Уровень понижен: $startLvl → $level.');
    }
    if (msgs.isNotEmpty) penaltyMsg = msgs.join('\n');
    lastCheck = today;
    if (taskDay != today) {
      progress = {};
      taskDay = today;
    }
  }

  // ---------- Достижения ----------
  double _total(String id) =>
      history.values.fold(0.0, (a, m) => a + (m[id] ?? 0.0));

  double _runWeek() {
    final t = todayNum();
    double sum = 0;
    for (int d = t - 6; d <= t; d++) {
      sum += history[d]?['run'] ?? 0.0;
    }
    return sum;
  }

  int _bestStreak(Iterable<int> days) {
    final list = days.toSet().toList()..sort();
    int best = 0, cur = 0, prev = -999;
    for (final d in list) {
      cur = d == prev + 1 ? cur + 1 : 1;
      prev = d;
      if (cur > best) best = cur;
    }
    return best;
  }

  // Лучшая серия дней, когда еда записана и вредного не было (без сегодня).
  int _bestCleanStreak() {
    final today = todayNum();
    final byDay = <int, bool>{}; // день -> была ли вредная еда
    for (final m in meals) {
      if (m.day >= today) continue;
      byDay[m.day] = (byDay[m.day] ?? false) || m.fast;
    }
    return _bestStreak(byDay.entries.where((e) => !e.value).map((e) => e.key));
  }

  /// Текущий прогресс по достижению (в тех же единицах, что и target).
  double achievementProgress(Achievement a) {
    switch (a.id) {
      case 'first':
        return tasks.any((t) => _total(t.id) > 0) ? 1 : 0;
      case 'marathon':
        return _runWeek();
      case 'runTotal':
        return _total('run');
      case 'streak7':
      case 'streak30':
        return _bestStreak(trainedDays).toDouble();
      case 'level10':
        return level.toDouble();
      case 'cleanweek':
        return _bestCleanStreak().toDouble();
      default: // burpee, squat, push, pull, dips, crunch: id совпадает с упражнением
        return _total(a.id);
    }
  }

  void _checkAchievements() {
    for (final a in achievements) {
      if (unlocked.containsKey(a.id)) continue;
      if (achievementProgress(a) >= a.target) {
        unlocked[a.id] = todayNum();
        newAchievements.add(a.name);
      }
    }
  }

  void clearAchievements() {
    newAchievements = [];
    notifyListeners();
  }

  // Добавляет выполненный объём. Возвращает, на сколько уровней вырос игрок.
  Future<int> addVolume(TaskDef t, double amount) async {
    if (amount <= 0) return 0;
    progress[t.id] = (progress[t.id] ?? 0) + amount;
    history[todayNum()] = Map.of(progress);
    xp += (amount * t.xpPer).round();
    if (!trainedDays.contains(todayNum())) trainedDays.add(todayNum());
    int up = 0;
    while (xp >= xpNeed) {
      xp -= xpNeed;
      level++;
      up++;
    }
    _checkAchievements();
    await _save();
    notifyListeners();
    return up;
  }

  Future<void> addMeal(String name, bool fast, {bool remember = false}) async {
    meals.add(
        Meal(todayNum(), name, fast, DateTime.now().millisecondsSinceEpoch));
    if (remember &&
        !customFoods.any((f) => f.name == name) &&
        !healthyFoods.any((f) => f.name == name) &&
        !fastFoods.any((f) => f.name == name)) {
      customFoods.add(Food(name, fast));
    }
    await _save();
    notifyListeners();
  }

  void clearPenalty() {
    penaltyMsg = '';
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('level', level);
    await p.setInt('xp', xp);
    await p.setInt('taskDay', taskDay);
    await p.setInt('lastCheck', lastCheck);
    await p.setBool('welcomed', welcomed);
    await p.setString('nick', nickname);
    await p.setString('email', email);
    await p.setInt('avatar', avatar);
    await p.setInt('joinDay', joinDay);
    await p.setBool('setupDone', setupDone);
    await p.setBool('expDone', expDone);
    await p.setStringList('sportExp',
        sportExp.entries.map((e) => '${e.key}:${e.value}').toList());
    await p.setStringList(
        'ach', unlocked.entries.map((e) => '${e.key}:${e.value}').toList());
    await p.setString('gender', gender);
    await p.setInt('age', age);
    await p.setDouble('weight', weight);
    await p.setDouble('height', height);
    await p.setStringList(
        'history',
        history.entries
            .map((e) =>
                '${e.key}|${e.value.entries.map((x) => '${x.key}:${x.value}').join(',')}')
            .toList());
    await p.setStringList('progress',
        progress.entries.map((e) => '${e.key}:${e.value}').toList());
    await p.setStringList('trained', trainedDays.map((e) => '$e').toList());
    await p.setStringList('meals', meals.map((m) => m.encode()).toList());
    await p.setStringList('customFoods',
        customFoods.map((f) => '${f.name}|${f.fast ? 1 : 0}').toList());
  }
}
