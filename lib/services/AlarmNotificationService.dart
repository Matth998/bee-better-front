import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmNotificationService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Alarm.init(showDebugLogs: true);
    _initialized = true;
  }

  static Future<void> scheduleAlarm({
    required int id,
    required int hour,
    required int minute,
    required String label,
    required String ringtone,
    required bool active,
  }) async {
    if (!active) {
      await cancelAlarm(id);
      return;
    }

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute, 0);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      assetAudioPath: 'assets/audio/$ringtone.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: '⏰ $label',
        body: 'Toque para dispensar',
        stopButton: 'Dispensar',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('Alarme $id agendado para $scheduledTime');
  }

  static Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
    debugPrint('Alarme $id cancelado');
  }

  static Future<void> cancelAll() async {
    await Alarm.stopAll();
  }
}