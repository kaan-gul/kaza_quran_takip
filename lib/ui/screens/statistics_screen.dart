import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/statistics_provider.dart';
import '../../src/features/kaza/domain/entities/prayer_time.dart';
import '../theme/app_colors.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatisticsPeriod _period = StatisticsPeriod.weekly;

  String _label(PrayerTime prayerTime) {
    return switch (prayerTime) {
      PrayerTime.sabah => 'Sabah',
      PrayerTime.ogle => 'Ogle',
      PrayerTime.ikindi => 'Ikindi',
      PrayerTime.aksam => 'Aksam',
      PrayerTime.yatsi => 'Yatsi',
      PrayerTime.vitir => 'Vitir',
    };
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider(_period));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: statsAsync.when(
        data: (stats) {
          return ListView(
            children: [
              _PeriodSelector(
                period: _period,
                onChanged: (value) => setState(() => _period = value),
              ),
              const SizedBox(height: 12),
              _DebtSummaryCard(totalRemaining: stats.totalRemaining),
              const SizedBox(height: 12),
              _DebtTableCard(stats: stats, labelBuilder: _label),
              const SizedBox(height: 12),
              _ChartCard(
                period: _period,
                chartTotals: stats.chartTotals,
                labelBuilder: _label,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.period, required this.onChanged});

  final StatisticsPeriod period;
  final ValueChanged<StatisticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatisticsPeriod>(
      segments: const <ButtonSegment<StatisticsPeriod>>[
        ButtonSegment<StatisticsPeriod>(
          value: StatisticsPeriod.weekly,
          label: Text('Son 7 Gun'),
          icon: Icon(Icons.date_range_rounded),
        ),
        ButtonSegment<StatisticsPeriod>(
          value: StatisticsPeriod.monthly,
          label: Text('Bu Ay'),
          icon: Icon(Icons.calendar_month_rounded),
        ),
      ],
      selected: <StatisticsPeriod>{period},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard({required this.totalRemaining});

  final int totalRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFFEE2E2),
            child: Icon(Icons.flag_rounded, color: Color(0xFFB91C1C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kalan Toplam Kaza Borcu',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalRemaining adet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtTableCard extends StatelessWidget {
  const _DebtTableCard({required this.stats, required this.labelBuilder});

  final StatisticsData stats;
  final String Function(PrayerTime) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Vakit',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Baslangic',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Kilinan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Kalan',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...stats.debts.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labelBuilder(item.prayerTime),
                        style: TextStyle(
                          color: AppColors.prayerColor(item.prayerTime),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item.initial}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item.completed}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item.remaining}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.period,
    required this.chartTotals,
    required this.labelBuilder,
  });

  final StatisticsPeriod period;
  final Map<PrayerTime, int> chartTotals;
  final String Function(PrayerTime) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final maxY = math
        .max(
          5,
          chartTotals.values.fold<int>(0, (maxValue, value) {
                if (value > maxValue) {
                  return value;
                }
                return maxValue;
              }) +
              2,
        )
        .toDouble();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              period == StatisticsPeriod.weekly
                  ? 'Son 7 Gunde Kilinan Kaza Dagilimi'
                  : 'Bu Ay Kilinan Kaza Dagilimi',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: true),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= PrayerTime.values.length) {
                            return const SizedBox.shrink();
                          }
                          final prayer = PrayerTime.values[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labelBuilder(prayer),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: PrayerTime.values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final prayer = entry.value;
                    final y = (chartTotals[prayer] ?? 0).toDouble();

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: y,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.prayerColor(prayer),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
