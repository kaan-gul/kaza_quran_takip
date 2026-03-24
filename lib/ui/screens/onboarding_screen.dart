import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _sabahController = TextEditingController();
  final _ogleController = TextEditingController();
  final _ikindiController = TextEditingController();
  final _aksamController = TextEditingController();
  final _yatsiController = TextEditingController();
  final _vitirController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _sabahController.dispose();
    _ogleController.dispose();
    _ikindiController.dispose();
    _aksamController.dispose();
    _yatsiController.dispose();
    _vitirController.dispose();
    super.dispose();
  }

  int _parseValue(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return 0;
    }
    return parsed;
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      await ref.read(userProfileProvider.notifier).saveInitialProfile(
            sabah: _parseValue(_sabahController.text),
            ogle: _parseValue(_ogleController.text),
            ikindi: _parseValue(_ikindiController.text),
            aksam: _parseValue(_aksamController.text),
            yatsi: _parseValue(_yatsiController.text),
            vitir: _parseValue(_vitirController.text),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Baslangic profili kaydedildi.')), 
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayit sirasinda bir hata olustu.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = <({String title, TextEditingController controller})>[
      (title: 'Sabah', controller: _sabahController),
      (title: 'Ogle', controller: _ogleController),
      (title: 'Ikindi', controller: _ikindiController),
      (title: 'Aksam', controller: _aksamController),
      (title: 'Yatsi', controller: _yatsiController),
      (title: 'Vitir', controller: _vitirController),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Hos geldin',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gecmis kaza namazi borclarini gir. Bu bilgi sadece takip icin kullanilir.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gecmis Kaza Namazi Borclari',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...fields.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: item.controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${item.title} borcu (adet)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Lutfen 0 veya pozitif bir sayi gir';
                        }
                        return null;
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch_rounded),
                    label: const Text('Kaydet ve Basla'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
