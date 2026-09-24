// features/settings/data/settings_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hyrox/features/settings/domain/settings_models.dart';

abstract class SettingsRepository {
  Future<AppLanguage?> loadSelectedLanguage();

  Future<void> saveSelectedLanguage(AppLanguage language);
}

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
      return InMemorySettingsRepository();
    });

class InMemorySettingsRepository implements SettingsRepository {
  AppLanguage? _selectedLanguage;

  @override
  Future<AppLanguage?> loadSelectedLanguage() async {
    return _selectedLanguage;
  }

  @override
  Future<void> saveSelectedLanguage(AppLanguage language) async {
    _selectedLanguage = language;
  }
}

class HiveSettingsRepository implements SettingsRepository {
  static const String _boxName = 'app_settings_box';
  static const String _selectedLanguageKey = 'selectedLanguage';

  @override
  Future<AppLanguage?> loadSelectedLanguage() async {
    final Box<dynamic> box = await _openBox();
    final String? storedValue = box.get(_selectedLanguageKey) as String?;
    return AppLanguageCodec.fromStorage(storedValue);
  }

  @override
  Future<void> saveSelectedLanguage(AppLanguage language) async {
    final Box<dynamic> box = await _openBox();
    await box.put(_selectedLanguageKey, language.storageValue);
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }

    return Hive.openBox<dynamic>(_boxName);
  }
}
