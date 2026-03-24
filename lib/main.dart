import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/database_provider.dart';
import 'ui/screens/main_layout.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  runApp(const ProviderScope(child: KazaQuranTakipApp()));
}

class KazaQuranTakipApp extends ConsumerWidget {
  const KazaQuranTakipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaza ve Kuran Takip',
      theme: AppTheme.light,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(isOnboardingRequiredProvider);

    return onboardingAsync.when(
      data: (needsOnboarding) {
        if (needsOnboarding) {
          return const OnboardingScreen();
        }
        return const MainLayout();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Baslangic kontrolunde hata olustu: $error'),
          ),
        ),
      ),
    );
  }
}
