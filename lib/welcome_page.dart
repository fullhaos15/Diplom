import 'package:flutter/material.dart';
import 'game_state.dart';

class WelcomePage extends StatefulWidget {
  final GameState s;
  const WelcomePage(this.s, {super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final ctrl = PageController();
  int page = 0;

  static const slides = [
    (
      Icons.fitness_center,
      'Добро пожаловать в FitQuest',
      'Фитнес, превращённый в игру. Тренируйся, получай опыт и поднимайся от уровня «Новичок» до «Легенды».'
    ),
    (
      Icons.trending_up,
      'Тренировки и уровни',
      'Отжимания, подтягивания, приседания, берпи, брусья, пресс и бег. Опыт даётся за каждое повторение и километр: главное — объём. С ростом уровня цели становятся сложнее.'
    ),
    (
      Icons.warning_amber_rounded,
      'Не пропускай',
      'Каждый день без тренировки снижает уровень на 1 и сбрасывает опыт. Тренируйся регулярно, чтобы не терять прогресс.'
    ),
    (
      Icons.restaurant,
      'Питание',
      'Записывай, что ты ешь. Чем больше и чаще вредной еды, тем сильнее штраф в конце дня: сначала сгорает опыт, а при частом фастфуде теряется уровень.'
    ),
    (
      Icons.calendar_month,
      'Следи за прогрессом',
      'На вкладке «Прогресс» смотри упражнения и еду за любой день. Получай достижения и титулы за спортивный опыт, а в профиле задай ник и аватар.'
    ),
  ];

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = page == slides.length - 1;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: widget.s.setWelcomed,
                child: const Text('Пропустить')),
          ),
          Expanded(
            child: PageView(
              controller: ctrl,
              onPageChanged: (i) => setState(() => page = i),
              children: [
                for (final sl in slides)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: const Color(0xFF0E1A30),
                            child: Icon(sl.$1, size: 56, color: cs.secondary),
                          ),
                          const SizedBox(height: 32),
                          Text(sl.$2,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          Text(sl.$3,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey.shade400)),
                        ]),
                  ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int i = 0; i < slides.length; i++)
              Container(
                margin: const EdgeInsets.all(4),
                width: i == page ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: i == page ? cs.primary : Colors.blueGrey.shade700,
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: last
                    ? widget.s.setWelcomed
                    : () => ctrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut),
                child: Text(last ? 'Начать' : 'Далее'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
