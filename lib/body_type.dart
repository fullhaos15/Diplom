import 'package:flutter/material.dart';

enum BodyType { ectomorph, mesomorph, endomorph }

class BodyInfo {
  final String name, description, tip;
  final IconData icon;
  const BodyInfo(this.name, this.icon, this.description, this.tip);
}

const bodyInfos = {
  BodyType.ectomorph: BodyInfo(
    'Эктоморф',
    Icons.directions_run,
    'Худощавое телосложение, узкие кости, быстрый обмен веществ. Трудно набирать вес.',
    'Делай упор на силовые упражнения, не перегружай кардио и следи, чтобы хватало калорий.',
  ),
  BodyType.mesomorph: BodyInfo(
    'Мезоморф',
    Icons.sports_gymnastics,
    'Атлетичное телосложение, широкие плечи, мышцы набираются сравнительно легко.',
    'Подходит почти любой формат: сочетай силовые упражнения и бег.',
  ),
  BodyType.endomorph: BodyInfo(
    'Эндоморф',
    Icons.fitness_center,
    'Крупное телосложение, медленный обмен веществ, склонность к накоплению жира.',
    'Больше кардио и бега, следи за питанием и старайся избегать фастфуда.',
  ),
};

double bmi(double weight, double height) =>
    weight / ((height / 100) * (height / 100));

/// Приблизительная оценка типа телосложения по полу, возрасту, росту и весу.
/// Используется индекс массы тела с разными порогами для мужчин и женщин,
/// с небольшим сдвигом порогов с возрастом.
BodyType detectBodyType(String gender, int age, double weight, double height) {
  final b = bmi(weight, height);
  final shift = (age.clamp(18, 60) - 25) * 0.05;
  final male = gender != 'f';
  final low = (male ? 20.5 : 19.5) + shift;
  final high = (male ? 25.5 : 24.5) + shift;
  if (b < low) return BodyType.ectomorph;
  if (b >= high) return BodyType.endomorph;
  return BodyType.mesomorph;
}
