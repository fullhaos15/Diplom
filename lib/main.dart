import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'achievements_page.dart';
import 'experience_page.dart';
import 'game_state.dart';
import 'profile_page.dart';
import 'setup_page.dart';
import 'progress_page.dart';
import 'welcome_page.dart';
import 'widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = GameState();
  await state.load();
  runApp(FitQuestApp(state));
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class Root extends StatelessWidget {
  final GameState s;
  const Root(this.s, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (_, __) => !s.welcomed
            ? WelcomePage(s)
            : !s.setupDone
                ? SetupPage(s)
                : !s.expDone
                    ? ExperiencePage(s)
                    : HomePage(s),
      );
}

class FitQuestApp extends StatelessWidget {
  final GameState s;
  const FitQuestApp(this.s, {super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FitQuest',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const AppScrollBehavior(),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF05080F),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3D8BFF),
            secondary: Color(0xFF00C2FF),
            surface: Color(0xFF0B1424),
            onPrimary: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF05080F),
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF0E1A30),
            surfaceTintColor: Colors.transparent,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color(0xFF0B1424),
            indicatorColor: Color(0xFF1B3A6B),
          ),
        ),
        home: Root(s),
      );
}

class HomePage extends StatefulWidget {
  final GameState s;
  const HomePage(this.s, {super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final ctrls = List.generate(5, (_) => ScrollController());

  @override
  void dispose() {
    for (final c in ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.s,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('FitQuest')),
        body: [
          TrainingPage(widget.s, ctrls[0]),
          ProgressPage(widget.s, ctrls[1]),
          FoodPage(widget.s, ctrls[2]),
          AchievementsPage(widget.s, ctrls[3]),
          ProfilePage(widget.s, ctrls[4]),
        ][tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.fitness_center), label: 'Тренировки'),
            NavigationDestination(
                icon: Icon(Icons.show_chart), label: 'Прогресс'),
            NavigationDestination(
                icon: Icon(Icons.restaurant), label: 'Питание'),
            NavigationDestination(
                icon: Icon(Icons.emoji_events), label: 'Достижения'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}

class TrainingPage extends StatelessWidget {
  final GameState s;
  final ScrollController controller;
  const TrainingPage(this.s, this.controller, {super.key});

  Future<void> _ask(BuildContext context, TaskDef t) async {
    final c = TextEditingController();
    final v = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.title),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(labelText: 'Сколько выполнено (${t.unit})'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(
                ctx, double.tryParse(c.text.replaceAll(',', '.'))),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (v == null || v <= 0) return;
    final up = await s.addVolume(t, v);
    if (up > 0 && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Новый уровень: ${s.level}!')));
    }
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
              if (s.penaltyMsg.isNotEmpty)
                Card(
                  color: const Color(0xFF3A1218),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.redAccent),
                    title: Text(s.penaltyMsg),
                    trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: s.clearPenalty),
                  ),
                ),
              if (s.newAchievements.isNotEmpty)
                Card(
                  color: const Color(0xFF3A2E0A),
                  child: ListTile(
                    leading:
                        const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(
                        'Получено достижение: ${s.newAchievements.join(', ')}'),
                    trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: s.clearAchievements),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Уровень ${s.level} — ${s.rank}',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                            value: s.xp / s.xpNeed, minHeight: 10),
                        const SizedBox(height: 4),
                        Text('Опыт: ${s.xp} / ${s.xpNeed}'),
                        if (s.todayJunk > 0) ...[
                          const SizedBox(height: 8),
                          Chip(
                            avatar:
                                const Icon(Icons.fastfood, color: Colors.white),
                            label: Text(
                                'Вредной еды сегодня: ${s.todayJunk}. '
                                'В конце дня: −${s.todayPenalty} опыта',
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.deepOrange,
                          ),
                        ],
                      ]),
                ),
              ),
              const SizedBox(height: 8),
              Text('Тренировка на сегодня',
                  style: Theme.of(context).textTheme.titleMedium),
              const Text(
                  'Опыт начисляется за каждое повторение и километр. '
                  'Закрывать весь список не обязательно.',
                  style: TextStyle(color: Colors.grey)),
              for (final t in tasks)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 4),
                              Text(
                                  '${fmt(s.progress[t.id] ?? 0)} / ${fmt(s.target(t))} ${t.unit}'
                                  '  ·  ${fmt(t.xpPer)} оп. за ${t.unit == 'км' ? 'км' : 'повтор'}'),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: ((s.progress[t.id] ?? 0) / s.target(t))
                                    .clamp(0.0, 1.0),
                              ),
                            ]),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () => _ask(context, t),
                      ),
                    ]),
                  ),
                ),
              const SizedBox(height: 8),
              const Text('Пропустил день без тренировки — потеряешь уровень!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ]));
  }
}

class FoodPage extends StatelessWidget {
  final GameState s;
  final ScrollController controller;
  const FoodPage(this.s, this.controller, {super.key});

  Widget chips(List<Food> items) => Wrap(spacing: 8, runSpacing: 4, children: [
        for (final f in items)
          ActionChip(
            avatar: Icon(f.fast ? Icons.fastfood : Icons.eco,
                color: f.fast ? Colors.deepOrange : Colors.lightGreenAccent),
            label: Text(f.name),
            onPressed: () => s.addMeal(f.name, f.fast),
          ),
      ]);

  Future<void> _custom(BuildContext context) async {
    final c = TextEditingController();
    bool fast = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Своя еда'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: c,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    label: Text('Полезная'),
                    icon: Icon(Icons.eco)),
                ButtonSegment(
                    value: true,
                    label: Text('Вредная'),
                    icon: Icon(Icons.fastfood)),
              ],
              selected: {fast},
              onSelectionChanged: (v) => setSt(() => fast = v.first),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                final name = c.text.trim().replaceAll('|', ' ');
                if (name.isNotEmpty) s.addMeal(name, fast, remember: true);
                Navigator.pop(ctx);
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleMedium;
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
              FilledButton.icon(
                onPressed: () => _custom(context),
                icon: const Icon(Icons.add),
                label: const Text('Добавить свою еду'),
              ),
              if (s.customFoods.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Мои продукты', style: t),
                chips(s.customFoods),
              ],
              const SizedBox(height: 16),
              Text('Полезная еда', style: t),
              chips(healthyFoods),
              const SizedBox(height: 16),
              Text('Вредная еда', style: t),
              chips(fastFoods),
              const Divider(height: 32),
              Text('Лента питания', style: t),
              if (s.meals.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Пока ничего')),
              for (final e in s.mealsByDay.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(children: [
                    Text(dayLabel(e.key),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text(
                        'Вредного: ${e.value.where((m) => m.fast).length} из ${e.value.length}',
                        style: const TextStyle(color: Colors.grey)),
                  ]),
                ),
                ...mealTimeline(e.value),
              ],
            ]));
  }
}
