import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/kaza_logs_provider.dart';
import '../../src/features/kaza/data/models/kaza_log_model.dart';

class PrayerHistoryScreen extends ConsumerWidget {
  const PrayerHistoryScreen({
    super.key,
    required this.prayerName,
    required this.prayerColor,
  });

  final String prayerName;
  final Color prayerColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(prayerHistoryProvider(prayerName));

    return Scaffold(
      appBar: AppBar(
        title: Text('$prayerName Geçmişi'),
        backgroundColor: prayerColor.withValues(alpha: 0.14),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Henüz bu vakit için kılınmış kaza kaydı bulunmuyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }

          final grouped = _groupLogsByDate(logs);
          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          final dateFormat = DateFormat('d MMMM y', 'tr_TR');

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final total = grouped[date] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card.filled(
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_month_rounded,
                      color: prayerColor.withValues(alpha: 0.92),
                    ),
                    title: Text(
                      dateFormat.format(date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: prayerColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+$total',
                        style: TextStyle(
                          color: prayerColor.withValues(alpha: 0.96),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, int> _groupLogsByDate(List<KazaLogModel> logs) {
    final grouped = <DateTime, int>{};

    for (final log in logs) {
      final key = DateTime(log.date.year, log.date.month, log.date.day);
      grouped[key] = (grouped[key] ?? 0) + log.count;
    }

    return grouped;
  }
}
