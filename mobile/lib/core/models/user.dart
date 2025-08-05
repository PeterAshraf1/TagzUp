import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? phone,
    required UserType userType,
    required UserStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonEnum()
enum UserType {
  @JsonValue('influencer')
  influencer,
  @JsonValue('business')
  business,
  @JsonValue('admin')
  admin,
}

@JsonEnum()
enum UserStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('suspended')
  suspended,
}