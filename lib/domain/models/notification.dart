import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();
  
  const factory AppNotification({
    required String id,
    required String title,
    required String message,
    required DateTime timestamp,
    @Default('Info') String category,
    @Default(false) bool isRead,
    String? actionUrl,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => 
      _$AppNotificationFromJson(json);
}
