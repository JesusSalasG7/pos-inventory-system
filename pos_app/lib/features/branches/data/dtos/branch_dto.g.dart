// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BranchDto _$BranchDtoFromJson(Map<String, dynamic> json) => _BranchDto(
  code: json['code'] as String,
  name: json['name'] as String,
  active: json['active'] as bool,
);

Map<String, dynamic> _$BranchDtoToJson(_BranchDto instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'active': instance.active,
};
