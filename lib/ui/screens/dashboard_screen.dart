import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/kaza_logs_provider.dart';
import '../../providers/quran_logs_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../src/features/kaza/domain/entities/prayer_time.dart';
import '../theme/app_colors.dart';
import 'prayer_history_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _quranPagesController = TextEditingController();

  String _todayKey() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.toIso8601String().split('T').first;
  }

  @override
  void dispose() {
    _quranPagesController.dispose();
    super.dispose();
  }

  String _prayerLabel(PrayerTime prayerTime) {
    return switch (prayerTime) {
      PrayerTime.sabah => 'Sabah',
      PrayerTime.ogle => 'Öğle',
      PrayerTime.ikindi => 'İkindi',
      PrayerTime.aksam => 'Akşam',
      PrayerTime.yatsi => 'Yatsı',
      PrayerTime.vitir => 'Vitir',
    };
  }

  Future<void> _onAddKaza(PrayerTime prayerTime) async {
    final result = await ref
        .read(kazaLogsProvider.notifier)
        .addKaza(prayerTime: prayerTime, count: 1);

    if (!mounted) {
      return;
    }

    final message = result.levelUp
        ? 'Tebrikler! Seviye ${result.newLevel} oldun.'
        : 'Harika, 1 adım daha yaklaştın!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _onAddQuranPages() async {
    final rawInput = _quranPagesController.text.trim();
    final pages = rawInput.isEmpty ? 1 : int.tryParse(rawInput);

    if (pages == null || pages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir sayfa sayısı gir.')),
      );
      return;
    }

    await ref.read(quranLogsProvider.notifier).addTodayPages(pages);
    _quranPagesController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$pages sayfa eklendi 📖'),
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  Future<void> _onUndoKaza(PrayerTime prayerTime) async {
    final removed = await ref
        .read(kazaLogsProvider.notifier)
        .undoTodayKaza(prayerTime: prayerTime);

    if (!mounted) {
      return;
    }

    if (removed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bugün geri alınacak kaza yok.'),
          duration: Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('$removed ${_prayerLabel(prayerTime)} kazası geri alındı ↩️'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _onRemoveQuranPages() async {
    final rawInput = _quranPagesController.text.trim();
    final pages = rawInput.isEmpty ? 1 : int.tryParse(rawInput);

    if (pages == null || pages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir sayfa sayısı gir.'),
          duration: Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    final removed =
        await ref.read(quranLogsProvider.notifier).removeTodayPages(pages);
    _quranPagesController.clear();

    if (!mounted) {
      return;
    }

    if (removed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bugün çıkarılacak sayfa yok.'),
          duration: Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removed sayfa çıkarıldı ↩️'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _openPrayerHistory({
    required String prayerName,
    required Color prayerColor,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrayerHistoryScreen(
          prayerName: prayerName,
          prayerColor: prayerColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final kazaLogsAsync = ref.watch(kazaLogsProvider);
    final quranLogsAsync = ref.watch(quranLogsProvider);

    return profileAsync.when(
      data: (data) {
        if (data == null) {
          return const Center(
            child: Text('Profil bulunamadi. Onboarding adimini tamamlayin.'),
          );
        }

        final profile = data.profile;
        final today = _todayKey();

        final todayKazaByPrayer = <PrayerTime, int>{
          for (final prayer in PrayerTime.values) prayer: 0,
        };

        final kazaLogs = kazaLogsAsync.valueOrNull ?? const [];
        for (final log in kazaLogs) {
          final date = DateTime(log.date.year, log.date.month, log.date.day)
              .toIso8601String()
              .split('T')
              .first;
          if (date != today) {
            continue;
          }
          todayKazaByPrayer[log.prayerTime] =
              (todayKazaByPrayer[log.prayerTime] ?? 0) + log.count;
        }

        final quranLogs = quranLogsAsync.valueOrNull ?? const [];
        final todayQuranPages = quranLogs
            .where(
              (log) =>
                  DateTime(log.date.year, log.date.month, log.date.day)
                      .toIso8601String()
                      .split('T')
                      .first ==
                  today,
            )
            .fold<int>(0, (sum, log) => sum + log.pages);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _LevelCard(
              level: profile.level,
              points: profile.motivationPoints,
              progress: data.levelProgress,
              pointsToNextLevel: data.pointsToNextLevel,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bugüne Kadar Kılınan Toplam Kaza Sayıları',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...PrayerTime.values.map((time) {
              final total = data.completedByPrayer[time] ?? 0;
              final prayerName = _prayerLabel(time);
              final prayerColor = AppColors.prayerColor(time);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PrayerCard(
                  title: prayerName,
                  total: total,
                  canUndo: (todayKazaByPrayer[time] ?? 0) > 0,
                  color: prayerColor,
                  onCardTap: () => _openPrayerHistory(
                    prayerName: prayerName,
                    prayerColor: prayerColor,
                  ),
                  onUndo: () => _onUndoKaza(time),
                  onTap: () => _onAddKaza(time),
                ),
              );
            }),
            const SizedBox(height: 10),
            Card.filled(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bugün kaç sayfa Kuran okudun?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quranPagesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Sayfa',
                              prefixIcon: Icon(Icons.menu_book_outlined),
                              hintText: 'Orn: 5',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed:
                              todayQuranPages > 0 ? _onRemoveQuranPages : null,
                          icon: const Icon(Icons.remove_rounded),
                          tooltip: 'Sayfa çıkar',
                          style: IconButton.styleFrom(
                            foregroundColor:
                                AppColors.quranEmerald.withValues(alpha: 0.92),
                            backgroundColor:
                                AppColors.quranEmerald.withValues(alpha: 0.16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PressAnimatedQuranAddButton(
                          onPressed: () {
                            _onAddQuranPages();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.points,
    required this.progress,
    required this.pointsToNextLevel,
  });

  final int level;
  final int points;
  final double progress;
  final int pointsToNextLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seviye $level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Motivasyon Puanı: $points',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sonraki seviye için $pointsToNextLevel puan kaldı',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.title,
    required this.total,
    required this.canUndo,
    required this.color,
    required this.onCardTap,
    required this.onUndo,
    required this.onTap,
  });

  final String title;
  final int total;
  final bool canUndo;
  final Color color;
  final VoidCallback onCardTap;
  final VoidCallback onUndo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeTextColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? const Color(0xFF111827)
            : Colors.white;

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onCardTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 9,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$total',
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kılınan Toplam Kaza:',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: canUndo ? onUndo : null,
                icon: const Icon(Icons.undo_rounded),
                tooltip: 'Geri al',
                style: IconButton.styleFrom(
                  foregroundColor: color.withValues(alpha: 0.88),
                  backgroundColor: color.withValues(alpha: 0.13),
                ),
              ),
              const SizedBox(width: 8),
              _PressAnimatedPrayerButton(
                color: color,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressAnimatedPrayerButton extends StatefulWidget {
  const _PressAnimatedPrayerButton(
      {required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  State<_PressAnimatedPrayerButton> createState() =>
      _PressAnimatedPrayerButtonState();
}

class _PressAnimatedPrayerButtonState
    extends State<_PressAnimatedPrayerButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: FilledButton.tonalIcon(
          onPressed: widget.onPressed,
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Kıldım'),
          style: FilledButton.styleFrom(
            foregroundColor: widget.color.withValues(alpha: 0.96),
            backgroundColor: widget.color.withValues(alpha: 0.16),
            overlayColor: widget.color.withValues(alpha: 0.32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _PressAnimatedQuranAddButton extends StatefulWidget {
  const _PressAnimatedQuranAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PressAnimatedQuranAddButton> createState() =>
      _PressAnimatedQuranAddButtonState();
}

class _PressAnimatedQuranAddButtonState
    extends State<_PressAnimatedQuranAddButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.quranEmerald,
            overlayColor: AppColors.quranEmerald.withValues(alpha: 0.32),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Ekle'),
        ),
      ),
    );
  }
}
