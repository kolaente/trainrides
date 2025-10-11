// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_lounge_visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbLoungeVisit _$DbLoungeVisitFromJson(Map<String, dynamic> json) =>
    DbLoungeVisit(
      id: (json['id'] as num?)?.toInt(),
      dbLoungeId: (json['db_lounge_id'] as num).toInt(),
      userId: json['user_id'] as String?,
      visitedAt: DateTime.parse(json['visited_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DbLoungeVisitToJson(DbLoungeVisit instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'db_lounge_id': instance.dbLoungeId,
      'user_id': instance.userId,
      'visited_at': instance.visitedAt.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };
