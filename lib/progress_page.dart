import 'package:flutter/material.dart';
import 'game_state.dart';
import 'widgets.dart';

class ProgressPage extends StatefulWidget {
  final GameState s;
  final ScrollController controller;
  const ProgressPage(this.s, this.controller, {super.key});
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int day = todayNum();

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: dateOf(day),
      firstDate: DateTime(2020),
      lastDate: dateOf(todayNum()),
    );
    if (d != null) setState(() => day = dayOf(d));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final ex = s.history[day] ?? {};
    final meals = s.mealsByDay[day] ?? [];
    final t = Theme.of(context).textTheme.titleMedium;
    return Scrollbar(
      controller: widget.controller,
      thumbVisibility: true,
      interactive: true,
      thickness: 8,
      radius: const Radius.circular(8),
      child: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => day--),
              ),
              Expanded(
                child: InkWell(
                  onTap: _pick,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(children: [
                      Text(dateStr(day),
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                          day == todayNum()
                              ? 'Сегодня, ${weekdayName(day)}'
                              : weekdayName(day),
                          style: const TextStyle(color: Colors.grey)),
                    ]),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    day < todayNum() ? () => setState(() => day++) : null,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Упражнения', style: t),
          const SizedBox(height: 8),
          if (!tasks.any((e) => (ex[e.id] ?? 0) > 0))
            const Text('В этот день тренировок нет',
                style: TextStyle(color: Colors.grey)),
          for (final e in tasks)
            if ((ex[e.id] ?? 0) > 0)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(e.title),
                  trailing: Text('${fmt(ex[e.id]!)} ${e.unit}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          const Divider(height: 32),
          Text('Питание', style: t),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            const Text('В этот день записей о еде нет',
                style: TextStyle(color: Colors.grey)),
          ...mealTimeline(meals),
        ],
      ),
    );
  }
}
