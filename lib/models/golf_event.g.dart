// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'golf_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventNote _$EventNoteFromJson(Map<String, dynamic> json) => _EventNote(
  title: json['title'] as String?,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$EventNoteToJson(_EventNote instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
    };

_GolfEvent _$GolfEventFromJson(Map<String, dynamic> json) => _GolfEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  seasonId: json['seasonId'] as String,
  date: const TimestampConverter().fromJson(json['date'] as Object),
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  regTime: const OptionalTimestampConverter().fromJson(json['regTime']),
  teeOffTime: const OptionalTimestampConverter().fromJson(json['teeOffTime']),
  registrationDeadline: const OptionalTimestampConverter().fromJson(
    json['registrationDeadline'],
  ),
  registrations:
      (json['registrations'] as List<dynamic>?)
          ?.map((e) => EventRegistration.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  courseName: json['courseName'] as String?,
  courseDetails: json['courseDetails'] as String?,
  dressCode: json['dressCode'] as String?,
  availableBuggies: (json['availableBuggies'] as num?)?.toInt(),
  maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
  facilities:
      (json['facilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  memberCost: (json['memberCost'] as num?)?.toDouble(),
  guestCost: (json['guestCost'] as num?)?.toDouble(),
  breakfastCost: (json['breakfastCost'] as num?)?.toDouble(),
  lunchCost: (json['lunchCost'] as num?)?.toDouble(),
  dinnerCost: (json['dinnerCost'] as num?)?.toDouble(),
  buggyCost: (json['buggyCost'] as num?)?.toDouble(),
  hasBreakfast: json['hasBreakfast'] as bool? ?? false,
  hasLunch: json['hasLunch'] as bool? ?? false,
  hasDinner: json['hasDinner'] as bool? ?? true,
  dinnerLocation: json['dinnerLocation'] as String?,
  notes:
      (json['notes'] as List<dynamic>?)
          ?.map((e) => EventNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  galleryUrls:
      (json['galleryUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  showRegistrationButton: json['showRegistrationButton'] as bool? ?? true,
  teeOffInterval: (json['teeOffInterval'] as num?)?.toInt() ?? 10,
  isGroupingPublished: json['isGroupingPublished'] as bool? ?? false,
  isMultiDay: json['isMultiDay'] as bool?,
  endDate: const OptionalTimestampConverter().fromJson(json['endDate']),
  grouping: json['grouping'] as Map<String, dynamic>? ?? const {},
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  courseId: json['courseId'] as String?,
  courseConfig: json['courseConfig'] as Map<String, dynamic>? ?? const {},
  selectedTeeName: json['selectedTeeName'] as String?,
  flashUpdates:
      (json['flashUpdates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  scoringForceActive: json['scoringForceActive'] as bool? ?? false,
  isScoringLocked: json['isScoringLocked'] as bool? ?? false,
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.draft,
);

Map<String, dynamic> _$GolfEventToJson(
  _GolfEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'seasonId': instance.seasonId,
  'date': const TimestampConverter().toJson(instance.date),
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'regTime': const OptionalTimestampConverter().toJson(instance.regTime),
  'teeOffTime': const OptionalTimestampConverter().toJson(instance.teeOffTime),
  'registrationDeadline': const OptionalTimestampConverter().toJson(
    instance.registrationDeadline,
  ),
  'registrations': instance.registrations.map((e) => e.toJson()).toList(),
  'courseName': instance.courseName,
  'courseDetails': instance.courseDetails,
  'dressCode': instance.dressCode,
  'availableBuggies': instance.availableBuggies,
  'maxParticipants': instance.maxParticipants,
  'facilities': instance.facilities,
  'memberCost': instance.memberCost,
  'guestCost': instance.guestCost,
  'breakfastCost': instance.breakfastCost,
  'lunchCost': instance.lunchCost,
  'dinnerCost': instance.dinnerCost,
  'buggyCost': instance.buggyCost,
  'hasBreakfast': instance.hasBreakfast,
  'hasLunch': instance.hasLunch,
  'hasDinner': instance.hasDinner,
  'dinnerLocation': instance.dinnerLocation,
  'notes': instance.notes.map((e) => e.toJson()).toList(),
  'galleryUrls': instance.galleryUrls,
  'showRegistrationButton': instance.showRegistrationButton,
  'teeOffInterval': instance.teeOffInterval,
  'isGroupingPublished': instance.isGroupingPublished,
  'isMultiDay': instance.isMultiDay,
  'endDate': const OptionalTimestampConverter().toJson(instance.endDate),
  'grouping': instance.grouping,
  'results': instance.results,
  'courseId': instance.courseId,
  'courseConfig': instance.courseConfig,
  'selectedTeeName': instance.selectedTeeName,
  'flashUpdates': instance.flashUpdates,
  'scoringForceActive': instance.scoringForceActive,
  'isScoringLocked': instance.isScoringLocked,
  'status': _$EventStatusEnumMap[instance.status]!,
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.published: 'published',
  EventStatus.completed: 'completed',
  EventStatus.cancelled: 'cancelled',
};
