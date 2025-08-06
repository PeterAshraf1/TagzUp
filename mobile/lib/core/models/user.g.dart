// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      userType: $enumDecode(_$UserTypeEnumMap, json['user_type']),
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'user_type': _$UserTypeEnumMap[instance.userType]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserTypeEnumMap = {
  UserType.influencer: 'influencer',
  UserType.business: 'business',
  UserType.admin: 'admin',
};

const _$UserStatusEnumMap = {
  UserStatus.pending: 'pending',
  UserStatus.active: 'active',
  UserStatus.suspended: 'suspended',
};