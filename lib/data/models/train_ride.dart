import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/api_constants.dart';

part 'train_ride.g.dart';

@JsonSerializable()
class TrainRide {
  final int? id;
  final String from;
  final String to;
  final double price;
  final String type;
  final DateTime date;
  final String? details;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainRide({
    this.id,
    required this.from,
    required this.to,
    required this.price,
    required this.type,
    required this.date,
    this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainRide.fromJson(Map<String, dynamic> json) => _$TrainRideFromJson(json);
  Map<String, dynamic> toJson() => _$TrainRideToJson(this);

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    if (value is Map<String, dynamic>) {
      final stringValue = value['value']?.toString();
      if (stringValue != null) {
        final parsed = double.tryParse(stringValue);
        return parsed ?? 0.0;
      }
    }
    return 0.0;
  }

  static String _parseStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['value']?.toString() ?? '';
    }
    return value.toString();
  }

  factory TrainRide.fromBaserowJson(Map<String, dynamic> json) {
    final dateString = _parseStringValue(json[ApiConstants.fieldMapping['date']!]);
    final detailsString = _parseStringValue(json[ApiConstants.fieldMapping['details']!]);
    
    return TrainRide(
      id: json['id'],
      from: _parseStringValue(json[ApiConstants.fieldMapping['from']!]),
      to: _parseStringValue(json[ApiConstants.fieldMapping['to']!]),
      price: _parsePrice(json[ApiConstants.fieldMapping['price']!]),
      type: _parseStringValue(json[ApiConstants.fieldMapping['type']!]),
      date: DateTime.parse(dateString.isNotEmpty ? dateString : DateTime.now().toIso8601String()),
      details: detailsString.isNotEmpty ? detailsString : null,
      createdAt: DateTime.parse(json['created_on'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_on'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toBaserowJson() {
    return {
      ApiConstants.fieldMapping['from']!: from,
      ApiConstants.fieldMapping['to']!: to,
      ApiConstants.fieldMapping['price']!: price,
      ApiConstants.fieldMapping['type']!: type,
      ApiConstants.fieldMapping['date']!: date.toIso8601String().split('T').first,
      if (details != null) ApiConstants.fieldMapping['details']!: details,
    };
  }

  TrainRide copyWith({
    int? id,
    String? from,
    String? to,
    double? price,
    String? type,
    DateTime? date,
    String? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainRide(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      price: price ?? this.price,
      type: type ?? this.type,
      date: date ?? this.date,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        other.type == type &&
        other.date == date &&
        other.details == details &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      from,
      to,
      price,
      type,
      date,
      details,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'TrainRide(id: $id, from: $from, to: $to, price: $price, type: $type, date: $date, details: $details, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  String get displayTitle => '$from → $to';
  String get displayDate => date.toIso8601String().split('T').first;
  String get displayPrice => '€${price.toStringAsFixed(2)}';
  String get displayDateTime => '${date.toIso8601String().split('T').first} $displayTitle';
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