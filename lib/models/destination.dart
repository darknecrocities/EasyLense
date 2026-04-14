import 'package:cloud_firestore/cloud_firestore.dart';

class Destination {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final int? estimatedMinutes;
  final DateTime? timestamp;

  Destination({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.estimatedMinutes,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  factory Destination.fromMap(String id, Map<String, dynamic> map) {
    return Destination(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Destination copyWith({
    double? distanceKm,
    int? estimatedMinutes,
  }) {
    return Destination(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      timestamp: timestamp,
    );
  }
}
