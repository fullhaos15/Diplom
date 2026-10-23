import 'package:flutter/material.dart';
import 'game_state.dart';

String fmt(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

DateTime dateOf(int day) => DateTime.utc(2020).add(Duration(days: day));
int dayOf(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2020)).inDays;

String dateStr(int day) {
  final d = dateOf(day);
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String dayLabel(int day) {
  final today = todayNum();
  if (day == today) return 'Сегодня';
  if (day == today - 1) return 'Вчера';
  return dateStr(day);
}

const _weekdays = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье'
];
String weekdayName(int day) => _weekdays[dateOf(day).weekday - 1];

/// Лента приёмов пищи: время - точка на линии - карточка
List<Widget> mealTimeline(List<Meal> meals) => [
      for (int i = 0; i < meals.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(meals[i].time,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Column(children: [
              const SizedBox(height: 14),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meals[i].fast
                      ? Colors.deepOrange
                      : Colors.lightGreenAccent,
                ),
              ),
              if (i < meals.length - 1)
                Expanded(
                    child:
                        Container(width: 2, color: Colors.blueGrey.shade700)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: Icon(meals[i].fast ? Icons.fastfood : Icons.eco,
                      color: meals[i].fast
                          ? Colors.deepOrange
                          : Colors.lightGreenAccent),
                  title: Text(meals[i].name),
                  subtitle:
                      Text(meals[i].fast ? 'Вредная еда' : 'Полезная еда'),
                ),
              ),
            ),
          ]),
        ),
    ];
