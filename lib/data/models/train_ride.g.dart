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
  type: json['type'] as String,
  date: DateTime.parse(json['date'] as String),
  details: json['details'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TrainRideToJson(TrainRide instance) => <String, dynamic>{
  'id': instance.id,
  'from': instance.from,
  'to': instance.to,
  'price': instance.price,
  'type': instance.type,
  'date': instance.date.toIso8601String(),
  'details': instance.details,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
