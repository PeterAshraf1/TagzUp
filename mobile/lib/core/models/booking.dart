import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String businessProfileId,
    required String influencerProfileId,
    required String packageId,
    required BookingStatus status,
    required double totalAmount,
    required double platformFee,
    required double influencerAmount,
    @Default('EGP') String currency,
    String? brief,
    String? requirements,
    DateTime? deadline,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

@JsonEnum()
enum BookingStatus {
  @JsonValue('pending_payment')
  pendingPayment,
  @JsonValue('paid')
  paid,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('pending_proof')
  pendingProof,
  @JsonValue('pending_verification')
  pendingVerification,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('disputed')
  disputed,
}