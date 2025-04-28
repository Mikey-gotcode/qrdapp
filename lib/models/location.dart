class LocationModel {
  final int? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  final int? merchantId;

  const LocationModel({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.merchantId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      merchantId: json['merchantId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'merchantId': merchantId,
    };
  }

  @override
  String toString() {
    return 'LocationModel{id: $id, name: $name, latitude: $latitude, longitude: $longitude, merchantId: $merchantId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          merchantId == other.merchantId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      merchantId.hashCode;
}
