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

  factory TrainRide.fromJson(Map<String, dynamic> json) =>
      _$TrainRideFromJson(json);
  Map<String, dynamic> toJson() => _$TrainRideToJson(this);

  static double _parsePrice(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    double rawResult = 0.0;

    if (value is num) {
      rawResult = value.toDouble();
    } else if (value is String) {
      final parsed = double.tryParse(value);
      rawResult = parsed ?? 0.0;
    } else if (value is Map<String, dynamic>) {
      final stringValue = value['value']?.toString();
      if (stringValue != null) {
        final parsed = double.tryParse(stringValue);
        rawResult = parsed ?? 0.0;
      }
    } else {
      return 0.0;
    }

    // Fix for Baserow field configuration issue: if price is suspiciously high and ends in 00,
    // it might be multiplied by 100 (e.g., 42 becomes 4200)
    // Only apply this fix if the price is abnormally high (>= 1000) and is a round number
    if (rawResult >= 1000 && rawResult % 100 == 0) {
      final correctedResult = rawResult / 100;
      return correctedResult;
    }

    return rawResult;
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
    final dateString = _parseStringValue(
      json[ApiConstants.fieldMapping['date']!],
    );
    final detailsString = _parseStringValue(
      json[ApiConstants.fieldMapping['details']!],
    );

    final parsedPrice = _parsePrice(json[ApiConstants.fieldMapping['price']!]);

    return TrainRide(
      id: json['id'],
      from: _parseStringValue(json[ApiConstants.fieldMapping['from']!]),
      to: _parseStringValue(json[ApiConstants.fieldMapping['to']!]),
      price: parsedPrice,
      type: _parseStringValue(json[ApiConstants.fieldMapping['type']!]),
      date: DateTime.parse(
        dateString.isNotEmpty ? dateString : DateTime.now().toIso8601String(),
      ),
      details: detailsString.isNotEmpty ? detailsString : null,
      createdAt: DateTime.parse(
        json['created_on'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_on'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory TrainRide.fromBaserowUserFieldJson(Map<String, dynamic> json) {
    final dateString = _parseStringValue(json['date']);
    final detailsString = _parseStringValue(json['details']);

    final parsedPrice = _parsePrice(json['price']);

    return TrainRide(
      id: json['id'],
      from: _parseStringValue(json['from']),
      to: _parseStringValue(json['to']),
      price: parsedPrice,
      type: _parseStringValue(json['type']),
      date: DateTime.parse(
        dateString.isNotEmpty ? dateString : DateTime.now().toIso8601String(),
      ),
      details: detailsString.isNotEmpty ? detailsString : null,
      createdAt: DateTime.parse(
        json['created_on'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_on'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toBaserowJson() {
    final result = {
      ApiConstants.fieldMapping['from']!: from,
      ApiConstants.fieldMapping['to']!: to,
      ApiConstants.fieldMapping['price']!: price,
      ApiConstants.fieldMapping['type']!: type,
      ApiConstants.fieldMapping['date']!: date
          .toIso8601String()
          .split('T')
          .first,
      if (details != null) ApiConstants.fieldMapping['details']!: details,
    };

    return result;
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
