// features/settings/data/app_info_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/features/settings/domain/settings_models.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class AppInfoRepository {
  Future<AppInfoSnapshot> load();
}

final Provider<AppInfoRepository> appInfoRepositoryProvider =
    Provider<AppInfoRepository>((Ref ref) {
      return const StubAppInfoRepository();
    });

class PackageInfoAppInfoRepository implements AppInfoRepository {
  @override
  Future<AppInfoSnapshot> load() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return AppInfoSnapshot(
      appName: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}

class StubAppInfoRepository implements AppInfoRepository {
  const StubAppInfoRepository();

  @override
  Future<AppInfoSnapshot> load() async {
    return const AppInfoSnapshot(
      appName: 'HYROX Training Tracker',
      version: '1.0.0',
      buildNumber: '1',
    );
  }
}
