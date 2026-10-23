import 'package:flutter/material.dart';
import 'achievements.dart';
import 'body_type.dart';
import 'Experience.dart';
import 'experience_page.dart';
import 'game_state.dart';
import 'setup_page.dart';
import 'widgets.dart';

const avatarIcons = [
  Icons.person,
  Icons.sports_gymnastics,
  Icons.directions_run,
  Icons.fitness_center,
  Icons.sports_martial_arts,
  Icons.self_improvement,
  Icons.bolt,
  Icons.local_fire_department,
];

class ProfilePage extends StatefulWidget {
  final GameState s;
  final ScrollController controller;
  const ProfilePage(this.s, this.controller, {super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final nick = TextEditingController(text: widget.s.nickname);
  late final mail = TextEditingController(text: widget.s.email);
  late int avatar = widget.s.avatar;

  @override
  void dispose() {
    nick.dispose();
    mail.dispose();
    super.dispose();
  }

  void _chooseAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < avatarIcons.length; i++)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    setState(() => avatar = i);
                    Navigator.pop(ctx);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: i == avatar
                        ? Theme.of(ctx).colorScheme.primary
                        : const Color(0xFF0E1A30),
                    child: Icon(avatarIcons[i], size: 30),
                  ),
                ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final cs = Theme.of(context).colorScheme;
    return Scrollbar(
      controller: widget.controller,
      thumbVisibility: true,
      interactive: true,
      thickness: 8,
      radius: const Radius.circular(8),
      child: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Center(
            child: GestureDetector(
              onTap: _chooseAvatar,
              child: Stack(children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFF0E1A30),
                  child:
                      Icon(avatarIcons[avatar], size: 52, color: cs.secondary),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: cs.primary,
                    child:
                        const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(s.mainTitle,
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          const SizedBox(height: 4),
          Center(child: Text('${s.rank} · уровень ${s.level}')),
          const SizedBox(height: 24),
          TextField(
            controller: nick,
            decoration: const InputDecoration(
                labelText: 'Ник',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          Text('Аккаунт', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: mail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Text(
              'В игре с ${dateStr(s.joinDay)}. Данные хранятся на этом устройстве.',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Сохранить'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                s.saveProfile(nick.text.trim(), mail.text.trim(), avatar);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Профиль сохранён')));
              },
            ),
          ),
          const SizedBox(height: 24),
          if (s.bodyType != null) ...[
            Text('Параметры тела',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(children: [
                ListTile(
                  leading: Icon(s.gender == 'm' ? Icons.male : Icons.female),
                  title: Text(s.gender == 'm' ? 'Мужчина' : 'Женщина'),
                  subtitle: Text(
                      '${s.age} лет · ${fmt(s.weight)} кг · ${fmt(s.height)} см'),
                ),
                ListTile(
                  leading:
                      Icon(bodyInfos[s.bodyType]!.icon, color: cs.secondary),
                  title: Text(bodyInfos[s.bodyType]!.name),
                  subtitle: Text(bodyInfos[s.bodyType]!.tip),
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Изменить параметры'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SetupPage(s, editing: true))),
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ],
          Text('Титулы', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(children: [
              if (s.sportExp.isEmpty)
                const ListTile(
                  leading: Icon(Icons.military_tech, color: Colors.amber),
                  title: Text('Новобранец'),
                  subtitle: Text('Опыта тренировок нет'),
                ),
              for (final e in s.sportExp.entries)
                ListTile(
                  leading: Icon(sportById(e.key).icon, color: cs.secondary),
                  title: Text(sportById(e.key).title),
                  subtitle: Text(
                      '${sportById(e.key).name} · ${durationName(e.value)}'),
                ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Изменить спортивный опыт'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ExperiencePage(s, editing: true))),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Достижений получено'),
                trailing: Text('${s.unlocked.length} / ${achievements.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Дней с тренировкой'),
                trailing: Text('${s.trainedDays.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Показать приветствие снова'),
                onTap: s.showWelcomeAgain,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
