import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'ui/screens/splash_screen.dart';
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
      home: const SplashScreen(),
    );
  }
}
