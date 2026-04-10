// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Campaign _$CampaignFromJson(Map<String, dynamic> json) => _Campaign(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => EventNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      category: json['category'] as String,
      targetType: json['targetType'] as String,
      recipientCount: (json['recipientCount'] as num).toInt(),
      status: $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']) ??
          CampaignStatus.sent,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sentByUserId: json['sentByUserId'] as String?,
      actionUrl: json['actionUrl'] as String?,
      targetDescription: json['targetDescription'] as String?,
    );

Map<String, dynamic> _$CampaignToJson(_Campaign instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'notes': instance.notes.map((e) => e.toJson()).toList(),
      'category': instance.category,
      'targetType': instance.targetType,
      'recipientCount': instance.recipientCount,
      'status': _$CampaignStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'sentByUserId': instance.sentByUserId,
      'actionUrl': instance.actionUrl,
      'targetDescription': instance.targetDescription,
    };

const _$CampaignStatusEnumMap = {
  CampaignStatus.draft: 'draft',
  CampaignStatus.sent: 'sent',
};
