// core/extensions/hyrox_station_localization.dart
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/l10n/app_localizations.dart';

extension HyroxStationLocalization on HyroxStation {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case HyroxStation.run1:
        return l10n.eventRun1;
      case HyroxStation.skiErg:
        return l10n.eventSkiErg;
      case HyroxStation.run2:
        return l10n.eventRun2;
      case HyroxStation.sledPush:
        return l10n.eventSledPush;
      case HyroxStation.run3:
        return l10n.eventRun3;
      case HyroxStation.sledPull:
        return l10n.eventSledPull;
      case HyroxStation.run4:
        return l10n.eventRun4;
      case HyroxStation.burpeeBroadJump:
        return l10n.eventBurpeeBroadJump;
      case HyroxStation.run5:
        return l10n.eventRun5;
      case HyroxStation.rowing:
        return l10n.eventRowing;
      case HyroxStation.run6:
        return l10n.eventRun6;
      case HyroxStation.farmersCarry:
        return l10n.eventFarmersCarry;
      case HyroxStation.run7:
        return l10n.eventRun7;
      case HyroxStation.sandbagLunges:
        return l10n.eventSandbagLunges;
      case HyroxStation.run8:
        return l10n.eventRun8;
      case HyroxStation.wallBalls:
        return l10n.eventWallBalls;
    }
  }
}
