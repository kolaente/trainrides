import 'package:json_annotation/json_annotation.dart';

part 'db_lounge.g.dart';

@JsonSerializable()
class DbLounge {
  @JsonKey(includeIfNull: false)
  final int? id;
  final String location;
  final String anchor;

  const DbLounge({this.id, required this.location, required this.anchor});

  factory DbLounge.fromJson(Map<String, dynamic> json) =>
      _$DbLoungeFromJson(json);
  Map<String, dynamic> toJson() => _$DbLoungeToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DbLounge &&
        other.id == id &&
        other.location == location &&
        other.anchor == anchor;
  }

  @override
  int get hashCode {
    return Object.hash(id, location, anchor);
  }

  @override
  String toString() {
    return 'DbLounge(id: $id, location: $location, anchor: $anchor)';
  }

  String get displayName => location;
}
