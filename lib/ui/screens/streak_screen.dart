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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seriler'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.mosque_rounded), text: 'Namaz Serisi'),
              Tab(icon: Icon(Icons.menu_book_rounded), text: 'Kuran Serisi'),
            ],
          ),
        ),
        body: streakAsync.when(
          data: (data) {
            return TabBarView(
              children: [
                _NamazSeriesTab(data: data),
                _QuranSeriesTab(data: data),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Hata: $error')),
        ),
      ),
    );
  }
}

class _NamazSeriesTab extends StatelessWidget {
  const _NamazSeriesTab({required this.data});

  final StreakData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricsWrap(
            items: [
              _MetricItem(
                label: 'Mevcut Seri',
                value: '${data.kazaCurrentStreak} Gün',
                icon: Icons.local_fire_department_rounded,
              ),
              _MetricItem(
                label: 'En Uzun Seri',
                value: '${data.kazaLongestStreak} Gün',
                icon: Icons.emoji_events_rounded,
              ),
              _MetricItem(
                label: 'Toplam Kaza (60 Gün)',
                value: '${data.totalKazaInRange}',
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionCardTitle(title: 'Son 60 Günlük Kaza Haritası'),
          const SizedBox(height: 8),
          _KazaHeatGrid(days: data.days),
          const SizedBox(height: 12),
          const _KazaLegend(),
        ],
      ),
    );
  }
}

class _QuranSeriesTab extends StatelessWidget {
  const _QuranSeriesTab({required this.data});

  final StreakData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricsWrap(
            items: [
              _MetricItem(
                label: 'Mevcut Seri',
                value: '${data.quranCurrentStreak} Gün',
                icon: Icons.local_fire_department_rounded,
              ),
              _MetricItem(
                label: 'En Uzun Seri',
                value: '${data.quranLongestStreak} Gün',
                icon: Icons.emoji_events_rounded,
              ),
              _MetricItem(
                label: 'Toplam Sayfa (60 Gün)',
                value: '${data.totalQuranPagesInRange}',
                icon: Icons.auto_stories_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionCardTitle(title: 'Son 60 Günlük Kuran Haritası'),
          const SizedBox(height: 8),
          _QuranHeatGrid(days: data.days),
          const SizedBox(height: 12),
          const _QuranLegend(),
        ],
      ),
    );
  }
}

class _SectionCardTitle extends StatelessWidget {
  const _SectionCardTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _MetricsWrap extends StatelessWidget {
  const _MetricsWrap({required this.items});

  final List<_MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 180,
              child: Card.filled(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        item.value,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KazaLegend extends StatelessWidget {
  const _KazaLegend();

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _LegendChip(color: Color(0xFFCFD8DC), label: '0 Kaza'),
                _LegendChip(color: Color(0x4D2196F3), label: '1-2 Kaza'),
                _LegendChip(color: Color(0x992196F3), label: '3-4 Kaza'),
                _LegendChip(color: Color(0xD92196F3), label: '5-6 Kaza'),
                _LegendChip(color: Color(0xFF2196F3), label: '7+ Kaza'),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Mavi tonunun koyuluğu, o gün kılınan toplam kaza sayısına göre artar.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranLegend extends StatelessWidget {
  const _QuranLegend();

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _LegendChip(color: Color(0x664BAF8A), label: '1-5 Sf'),
            _LegendChip(color: Color(0xB34BAF8A), label: '6-10 Sf'),
            _LegendChip(color: Color(0xFF4BAF8A), label: '20+ Sf'),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _KazaHeatGrid extends StatelessWidget {
  const _KazaHeatGrid({required this.days});

  final List<StreakDayData> days;

  @override
  Widget build(BuildContext context) {
    final hasAnyData = days.any((day) => day.hasKaza);
    if (!hasAnyData) {
      return const _GridCard(
        child: _EmptyStreakState(
          icon: Icons.auto_graph_rounded,
          text: 'Henüz bir kayıt yok. Hadi Bismillah deyip ilk adımını at!',
        ),
      );
    }

    return _GridCard(
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: days.map((day) {
          return _KazaDayCell(day: day, prayerLabelBuilder: _prayerLabel);
        }).toList(),
      ),
    );
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
}

class _QuranHeatGrid extends StatelessWidget {
  const _QuranHeatGrid({required this.days});

  final List<StreakDayData> days;

  @override
  Widget build(BuildContext context) {
    final hasAnyData = days.any((day) => day.hasQuran);
    if (!hasAnyData) {
      return const _GridCard(
        child: _EmptyStreakState(
          icon: Icons.menu_book_rounded,
          text: 'Henüz bir kayıt yok. Hadi Bismillah deyip ilk adımını at!',
        ),
      );
    }

    return _GridCard(
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: days.map((day) {
          final color = _quranColor(day.quranPages);
          return Tooltip(
            message: _tooltip(day),
            child: Container(
              width: 17,
              height: 17,
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
    return Card.outlined(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _EmptyStreakState extends StatelessWidget {
  const _EmptyStreakState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KazaDayCell extends StatelessWidget {
  const _KazaDayCell({required this.day, required this.prayerLabelBuilder});

  final StreakDayData day;
  final String Function(PrayerTime) prayerLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDayDetailDialog(context),
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: _kazaColor(context, day.totalKazaCount),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Color _kazaColor(BuildContext context, int total) {
    if (total <= 0) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    final baseBlue = Theme.of(context).colorScheme.primary;
    if (total <= 2) {
      return baseBlue.withValues(alpha: 0.30);
    }
    if (total <= 4) {
      return baseBlue.withValues(alpha: 0.60);
    }
    if (total <= 6) {
      return baseBlue.withValues(alpha: 0.85);
    }
    return baseBlue.withValues(alpha: 1.0);
  }

  Future<void> _showDayDetailDialog(BuildContext context) async {
    final date =
        '${day.date.day.toString().padLeft(2, '0')}.${day.date.month.toString().padLeft(2, '0')}.${day.date.year}';
    final details = day.nonZeroKazaDetails;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(date),
          content: details.isEmpty
              ? const Text('Kayıt yok')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: PrayerTime.values
                      .where((prayer) => (details[prayer] ?? 0) > 0)
                      .map(
                        (prayer) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${prayerLabelBuilder(prayer)}: ${details[prayer]}',
                          ),
                        ),
                      )
                      .toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
