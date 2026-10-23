import 'package:flutter/material.dart';
import 'body_type.dart';
import 'game_state.dart';
import 'widgets.dart';

class SetupPage extends StatefulWidget {
  final GameState s;
  final bool editing;
  const SetupPage(this.s, {this.editing = false, super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late String gender = widget.s.gender;
  late int age = widget.s.age;
  late double weight = widget.s.weight;
  late double height = widget.s.height;

  Widget _genderCard(String value, IconData icon, String label) {
    final selected = gender == value;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? const Color(0xFF1B3A6B) : const Color(0xFF0E1A30),
            border: Border.all(
                color: selected ? cs.secondary : Colors.transparent, width: 2),
          ),
          child: Column(children: [
            Icon(icon, size: 64, color: selected ? cs.secondary : Colors.grey),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _slider(String label, String value, double v, double min, double max,
      int div, ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
      Slider(
          value: v.clamp(min, max),
          min: min,
          max: max,
          divisions: div,
          onChanged: onChanged),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final type =
        gender.isEmpty ? null : detectBodyType(gender, age, weight, height);
    final info = type == null ? null : bodyInfos[type]!;
    return Scaffold(
      appBar:
          widget.editing ? AppBar(title: const Text('Параметры тела')) : null,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          if (!widget.editing) ...[
            Text('Расскажи о себе',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Это нужно, чтобы определить твой тип телосложения.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
          ],
          Row(children: [
            _genderCard('m', Icons.male, 'Мужчина'),
            const SizedBox(width: 16),
            _genderCard('f', Icons.female, 'Женщина'),
          ]),
          const SizedBox(height: 24),
          _slider('Возраст', '$age лет', age.toDouble(), 10, 80, 70,
              (v) => setState(() => age = v.round())),
          _slider('Вес', '${fmt(weight)} кг', weight, 30, 200, 340,
              (v) => setState(() => weight = (v * 2).round() / 2)),
          _slider('Рост', '${fmt(height)} см', height, 120, 220, 100,
              (v) => setState(() => height = v.roundToDouble())),
          const SizedBox(height: 8),
          if (info != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(info.icon,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 32),
                        const SizedBox(width: 12),
                        Text('Тип: ${info.name}',
                            style: Theme.of(context).textTheme.titleLarge),
                      ]),
                      const SizedBox(height: 8),
                      Text(info.description),
                      const SizedBox(height: 8),
                      Text('Совет: ${info.tip}'),
                      const SizedBox(height: 8),
                      Text(
                          'ИМТ: ${bmi(weight, height).toStringAsFixed(1)}. Это приблизительная оценка '
                          'по полу, возрасту, росту и весу.',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ]),
              ),
            )
          else
            const Text('Выбери пол, чтобы увидеть свой тип телосложения.',
                style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: gender.isEmpty
                  ? null
                  : () async {
                      await widget.s.saveBody(gender, age, weight, height);
                      if (widget.editing && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: Text(widget.editing ? 'Сохранить' : 'Продолжить'),
            ),
          ),
        ]),
      ),
    );
  }
}
