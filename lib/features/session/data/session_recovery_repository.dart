// features/session/data/session_recovery_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';

abstract class SessionRecoveryRepository {
  Future<void> save(SessionRecoveryPayload payload);

  Future<SessionRecoveryPayload?> load();

  Future<void> clear();
}

final Provider<SessionRecoveryRepository> sessionRecoveryRepositoryProvider =
    Provider<SessionRecoveryRepository>((Ref ref) {
      return InMemorySessionRecoveryRepository();
    });

class InMemorySessionRecoveryRepository implements SessionRecoveryRepository {
  SessionRecoveryPayload? _payload;

  @override
  Future<void> clear() async {
    _payload = null;
  }

  @override
  Future<SessionRecoveryPayload?> load() async {
    return _payload;
  }

  @override
  Future<void> save(SessionRecoveryPayload payload) async {
    _payload = payload;
  }
}

class HiveSessionRecoveryRepository implements SessionRecoveryRepository {
  static const String _boxName = 'session_recovery_box';
  static const String _activeSessionKey = 'active_session';

  @override
  Future<void> clear() async {
    final Box<dynamic> box = await _openBox();
    await box.delete(_activeSessionKey);
  }

  @override
  Future<SessionRecoveryPayload?> load() async {
    final Box<dynamic> box = await _openBox();
    final Object? raw = box.get(_activeSessionKey);

    if (raw == null) {
      return null;
    }

    if (raw is! Map) {
      await clear();
      return null;
    }

    try {
      final Map<String, dynamic> payloadMap = raw.map(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );

      return SessionRecoveryPayload.fromJson(payloadMap);
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(SessionRecoveryPayload payload) async {
    final Box<dynamic> box = await _openBox();
    await box.put(_activeSessionKey, payload.toJson());
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }

    return Hive.openBox<dynamic>(_boxName);
  }
}
