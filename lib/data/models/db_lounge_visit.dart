import 'package:json_annotation/json_annotation.dart';

part 'db_lounge_visit.g.dart';

@JsonSerializable()
class DbLoungeVisit {
  @JsonKey(includeIfNull: false)
  final int? id;
  @JsonKey(name: 'db_lounge_id')
  final int dbLoungeId;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'visited_at')
  final DateTime visitedAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const DbLoungeVisit({
    this.id,
    required this.dbLoungeId,
    this.userId,
    required this.visitedAt,
    this.createdAt,
  });

  factory DbLoungeVisit.fromJson(Map<String, dynamic> json) =>
      _$DbLoungeVisitFromJson(json);
  Map<String, dynamic> toJson() => _$DbLoungeVisitToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DbLoungeVisit &&
        other.id == id &&
        other.dbLoungeId == dbLoungeId &&
        other.userId == userId &&
        other.visitedAt == visitedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, dbLoungeId, userId, visitedAt, createdAt);
  }

  @override
  String toString() {
    return 'DbLoungeVisit(id: $id, dbLoungeId: $dbLoungeId, userId: $userId, visitedAt: $visitedAt, createdAt: $createdAt)';
  }

  String get displayDate => visitedAt.toIso8601String().split('T').first;
}
