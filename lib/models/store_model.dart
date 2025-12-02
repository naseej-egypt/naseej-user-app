class Store {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final List<String> openingHours;
  final List<String> workingDays;
  final double distance;
  final Map<String, dynamic>? manager;
  final int? deliveryMenCount;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isOpen = true,
    required this.openingHours,
    this.workingDays = const [],
    this.distance = 0.0,
    this.manager,
    this.deliveryMenCount,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    // Handle location data
    final location = json['location'] ?? {};

    // Enhanced image URL handling
    String? imageUrl = _parseImageUrl(json['image_url']);

    // Handle opening hours
    List<String> openingHours = _parseOpeningHours(json);

    // Handle working days
    List<String> workingDays = [];
    if (json['working_days'] is List) {
      workingDays = List<String>.from(json['working_days']);
    }

    // Calculate if store is currently open (FIXED LOGIC)
    bool isOpen = _calculateIsOpen(openingHours, workingDays);

    return Store(
      id: (json['id'] ?? json['store_id'] ?? '').toString(),
      name: json['store_name'] ?? json['name'] ?? 'Unknown Store',
      description: json['description'] ?? 'Store located in ${json['address'] ?? ''}',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      latitude: (location['latitude'] ?? json['latitude'] ?? 0.0).toDouble(),
      longitude: (location['longitude'] ?? json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      imageUrl: imageUrl,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: (json['review_count'] ?? json['reviewCount'] ?? 0).toInt(),
      isOpen: isOpen,
      openingHours: openingHours,
      workingDays: workingDays,
      distance: (json['distance'] ?? 0.0).toDouble(),
      manager: json['manager'] is Map ? Map<String, dynamic>.from(json['manager']) : null,
      deliveryMenCount: json['delivery_men_count'] ?? json['deliveryMenCount'],
    );
  }

  static String? _parseImageUrl(dynamic imageUrlData) {
    if (imageUrlData == null ||
        imageUrlData.toString().isEmpty ||
        imageUrlData.toString() == 'null') {
      return null;
    }

    String url = imageUrlData.toString();

    // Ensure the URL is properly formatted
    if (url.startsWith('http')) {
      return url;
    } else {
      if (url.startsWith('/')) {
        return 'https://appforyou.store$url';
      } else {
        return 'https://appforyou.store/backendnaseej/upload/stores/$url';
      }
    }
  }

  static List<String> _parseOpeningHours(Map<String, dynamic> json) {
    List<String> openingHours = [];

    if (json['opening_hours'] is List) {
      openingHours = List<String>.from(json['opening_hours']);
    } else if (json['hours'] is Map) {
      final hours = json['hours'];
      if (hours['opening_time'] != null && hours['closing_time'] != null) {
        openingHours = ['${hours['opening_time']} - ${hours['closing_time']}'];
      }
    }

    if (openingHours.isEmpty) {
      openingHours = ['09:00 - 18:00'];
    }

    return openingHours;
  }

  // FIXED: Proper 24-hour system logic for open/closed status
  static bool _calculateIsOpen(List<String> openingHours, List<String> workingDays) {
    if (openingHours.isEmpty || workingDays.isEmpty) {
      return false;
    }

    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);

    // Check if today is a working day
    if (!workingDays.contains(currentDay)) {
      return false;
    }

    // Parse opening hours (format: "09:00 - 22:00")
    if (openingHours.isNotEmpty) {
      final hours = openingHours.first.split(' - ');
      if (hours.length == 2) {
        try {
          // Parse opening and closing times
          final openingParts = hours[0].trim().split(':');
          final closingParts = hours[1].trim().split(':');

          final openingHour = int.parse(openingParts[0]);
          final openingMinute = int.parse(openingParts[1]);
          final closingHour = int.parse(closingParts[0]);
          final closingMinute = int.parse(closingParts[1]);

          // Create DateTime objects for comparison
          final openingTime = DateTime(now.year, now.month, now.day, openingHour, openingMinute);
          final closingTime = DateTime(now.year, now.month, now.day, closingHour, closingMinute);

          // Handle case where closing time is after midnight (e.g., 09:00 - 03:00)
          final effectiveClosingTime = closingTime.isBefore(openingTime)
              ? closingTime.add(Duration(days: 1))
              : closingTime;

          // Check if current time is within opening hours
          final isWithinHours = now.isAfter(openingTime) && now.isBefore(effectiveClosingTime);

          return isWithinHours;
        } catch (e) {
          print('Error parsing opening hours: $e');
          return false;
        }
      }
    }

    return false;
  }

  String get fullAddress => '$address, $city';

  bool get isCurrentlyOpen {
    return _calculateIsOpen(openingHours, workingDays);
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'workingDays': workingDays,
      'distance': distance,
      'manager': manager,
      'deliveryMenCount': deliveryMenCount,
    };
  }
}