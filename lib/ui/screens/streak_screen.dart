import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/streak_provider.dart';
import '../../src/features/kaza/domain/entities/prayer_time.dart';
import '../theme/app_colors.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: streakAsync.when(
        data: (data) {
          return ListView(
            children: [
              _StreakHeader(
                title: 'Kaza Namazi Serisi',
                subtitle:
                    'Kutular o gun kilinan vakit sayisina gore dikey seritlere ayrilir.',
                streak: data.kazaCurrentStreak,
                icon: Icons.local_fire_department_rounded,
                badgeColor: const Color(0xFFFEF3C7),
                textColor: const Color(0xFF92400E),
              ),
              const SizedBox(height: 10),
              _KazaHeatGrid(days: data.days),
              const SizedBox(height: 22),
              _StreakHeader(
                title: 'Kuran Okuma Serisi',
                subtitle:
                    'Yesil ton koyulastikca o gun daha fazla sayfa okunmus demektir.',
                streak: data.quranCurrentStreak,
                icon: Icons.menu_book_rounded,
                badgeColor: const Color(0xFFD1FAE5),
                textColor: const Color(0xFF065F46),
              ),
              const SizedBox(height: 10),
              _QuranHeatGrid(days: data.days),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({
    required this.title,
    required this.subtitle,
    required this.streak,
    required this.icon,
    required this.badgeColor,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final int streak;
  final IconData icon;
  final Color badgeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$streak gun',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _KazaHeatGrid extends StatelessWidget {
  const _KazaHeatGrid({required this.days});

  final List<StreakDayData> days;

  @override
  Widget build(BuildContext context) {
    return _GridCard(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: days.map((day) {
          return Tooltip(
            message: _tooltip(day),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: KazaStreakCellPainter(kazaCounts: day.kazaCounts),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tooltip(StreakDayData day) {
    final date =
        '${day.date.day.toString().padLeft(2, '0')}.${day.date.month.toString().padLeft(2, '0')}.${day.date.year}';
    if (!day.hasKaza) {
      return '$date - Kaza yok';
    }

    final lines = <String>[];
    for (final prayer in PrayerTime.values) {
      final count = day.kazaCounts[prayer] ?? 0;
      if (count <= 0) {
        continue;
      }
      lines.add('${_prayerLabel(prayer)}: $count');
    }
    return '$date\n${lines.join(', ')}';
  }

  String _prayerLabel(PrayerTime prayerTime) {
    return switch (prayerTime) {
      PrayerTime.sabah => 'Sabah',
      PrayerTime.ogle => 'Ogle',
      PrayerTime.ikindi => 'Ikindi',
      PrayerTime.aksam => 'Aksam',
      PrayerTime.yatsi => 'Yatsi',
      PrayerTime.vitir => 'Vitir',
    };
  }
}

class _QuranHeatGrid extends StatelessWidget {
  const _QuranHeatGrid({required this.days});

  final List<StreakDayData> days;

  @override
  Widget build(BuildContext context) {
    return _GridCard(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: days.map((day) {
          final color = _quranColor(day.quranPages);
          return Tooltip(
            message: _tooltip(day),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tooltip(StreakDayData day) {
    final date =
        '${day.date.day.toString().padLeft(2, '0')}.${day.date.month.toString().padLeft(2, '0')}.${day.date.year}';
    return '$date - ${day.quranPages} sayfa';
  }

  Color _quranColor(int pages) {
    if (pages <= 0) {
      return const Color(0xFFE5E7EB);
    }
    if (pages <= 5) {
      return AppColors.quranEmerald.withValues(alpha: 0.40);
    }
    if (pages <= 10) {
      return AppColors.quranEmerald.withValues(alpha: 0.70);
    }
    if (pages < 20) {
      return AppColors.quranEmerald.withValues(alpha: 0.85);
    }
    return AppColors.quranEmerald.withValues(alpha: 1.0);
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class KazaStreakCellPainter extends CustomPainter {
  const KazaStreakCellPainter({required this.kazaCounts});

  final Map<PrayerTime, int> kazaCounts;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    canvas.save();
    canvas.clipRRect(rrect);

    final active =
        PrayerTime.values.where((item) => (kazaCounts[item] ?? 0) > 0).toList();

    if (active.isEmpty) {
      final paint = Paint()..color = const Color(0xFFE5E7EB);
      canvas.drawRect(rect, paint);
      canvas.restore();
      return;
    }

    final segmentWidth = size.width / active.length;

    for (var i = 0; i < active.length; i++) {
      final prayer = active[i];
      final count = kazaCounts[prayer] ?? 0;
      final alpha = _alphaByCount(count);
      final color = AppColors.prayerColor(prayer).withValues(alpha: alpha);
      final paint = Paint()..color = color;

      final left = i * segmentWidth;
      final segment = Rect.fromLTWH(left, 0, segmentWidth + 0.1, size.height);
      canvas.drawRect(segment, paint);
    }

    canvas.restore();
  }

  double _alphaByCount(int count) {
    if (count <= 1) {
      return 0.40;
    }
    if (count == 2) {
      return 0.70;
    }
    return 1.0;
  }

  @override
  bool shouldRepaint(covariant KazaStreakCellPainter oldDelegate) {
    return oldDelegate.kazaCounts != kazaCounts;
  }
}
