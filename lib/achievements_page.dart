import 'package:flutter/material.dart';
import 'achievements.dart';
import 'game_state.dart';
import 'widgets.dart';

class AchievementsPage extends StatelessWidget {
  final GameState s;
  final ScrollController controller;
  const AchievementsPage(this.s, this.controller, {super.key});

  Widget _tile(BuildContext context, Achievement a) {
    final done = s.unlocked.containsKey(a.id);
    final p = done
        ? a.target
        : s.achievementProgress(a).clamp(0.0, a.target).toDouble();
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: done ? const Color(0xFF2A2410) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF05080F),
            child: Icon(a.icon,
                size: 26, color: done ? Colors.amber : Colors.blueGrey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(a.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (done)
                  const Icon(Icons.check_circle, color: Colors.amber, size: 20),
              ]),
              const SizedBox(height: 2),
              Text(a.desc, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              if (done)
                Text('Получено ${dateStr(s.unlocked[a.id]!)}',
                    style: const TextStyle(color: Colors.amber))
              else ...[
                LinearProgressIndicator(value: p / a.target),
                const SizedBox(height: 4),
                Text('${fmt(p)} / ${fmt(a.target)}',
                    style: TextStyle(color: cs.secondary, fontSize: 12)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      interactive: true,
      thickness: 8,
      radius: const Radius.circular(8),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Получено ${s.unlocked.length} из ${achievements.length}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: s.unlocked.length / achievements.length,
                        minHeight: 8),
                  ]),
            ),
          ),
          for (final a in achievements) _tile(context, a),
        ],
      ),
    );
  }
}
