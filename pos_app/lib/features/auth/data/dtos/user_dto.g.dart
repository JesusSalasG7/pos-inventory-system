// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  fullName: json['full_name'] as String,
  role: json['role'] as String,
  isActive: json['is_active'] as bool,
  assignedBranch: json['assigned_branch'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'full_name': instance.fullName,
  'role': instance.role,
  'is_active': instance.isActive,
  'assigned_branch': instance.assignedBranch,
};
