import 'package:flutter/material.dart';

class Achievement {
  final String id, name, desc;
  final IconData icon;
  final double target;
  const Achievement(this.id, this.name, this.desc, this.icon, this.target);
}

const achievements = [
  Achievement('first', 'Первый шаг', 'Выполни любое упражнение в первый раз.',
      Icons.flag, 1),
  Achievement('marathon', 'Марафонец', 'Пробеги 100 км за неделю (7 дней).',
      Icons.directions_run, 100),
  Achievement('burpee', 'Прыжки к небу', 'Сделай 1000 берпи.',
      Icons.rocket_launch, 1000),
  Achievement(
      'squat', 'Стальные ноги', 'Сделай 1000 приседаний.', Icons.shield, 1000),
  Achievement('push', 'Каменные руки', 'Сделай 1000 отжиманий.',
      Icons.fitness_center, 1000),
  Achievement('pull', 'Орёл на турнике', 'Сделай 500 подтягиваний.',
      Icons.sports_gymnastics, 500),
  Achievement('dips', 'Король брусьев', 'Сделай 500 повторений на брусьях.',
      Icons.military_tech, 500),
  Achievement('crunch', 'Стальной пресс', 'Сделай 1500 скручиваний на пресс.',
      Icons.local_fire_department, 1500),
  Achievement(
      'runTotal', 'Дальний путь', 'Пробеги суммарно 300 км.', Icons.route, 300),
  Achievement('streak7', 'Железная неделя', 'Тренируйся 7 дней подряд.',
      Icons.calendar_month, 7),
  Achievement('streak30', 'Несгибаемый', 'Тренируйся 30 дней подряд.',
      Icons.emoji_events, 30),
  Achievement(
      'level10', 'Десятый рубеж', 'Достигни 10 уровня.', Icons.trending_up, 10),
  Achievement('cleanweek', 'Чистая неделя',
      '7 дней подряд записывай еду и не ешь вредное.', Icons.eco, 7),
];