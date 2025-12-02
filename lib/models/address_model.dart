class AddressModel {
  final String id;
  final String customerId;
  final String label;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  bool isDefault;
  final String? createdAt;
  final String? updatedAt;

  AddressModel({
    required this.id,
    required this.customerId,
    required this.label,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'label': label,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      label: json['label'] ?? 'Home',
      streetAddress: json['streetAddress'] ?? json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? json['zip_code'] ?? '',
      country: json['country'] ?? 'Egypt',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDefault: json['isDefault'] == true || json['is_default'] == 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper method to convert to API request format
  Map<String, dynamic> toApiRequest() {
    return {
      'street': streetAddress,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'label': label, // Add label to API request
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'is_default': isDefault ? '1' : '0',
    };
  }
}