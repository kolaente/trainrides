// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_lounge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbLounge _$DbLoungeFromJson(Map<String, dynamic> json) => DbLounge(
  id: (json['id'] as num?)?.toInt(),
  location: json['location'] as String,
  anchor: json['anchor'] as String,
);

Map<String, dynamic> _$DbLoungeToJson(DbLounge instance) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'location': instance.location,
  'anchor': instance.anchor,
};
