// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_ride.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainRide _$TrainRideFromJson(Map<String, dynamic> json) => TrainRide(
  id: (json['id'] as num?)?.toInt(),
  from: json['from'] as String,
  to: json['to'] as String,
  price: (json['price'] as num).toDouble(),
  typeId: (json['type_id'] as num?)?.toInt(),
  date: DateTime.parse(json['date'] as String),
  details: json['details'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  userId: json['user_id'] as String?,
);

Map<String, dynamic> _$TrainRideToJson(TrainRide instance) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'from': instance.from,
  'to': instance.to,
  'price': instance.price,
  'type_id': instance.typeId,
  'date': instance.date.toIso8601String(),
  'details': instance.details,
  'created_at': instance.createdAt.toIso8601String(),
  'user_id': instance.userId,
};
