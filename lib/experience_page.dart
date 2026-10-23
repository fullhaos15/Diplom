import 'package:flutter/material.dart';
import 'Experience.dart';
import 'game_state.dart';

/// Меню «Был ли раньше опыт тренировок?»: виды спорта + сколько занимался.
class ExperiencePage extends StatefulWidget {
  final GameState s;
  final bool editing;
  const ExperiencePage(this.s, {this.editing = false, super.key});
  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  late final Map<String, int> sel = Map.of(widget.s.sportExp);

  Widget _sportCard(Sport sp) {
    final on = sel.containsKey(sp.id);
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: on ? cs.secondary : Colors.transparent, width: 2),
      ),
      child: Column(children: [
        CheckboxListTile(
          value: on,
          onChanged: (v) => setState(() {
            if (v == true) {
              sel[sp.id] = durationOptions.first.$1;
            } else {
              sel.remove(sp.id);
            }
          }),
          secondary: Icon(sp.icon, color: on ? cs.secondary : Colors.grey),
          title: Text(sp.name),
          subtitle: Text('Титул: ${sp.title}'),
        ),
        if (on)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(spacing: 8, runSpacing: 4, children: [
                for (final d in durationOptions)
                  ChoiceChip(
                    label: Text(d.$2),
                    selected: sel[sp.id] == d.$1,
                    onSelected: (_) => setState(() => sel[sp.id] = d.$1),
                  ),
              ]),
            ),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = earnedTitles(sel);
    return Scaffold(
      appBar:
          widget.editing ? AppBar(title: const Text('Спортивный опыт')) : null,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          if (!widget.editing) ...[
            Text('Был ли у тебя опыт тренировок?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
                'Отметь виды спорта, которыми занимался, и как долго. '
                'От этого зависят стартовый уровень и титулы. '
                'Если опыта нет — просто нажми кнопку внизу.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
          ],
          for (final sp in sports) _sportCard(sp),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.editing)
                      const Text('Уровень не изменится, обновятся титулы.')
                    else
                      Text(sel.isEmpty
                          ? 'Без опыта: старт с 1 уровня'
                          : 'Стартовый уровень: ${startLevel(sel)}'),
                    const SizedBox(height: 4),
                    Text('Титулы: ${titles.join(', ')}'),
                  ]),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await widget.s.saveExperience(sel, first: !widget.editing);
                if (widget.editing && context.mounted) Navigator.pop(context);
              },
              child: Text(widget.editing
                  ? 'Сохранить'
                  : sel.isEmpty
                      ? 'Раньше не занимался — начать'
                      : 'Продолжить'),
            ),
          ),
        ]),
      ),
    );
  }
}
