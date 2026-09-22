// features/session/domain/hyrox_events.dart
import 'package:flutter/foundation.dart';

enum HyroxStation {
  run1,
  skiErg,
  run2,
  sledPush,
  run3,
  sledPull,
  run4,
  burpeeBroadJump,
  run5,
  rowing,
  run6,
  farmersCarry,
  run7,
  sandbagLunges,
  run8,
  wallBalls,
}

@immutable
class HyroxEventDefinition {
  const HyroxEventDefinition({required this.order, required this.station});

  final int order;
  final HyroxStation station;
}

const List<HyroxEventDefinition> hyroxEventDefinitions = <HyroxEventDefinition>[
  HyroxEventDefinition(order: 1, station: HyroxStation.run1),
  HyroxEventDefinition(order: 2, station: HyroxStation.skiErg),
  HyroxEventDefinition(order: 3, station: HyroxStation.run2),
  HyroxEventDefinition(order: 4, station: HyroxStation.sledPush),
  HyroxEventDefinition(order: 5, station: HyroxStation.run3),
  HyroxEventDefinition(order: 6, station: HyroxStation.sledPull),
  HyroxEventDefinition(order: 7, station: HyroxStation.run4),
  HyroxEventDefinition(order: 8, station: HyroxStation.burpeeBroadJump),
  HyroxEventDefinition(order: 9, station: HyroxStation.run5),
  HyroxEventDefinition(order: 10, station: HyroxStation.rowing),
  HyroxEventDefinition(order: 11, station: HyroxStation.run6),
  HyroxEventDefinition(order: 12, station: HyroxStation.farmersCarry),
  HyroxEventDefinition(order: 13, station: HyroxStation.run7),
  HyroxEventDefinition(order: 14, station: HyroxStation.sandbagLunges),
  HyroxEventDefinition(order: 15, station: HyroxStation.run8),
  HyroxEventDefinition(order: 16, station: HyroxStation.wallBalls),
];
