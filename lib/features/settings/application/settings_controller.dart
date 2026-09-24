// features/settings/application/settings_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/features/settings/data/app_info_repository.dart';
import 'package:hyrox/features/settings/data/settings_repository.dart';
import 'package:hyrox/features/settings/domain/settings_models.dart';

final StateNotifierProvider<SettingsController, SettingsViewState>
settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsViewState>((Ref ref) {
      final SettingsRepository settingsRepository = ref.watch(
        settingsRepositoryProvider,
      );
      final AppInfoRepository appInfoRepository = ref.watch(
        appInfoRepositoryProvider,
      );

      return SettingsController(
        settingsRepository: settingsRepository,
        appInfoRepository: appInfoRepository,
      );
    });

final Provider<Locale?> appLocaleOverrideProvider = Provider<Locale?>((
  Ref ref,
) {
  final SettingsViewState state = ref.watch(settingsControllerProvider);
  return state.selectedLanguage?.locale;
});

class SettingsController extends StateNotifier<SettingsViewState> {
  SettingsController({
    SettingsRepository? settingsRepository,
    AppInfoRepository? appInfoRepository,
  }) : _settingsRepository = settingsRepository ?? InMemorySettingsRepository(),
       _appInfoRepository = appInfoRepository ?? const StubAppInfoRepository(),
       super(SettingsViewState.initial()) {
    unawaited(_load());
  }

  final SettingsRepository _settingsRepository;
  final AppInfoRepository _appInfoRepository;

  AppLanguage effectiveLanguage(Locale locale) {
    if (state.selectedLanguage != null) {
      return state.selectedLanguage!;
    }

    return locale.languageCode.toLowerCase() == 'zh'
        ? AppLanguage.traditionalChinese
        : AppLanguage.english;
  }

  Future<void> selectLanguage(AppLanguage language) async {
    state = state.copyWith(selectedLanguage: language, isSavingLanguage: true);

    try {
      await _settingsRepository.saveSelectedLanguage(language);
    } finally {
      if (mounted) {
        state = state.copyWith(isSavingLanguage: false);
      }
    }
  }

  Future<void> _load() async {
    try {
      final AppLanguage? selectedLanguage = await _settingsRepository
          .loadSelectedLanguage();
      final AppInfoSnapshot appInfo = await _appInfoRepository.load();

      if (!mounted) {
        return;
      }

      state = state.copyWith(
        selectedLanguage: selectedLanguage,
        appInfo: appInfo,
        isLoading: false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      state = state.copyWith(isLoading: false);
    }
  }
}

class SettingsViewState {
  const SettingsViewState({
    required this.selectedLanguage,
    required this.appInfo,
    required this.isLoading,
    required this.isSavingLanguage,
  });

  factory SettingsViewState.initial() {
    return const SettingsViewState(
      selectedLanguage: null,
      appInfo: AppInfoSnapshot.unknown(),
      isLoading: true,
      isSavingLanguage: false,
    );
  }

  final AppLanguage? selectedLanguage;
  final AppInfoSnapshot appInfo;
  final bool isLoading;
  final bool isSavingLanguage;

  SettingsViewState copyWith({
    AppLanguage? selectedLanguage,
    AppInfoSnapshot? appInfo,
    bool? isLoading,
    bool? isSavingLanguage,
  }) {
    return SettingsViewState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      appInfo: appInfo ?? this.appInfo,
      isLoading: isLoading ?? this.isLoading,
      isSavingLanguage: isSavingLanguage ?? this.isSavingLanguage,
    );
  }
}
