import 'package:flutter/material.dart';

class Sport {
  final String id, name, title; // title - титул за этот вид спорта
  final IconData icon;
  const Sport(this.id, this.name, this.title, this.icon);
}

const sports = [
  Sport('gym', 'Тренажёрный зал', 'Железный титан', Icons.fitness_center),
  Sport('swim', 'Плавание', 'Воин моря', Icons.pool),
  Sport('volley', 'Волейбол', 'Повелитель сетки', Icons.sports_volleyball),
  Sport('box', 'Бокс', 'Гладиатор', Icons.sports_mma),
  Sport('football', 'Футбол', 'Король газона', Icons.sports_soccer),
  Sport('basket', 'Баскетбол', 'Покоритель кольца', Icons.sports_basketball),
  Sport('run', 'Бег', 'Ветер степей', Icons.directions_run),
  Sport('wrestle', 'Борьба', 'Несокрушимый', Icons.sports_kabaddi),
  Sport('tennis', 'Теннис', 'Ас корта', Icons.sports_tennis),
  Sport('calis', 'Гимнастика / воркаут', 'Мастер турника',
      Icons.sports_gymnastics),
];

Sport sportById(String id) => sports.firstWhere((s) => s.id == id);

// (месяцев занятий, подпись)
const durationOptions = [
  (3, 'Меньше 6 месяцев'),
  (9, '6–12 месяцев'),
  (24, '1–3 года'),
  (48, 'Больше 3 лет'),
];

String durationName(int months) => durationOptions
    .firstWhere((d) => d.$1 == months, orElse: () => durationOptions.first)
    .$2;

/// Стартовый уровень: от самого долгого стажа + бонус за разнообразие (до +2).
int startLevel(Map<String, int> exp) {
  if (exp.isEmpty) return 1;
  final maxMonths = exp.values.reduce((a, b) => a > b ? a : b);
  final base = maxMonths >= 48
      ? 7
      : maxMonths >= 24
          ? 5
          : maxMonths >= 9
              ? 3
              : 2;
  final extra = (exp.length - 1).clamp(0, 2).toInt();
  return base + extra;
}

/// Титулы за виды спорта. Без опыта выдаётся «Новобранец».
List<String> earnedTitles(Map<String, int> exp) {
  if (exp.isEmpty) return ['Новобранец'];
  return [for (final id in exp.keys) sportById(id).title];
}

/// Главный титул для профиля: за вид спорта с самым большим стажем.
String mainTitleOf(Map<String, int> exp) {
  if (exp.isEmpty) return 'Новобранец';
  final best = exp.entries.reduce((a, b) => b.value > a.value ? b : a);
  return sportById(best.key).title;
}
