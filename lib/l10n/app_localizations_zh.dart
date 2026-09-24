// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HYROX 訓練追蹤器';

  @override
  String get foundationReady => '基礎架構已完成。';

  @override
  String get placeholderDescription => '核心架構、路由、本地化與儲存啟動已串接完成。';

  @override
  String get currentEventLabel => '目前項目';

  @override
  String get progressLabel => '進度';

  @override
  String get workoutTimeLabel => '訓練時間';

  @override
  String get pauseTimeLabel => '暫停時間';

  @override
  String get pauseCountLabel => '暫停次數';

  @override
  String get restTimeLabel => '休息時間';

  @override
  String get totalEventTimeLabel => '項目總時間';

  @override
  String get sessionTotalsLabel => '訓練總計';

  @override
  String get totalWorkoutLabel => '訓練總時間';

  @override
  String get totalPauseLabel => '暫停總時間';

  @override
  String get totalPauseCountLabel => '暫停總次數';

  @override
  String get totalRestLabel => '休息總時間';

  @override
  String get totalSessionLabel => '全程總時間';

  @override
  String get completedEventsLabel => '已完成項目';

  @override
  String get sessionCompletedTitle => '訓練完成';

  @override
  String get voiceWorkoutComplete => '訓練完成';

  @override
  String get voicePauseStarted => '已暫停';

  @override
  String get voicePauseEnded => '繼續訓練';

  @override
  String get voiceStartRest => '開始休息';

  @override
  String get voiceRestComplete => '休息完成';

  @override
  String get voiceSessionComplete => '全程完成';

  @override
  String voiceStartEvent(Object eventName) {
    return '開始$eventName';
  }

  @override
  String get startWorkoutButton => '開始訓練';

  @override
  String get pauseButton => '暫停';

  @override
  String get resumeButton => '繼續';

  @override
  String get completeWorkoutButton => '完成訓練';

  @override
  String get startRestButton => '開始休息';

  @override
  String get completeRestButton => '完成休息';

  @override
  String get autoTransitionSettingsTitle => '自動轉場';

  @override
  String get autoTransitionEnabledLabel => '啟用自動轉場';

  @override
  String get transitionDelayLabel => '轉場延遲';

  @override
  String get defaultRestDurationLabel => '預設休息時間';

  @override
  String get secondsLabel => '秒';

  @override
  String get autoTransitionPendingLabel => '下一個自動動作';

  @override
  String get autoTransitionActionStartRest => '開始休息';

  @override
  String get autoTransitionActionStartNextWorkout => '開始下一個項目';

  @override
  String get recoveryPromptTitle => '要繼續先前訓練嗎？';

  @override
  String get recoveryPromptMessage => '偵測到尚未完成的訓練紀錄。你可以繼續，或捨棄並開始新訓練。';

  @override
  String get recoveryResumeButton => '繼續';

  @override
  String get recoveryDiscardButton => '捨棄';

  @override
  String get viewStatisticsTooltip => '查看統計';

  @override
  String get statisticsTitle => '統計與分析';

  @override
  String get statisticsUnavailableTitle => '尚無統計資料';

  @override
  String get statisticsUnavailableMessage => '完成一次訓練後即可查看統計分析。';

  @override
  String get eventHighlightsTitle => '項目重點';

  @override
  String get runAnalysisTitle => '跑步分析';

  @override
  String get fastestEventLabel => '最快項目';

  @override
  String get slowestEventLabel => '最慢項目';

  @override
  String get mostInterruptedEventLabel => '最常中斷項目';

  @override
  String get longestPauseEventLabel => '最長暫停項目';

  @override
  String get fastestRunLabel => '最快跑步';

  @override
  String get slowestRunLabel => '最慢跑步';

  @override
  String get averageRunTimeLabel => '平均跑步時間';

  @override
  String get fatigueIndexLabel => '疲勞指數';

  @override
  String get fatigueIndexFormulaLabel => '後 4 項平均 - 前 4 項平均';

  @override
  String get averagePauseTimeLabel => '平均暫停時間';

  @override
  String get averageRestTimeLabel => '平均休息時間';

  @override
  String get workoutDurationChartTitle => '各項目訓練時間';

  @override
  String get pauseDurationChartTitle => '各項目暫停時間';

  @override
  String get restDurationChartTitle => '各項目休息時間';

  @override
  String get cumulativeTimeChartTitle => '各項目累積時間';

  @override
  String get notificationChannelName => '訓練追蹤';

  @override
  String get notificationChannelDescription => '提供進行中 HYROX 訓練的背景追蹤與控制通知。';

  @override
  String get eventRun1 => '跑步 1';

  @override
  String get eventSkiErg => '滑雪機';

  @override
  String get eventRun2 => '跑步 2';

  @override
  String get eventSledPush => '推雪橇';

  @override
  String get eventRun3 => '跑步 3';

  @override
  String get eventSledPull => '拉雪橇';

  @override
  String get eventRun4 => '跑步 4';

  @override
  String get eventBurpeeBroadJump => '波比跳遠';

  @override
  String get eventRun5 => '跑步 5';

  @override
  String get eventRowing => '划船機';

  @override
  String get eventRun6 => '跑步 6';

  @override
  String get eventFarmersCarry => '農夫走';

  @override
  String get eventRun7 => '跑步 7';

  @override
  String get eventSandbagLunges => '沙袋弓步';

  @override
  String get eventRun8 => '跑步 8';

  @override
  String get eventWallBalls => '牆球';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'HYROX 訓練追蹤器';

  @override
  String get foundationReady => '基礎架構已完成。';

  @override
  String get placeholderDescription => '核心架構、路由、本地化與儲存啟動已串接完成。';

  @override
  String get currentEventLabel => '目前項目';

  @override
  String get progressLabel => '進度';

  @override
  String get workoutTimeLabel => '訓練時間';

  @override
  String get pauseTimeLabel => '暫停時間';

  @override
  String get pauseCountLabel => '暫停次數';

  @override
  String get restTimeLabel => '休息時間';

  @override
  String get totalEventTimeLabel => '項目總時間';

  @override
  String get sessionTotalsLabel => '訓練總計';

  @override
  String get totalWorkoutLabel => '訓練總時間';

  @override
  String get totalPauseLabel => '暫停總時間';

  @override
  String get totalPauseCountLabel => '暫停總次數';

  @override
  String get totalRestLabel => '休息總時間';

  @override
  String get totalSessionLabel => '全程總時間';

  @override
  String get completedEventsLabel => '已完成項目';

  @override
  String get sessionCompletedTitle => '訓練完成';

  @override
  String get voiceWorkoutComplete => '訓練完成';

  @override
  String get voicePauseStarted => '已暫停';

  @override
  String get voicePauseEnded => '繼續訓練';

  @override
  String get voiceStartRest => '開始休息';

  @override
  String get voiceRestComplete => '休息完成';

  @override
  String get voiceSessionComplete => '全程完成';

  @override
  String voiceStartEvent(Object eventName) {
    return '開始$eventName';
  }

  @override
  String get startWorkoutButton => '開始訓練';

  @override
  String get pauseButton => '暫停';

  @override
  String get resumeButton => '繼續';

  @override
  String get completeWorkoutButton => '完成訓練';

  @override
  String get startRestButton => '開始休息';

  @override
  String get completeRestButton => '完成休息';

  @override
  String get autoTransitionSettingsTitle => '自動轉場';

  @override
  String get autoTransitionEnabledLabel => '啟用自動轉場';

  @override
  String get transitionDelayLabel => '轉場延遲';

  @override
  String get defaultRestDurationLabel => '預設休息時間';

  @override
  String get secondsLabel => '秒';

  @override
  String get autoTransitionPendingLabel => '下一個自動動作';

  @override
  String get autoTransitionActionStartRest => '開始休息';

  @override
  String get autoTransitionActionStartNextWorkout => '開始下一個項目';

  @override
  String get recoveryPromptTitle => '要繼續先前訓練嗎？';

  @override
  String get recoveryPromptMessage => '偵測到尚未完成的訓練紀錄。你可以繼續，或捨棄並開始新訓練。';

  @override
  String get recoveryResumeButton => '繼續';

  @override
  String get recoveryDiscardButton => '捨棄';

  @override
  String get viewStatisticsTooltip => '查看統計';

  @override
  String get statisticsTitle => '統計與分析';

  @override
  String get statisticsUnavailableTitle => '尚無統計資料';

  @override
  String get statisticsUnavailableMessage => '完成一次訓練後即可查看統計分析。';

  @override
  String get eventHighlightsTitle => '項目重點';

  @override
  String get runAnalysisTitle => '跑步分析';

  @override
  String get fastestEventLabel => '最快項目';

  @override
  String get slowestEventLabel => '最慢項目';

  @override
  String get mostInterruptedEventLabel => '最常中斷項目';

  @override
  String get longestPauseEventLabel => '最長暫停項目';

  @override
  String get fastestRunLabel => '最快跑步';

  @override
  String get slowestRunLabel => '最慢跑步';

  @override
  String get averageRunTimeLabel => '平均跑步時間';

  @override
  String get fatigueIndexLabel => '疲勞指數';

  @override
  String get fatigueIndexFormulaLabel => '後 4 項平均 - 前 4 項平均';

  @override
  String get averagePauseTimeLabel => '平均暫停時間';

  @override
  String get averageRestTimeLabel => '平均休息時間';

  @override
  String get workoutDurationChartTitle => '各項目訓練時間';

  @override
  String get pauseDurationChartTitle => '各項目暫停時間';

  @override
  String get restDurationChartTitle => '各項目休息時間';

  @override
  String get cumulativeTimeChartTitle => '各項目累積時間';

  @override
  String get notificationChannelName => '訓練追蹤';

  @override
  String get notificationChannelDescription => '提供進行中 HYROX 訓練的背景追蹤與控制通知。';

  @override
  String get eventRun1 => '跑步 1';

  @override
  String get eventSkiErg => '滑雪機';

  @override
  String get eventRun2 => '跑步 2';

  @override
  String get eventSledPush => '推雪橇';

  @override
  String get eventRun3 => '跑步 3';

  @override
  String get eventSledPull => '拉雪橇';

  @override
  String get eventRun4 => '跑步 4';

  @override
  String get eventBurpeeBroadJump => '波比跳遠';

  @override
  String get eventRun5 => '跑步 5';

  @override
  String get eventRowing => '划船機';

  @override
  String get eventRun6 => '跑步 6';

  @override
  String get eventFarmersCarry => '農夫走';

  @override
  String get eventRun7 => '跑步 7';

  @override
  String get eventSandbagLunges => '沙袋弓步';

  @override
  String get eventRun8 => '跑步 8';

  @override
  String get eventWallBalls => '牆球';
}
