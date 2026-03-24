import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/kaza_logs_provider.dart';
import '../../providers/quran_logs_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../src/features/kaza/domain/entities/prayer_time.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _quranPagesController = TextEditingController();

  @override
  void dispose() {
    _quranPagesController.dispose();
    super.dispose();
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

  Future<void> _onAddKaza(PrayerTime prayerTime) async {
    final result = await ref
        .read(kazaLogsProvider.notifier)
        .addKaza(prayerTime: prayerTime, count: 1);

    if (!mounted) {
      return;
    }

    final message = result.levelUp
        ? 'Tebrikler! Seviye ${result.newLevel} oldun.'
        : 'Harika, 1 adim daha yaklastin!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onAddQuranPages() async {
    final pages = int.tryParse(_quranPagesController.text.trim()) ?? 0;
    if (pages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lutfen gecerli bir sayfa sayisi gir.')),
      );
      return;
    }

    await ref.read(quranLogsProvider.notifier).addTodayPages(pages);
    _quranPagesController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$pages sayfa eklendi. Devam!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (data) {
        if (data == null) {
          return const Center(
            child: Text('Profil bulunamadi. Onboarding adimini tamamlayin.'),
          );
        }

        final profile = data.profile;

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
              'Bugune Kadar Kilinan Toplam Kaza Sayilari',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...PrayerTime.values.map((time) {
              final total = data.completedByPrayer[time] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PrayerCard(
                  title: _prayerLabel(time),
                  total: total,
                  color: AppColors.prayerColor(time),
                  onTap: () => _onAddKaza(time),
                ),
              );
            }),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bugun kac sayfa Kuran okudun?',
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
                              hintText: 'Orn: 5',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _onAddQuranPages,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.quranEmerald,
                          ),
                          child: const Text('Ekle'),
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
            'Level $level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Motivasyon Puani: $points',
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
            'Sonraki level icin $pointsToNextLevel puan kaldi',
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
    required this.color,
    required this.onTap,
  });

  final String title;
  final int total;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
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
                  Text('Bugune kadar kilinan toplam: $total'),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onTap,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Kildim'),
              style: FilledButton.styleFrom(
                foregroundColor: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
