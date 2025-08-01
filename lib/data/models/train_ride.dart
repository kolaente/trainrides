import 'package:json_annotation/json_annotation.dart';

part 'train_ride.g.dart';

@JsonSerializable()
class TrainRide {
  @JsonKey(includeIfNull: false)
  final int? id;
  @JsonKey(name: 'from')
  final String from;
  @JsonKey(name: 'to')
  final String to;
  final double price;
  @JsonKey(name: 'type_id')
  final int? typeId;
  final DateTime date;
  final String? details;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'user_id')
  final String? userId;

  const TrainRide({
    this.id,
    required this.from,
    required this.to,
    required this.price,
    this.typeId,
    required this.date,
    this.details,
    required this.createdAt,
    this.userId,
  });

  factory TrainRide.fromJson(Map<String, dynamic> json) =>
      _$TrainRideFromJson(json);
  Map<String, dynamic> toJson() => _$TrainRideToJson(this);

  TrainRide copyWith({
    int? id,
    String? from,
    String? to,
    double? price,
    int? typeId,
    DateTime? date,
    String? details,
    DateTime? createdAt,
    String? userId,
  }) {
    return TrainRide(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      price: price ?? this.price,
      typeId: typeId ?? this.typeId,
      date: date ?? this.date,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainRide &&
        other.id == id &&
        other.from == from &&
        other.to == to &&
        other.price == price &&
        other.typeId == typeId &&
        other.date == date &&
        other.details == details &&
        other.createdAt == createdAt &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      from,
      to,
      price,
      typeId,
      date,
      details,
      createdAt,
      userId,
    );
  }

  @override
  String toString() {
    return 'TrainRide(id: $id, from: $from, to: $to, price: $price, typeId: $typeId, date: $date, details: $details, createdAt: $createdAt, userId: $userId)';
  }

  String get displayTitle => '$from → $to';
  String get displayDate => date.toIso8601String().split('T').first;
  String get displayPrice => '${price.toStringAsFixed(2)} €';
  String get displayDateTime =>
      '${date.toIso8601String().split('T').first} $displayTitle';
}

enum TrainType {
  ice('ICE'),
  ic('IC'),
  re('RE'),
  rb('RB'),
  sbahn('S-Bahn'),
  tram('Tram'),
  bus('Bus'),
  other('Other');

  const TrainType(this.displayName);
  final String displayName;

  static TrainType fromString(String value) {
    return TrainType.values.firstWhere(
      (type) => type.name == value.toLowerCase() || type.displayName == value,
      orElse: () => TrainType.other,
    );
  }
}
