import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/kaza_logs_provider.dart';
import '../../providers/quran_logs_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../src/features/dhikr/data/models/dhikr_type_model.dart';
import '../../src/features/dhikr/presentation/providers/dhikr_logs_provider.dart';
import '../../src/features/dhikr/presentation/providers/dhikr_types_provider.dart';
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
  final _dateFormat = DateFormat('d MMMM y', 'tr_TR');

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return _dateOnly(a) == _dateOnly(b);
  }

  String _selectedDateLabel(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final selected = _dateOnly(date);

    if (_isSameDay(selected, today)) {
      return 'Bugün';
    }

    if (_isSameDay(selected, today.subtract(const Duration(days: 1)))) {
      return 'Dün';
    }

    return _dateFormat.format(selected);
  }

  String _snackbarDateLabel(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final selected = _dateOnly(date);

    if (_isSameDay(selected, today)) {
      return 'bugün';
    }

    if (_isSameDay(selected, today.subtract(const Duration(days: 1)))) {
      return 'dün';
    }

    return _dateFormat.format(selected);
  }

  void _setSelectedDate(DateTime date) {
    ref.read(selectedDateProvider.notifier).state = _dateOnly(date);
  }

  String _quranHeading(DateTime selectedDate) {
    final today = _dateOnly(DateTime.now());
    final selected = _dateOnly(selectedDate);

    if (_isSameDay(selected, today)) {
      return "Bugün kaç sayfa Kur'an okudun?";
    }

    if (_isSameDay(selected, today.subtract(const Duration(days: 1)))) {
      return "Dün kaç sayfa Kur'an okudun?";
    }

    return '${_dateFormat.format(selected)} tarihinde kaç sayfa okudun?';
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
    final selectedDate = ref.read(selectedDateProvider);
    final result = await ref
        .read(kazaLogsProvider.notifier)
        .addKaza(prayerTime: prayerTime, count: 1, date: selectedDate);

    if (!mounted) {
      return;
    }

    final prayerLabel = _prayerLabel(prayerTime);
    final dateLabel = _snackbarDateLabel(selectedDate);
    final baseMessage = _isSameDay(selectedDate, DateTime.now())
        ? '1 $prayerLabel kazası eklendi'
        : '1 $prayerLabel kazası geçmişe ($dateLabel) eklendi';
    final message = result.levelUp
        ? '$baseMessage. Seviye ${result.newLevel} oldun.'
        : baseMessage;

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
    final selectedDate = ref.read(selectedDateProvider);

    if (pages == null || pages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir sayfa sayısı gir.')),
      );
      return;
    }

    await ref
        .read(quranLogsProvider.notifier)
        .addTodayPages(pages, date: selectedDate);
    _quranPagesController.clear();

    if (mounted) {
      final dateLabel = _snackbarDateLabel(selectedDate);
      final message = _isSameDay(selectedDate, DateTime.now())
          ? '$pages sayfa eklendi 📖'
          : '$pages sayfa $dateLabel tarihine eklendi 📖';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  Future<void> _onUndoKaza(PrayerTime prayerTime) async {
    final selectedDate = ref.read(selectedDateProvider);
    final removed = await ref
        .read(kazaLogsProvider.notifier)
        .undoTodayKaza(prayerTime: prayerTime, date: selectedDate);

    if (!mounted) {
      return;
    }

    if (removed <= 0) {
      final dateLabel = _selectedDateLabel(selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dateLabel için geri alınacak kaza yok.'),
          duration: const Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    final dateLabel = _snackbarDateLabel(selectedDate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSameDay(selectedDate, DateTime.now())
              ? '$removed ${_prayerLabel(prayerTime)} kazası geri alındı ↩️'
              : '$removed ${_prayerLabel(prayerTime)} kazası $dateLabel tarihinden geri alındı ↩️',
        ),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _onRemoveQuranPages() async {
    final rawInput = _quranPagesController.text.trim();
    final pages = rawInput.isEmpty ? 1 : int.tryParse(rawInput);
    final selectedDate = ref.read(selectedDateProvider);

    if (pages == null || pages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir sayfa sayısı gir.'),
          duration: Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    final removed = await ref
        .read(quranLogsProvider.notifier)
        .removeTodayPages(pages, date: selectedDate);
    _quranPagesController.clear();

    if (!mounted) {
      return;
    }

    if (removed <= 0) {
      final dateLabel = _selectedDateLabel(selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dateLabel için çıkarılacak sayfa yok.'),
          duration: const Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    final dateLabel = _snackbarDateLabel(selectedDate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSameDay(selectedDate, DateTime.now())
              ? '$removed sayfa çıkarıldı ↩️'
              : '$removed sayfa $dateLabel tarihinden çıkarıldı ↩️',
        ),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _showAddDhikrDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddDhikrDialog(),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zikir kaydedildi.')),
      );
    }
  }

  Future<void> _onAddDhikrCount(DhikrTypeModel dhikr, int count) async {
    final selectedDate = ref.read(selectedDateProvider);
    final result = await ref.read(dhikrTypesProvider.notifier).addDhikrCount(
          dhikr: dhikr,
          count: count,
          date: selectedDate,
        );

    if (!mounted) {
      return;
    }

    final dateLabel = _snackbarDateLabel(selectedDate);
    final baseMessage = _isSameDay(selectedDate, DateTime.now())
        ? '$count ${dhikr.name} zikri eklendi'
        : '$count ${dhikr.name} zikri $dateLabel tarihine eklendi';
    final bonusMessage = result.bonusAwarded
        ? ' Hedefe ulaşıldı, +20 bonus puan kazanıldı.'
        : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$baseMessage$bonusMessage'),
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
    final dhikrTypesAsync = ref.watch(dhikrTypesProvider);
    final dhikrLogsAsync = ref.watch(dhikrLogsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final today = _dateOnly(DateTime.now());
    final selectedDay = _dateOnly(selectedDate);
    final canGoForward = !_isSameDay(selectedDay, today);

    return profileAsync.when(
      data: (data) {
        if (data == null) {
          return const Center(
            child: Text('Profil bulunamadi. Onboarding adimini tamamlayin.'),
          );
        }

        final profile = data.profile;
        final selectedDateLabel = _selectedDateLabel(selectedDate);

        final selectedKazaByPrayer = <PrayerTime, int>{
          for (final prayer in PrayerTime.values) prayer: 0,
        };

        final kazaLogs = kazaLogsAsync.valueOrNull ?? const [];
        for (final log in kazaLogs) {
          if (!_isSameDay(log.date, selectedDate)) {
            continue;
          }
          selectedKazaByPrayer[log.prayerTime] =
              (selectedKazaByPrayer[log.prayerTime] ?? 0) + log.count;
        }

        final quranLogs = quranLogsAsync.valueOrNull ?? const [];
        final selectedQuranPages = quranLogs
            .where((log) => _isSameDay(log.date, selectedDate))
            .fold<int>(0, (sum, log) => sum + log.pages);

        final dhikrTypes =
            dhikrTypesAsync.valueOrNull ?? const <DhikrTypeModel>[];
        final dhikrLogs = dhikrLogsAsync.valueOrNull ?? const [];
        final selectedDhikrCountById = <int, int>{};
        for (final log in dhikrLogs) {
          selectedDhikrCountById[log.dhikrId] =
              (selectedDhikrCountById[log.dhikrId] ?? 0) + log.completedCount;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _DateNavigatorBar(
              label: selectedDateLabel,
              onPrevious: () => _setSelectedDate(
                selectedDay.subtract(const Duration(days: 1)),
              ),
              onNext: canGoForward
                  ? () => _setSelectedDate(
                        selectedDay.add(const Duration(days: 1)),
                      )
                  : null,
              onPickDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDay,
                  firstDate: DateTime(2000),
                  lastDate: today,
                  locale: const Locale('tr', 'TR'),
                  builder: (context, child) {
                    final theme = Theme.of(context);
                    return Theme(
                      data: theme.copyWith(
                        datePickerTheme: theme.datePickerTheme.copyWith(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );

                if (picked != null) {
                  _setSelectedDate(picked);
                }
              },
            ),
            const SizedBox(height: 16),
            _LevelCard(
              level: profile.level,
              points: profile.motivationPoints,
              progress: data.levelProgress,
              pointsToNextLevel: data.pointsToNextLevel,
            ),
            const SizedBox(height: 16),
            const Text(
              'Seçili Günün Toplam Kaza Sayıları',
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
                  canUndo: (selectedKazaByPrayer[time] ?? 0) > 0,
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
                    Text(
                      _quranHeading(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Seçili gün toplamı: $selectedQuranPages sayfa',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          onPressed: selectedQuranPages > 0
                              ? _onRemoveQuranPages
                              : null,
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
                            onPressed: _onAddQuranPages),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Günlük Zikirlerim',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddDhikrDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Yeni Zikir Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (dhikrTypesAsync.isLoading && dhikrTypes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dhikrTypes.isEmpty)
              const _DhikrEmptyState()
            else
              ListView.builder(
                itemCount: dhikrTypes.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final dhikr = dhikrTypes[index];
                  final currentCount = dhikr.id == null
                      ? 0
                      : (selectedDhikrCountById[dhikr.id!] ?? 0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DhikrCard(
                      name: dhikr.name,
                      targetCount: dhikr.targetCount,
                      currentCount: currentCount,
                      onAddOne: dhikr.id == null
                          ? null
                          : () => _onAddDhikrCount(dhikr, 1),
                      onAddThirtyThree: dhikr.id == null
                          ? null
                          : () => _onAddDhikrCount(dhikr, 33),
                    ),
                  );
                },
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }
}

class _DateNavigatorBar extends StatelessWidget {
  const _DateNavigatorBar({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Önceki gün',
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Sonraki gün',
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDhikrDialog extends ConsumerStatefulWidget {
  const _AddDhikrDialog();

  @override
  ConsumerState<_AddDhikrDialog> createState() => _AddDhikrDialogState();
}

class _AddDhikrDialogState extends ConsumerState<_AddDhikrDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController(text: '99');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(dhikrTypesProvider.notifier).addDhikrType(
            name: _nameController.text.trim(),
            targetCount: int.parse(_targetController.text.trim()),
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Zikir Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Zikir Adı',
                  hintText: 'La ilahe illallah',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Zikir adını gir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hedef Sayı',
                  hintText: '99',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Pozitif bir sayı gir';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Kaydet'),
        ),
      ],
    );
  }
}

class _DhikrEmptyState extends StatelessWidget {
  const _DhikrEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'Henüz zikir eklenmedi. "Yeni Zikir Ekle" ile kendi listenizi oluşturun.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.name,
    required this.targetCount,
    required this.currentCount,
    required this.onAddOne,
    required this.onAddThirtyThree,
  });

  final String name;
  final int targetCount;
  final int currentCount;
  final VoidCallback? onAddOne;
  final VoidCallback? onAddThirtyThree;

  @override
  Widget build(BuildContext context) {
    final progress = targetCount <= 0
        ? 0.0
        : (currentCount / targetCount).clamp(0, 1).toDouble();

    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '$currentCount/$targetCount',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onAddOne,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('+1'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddThirtyThree,
                    icon: const Icon(Icons.exposure_plus_1_rounded),
                    label: const Text('+33'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
