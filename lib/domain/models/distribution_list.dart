import 'package:freezed_annotation/freezed_annotation.dart';

part 'distribution_list.freezed.dart';
part 'distribution_list.g.dart';

@freezed
abstract class DistributionList with _$DistributionList {
  const factory DistributionList({
    required String id,
    required String name,
    required List<String> memberIds,
    required DateTime createdAt,
  }) = _DistributionList;

  factory DistributionList.fromJson(Map<String, dynamic> json) => _$DistributionListFromJson(json);
}
