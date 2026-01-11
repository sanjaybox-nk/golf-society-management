// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Campaign _$CampaignFromJson(Map<String, dynamic> json) => _Campaign(
  id: json['id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  category: json['category'] as String,
  targetType: json['targetType'] as String,
  recipientCount: (json['recipientCount'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  sentByUserId: json['sentByUserId'] as String?,
  actionUrl: json['actionUrl'] as String?,
  targetDescription: json['targetDescription'] as String?,
);

Map<String, dynamic> _$CampaignToJson(_Campaign instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'message': instance.message,
  'category': instance.category,
  'targetType': instance.targetType,
  'recipientCount': instance.recipientCount,
  'timestamp': instance.timestamp.toIso8601String(),
  'sentByUserId': instance.sentByUserId,
  'actionUrl': instance.actionUrl,
  'targetDescription': instance.targetDescription,
};
