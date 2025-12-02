class CarpetProduct {
  String? id;
  String? name;
  String? description;
  String? price;
  String? color;
  String? size;
  String? dimensions;
  String? material;
  String? category;
  String? imageUrl;
  String? userId;
  String? createdAt;
  bool isFavorite;

  CarpetProduct({
    this.id,
    this.name,
    this.description,
    this.price,
    this.color,
    this.size,
    this.dimensions,
    this.material,
    this.category,
    this.imageUrl,
    this.userId,
    this.createdAt,
    this.isFavorite = false,
  });

  // Create from JSON (from database)
  factory CarpetProduct.fromJson(Map<String, dynamic> json) {
    return CarpetProduct(
      id: json['note_id']?.toString(),
      name: json['note_title']?.toString() ?? 'Untitled Carpet',
      description: json['note_content']?.toString() ?? '',
      price: _extractPrice(json['note_content']?.toString()),
      color: _extractColor(json['note_content']?.toString()),
      size: _extractSize(json['note_content']?.toString()),
      dimensions: _extractDimensions(json['note_content']?.toString()),
      material: 'Handwoven Wool', // Default
      category: 'Traditional', // Default
      imageUrl: json['note_image']?.toString(),
      userId: json['user_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      isFavorite: false,
    );
  }

  // Helper methods to extract info from description
  static String _extractPrice(String? content) {
    if (content == null) return '\$299';
    // Look for price patterns like $299, 299$, etc.
    final priceRegex = RegExp(r'\$?\d+\.?\d*');
    final match = priceRegex.firstMatch(content);
    if (match != null) {
      var price = match.group(0);
      return price!.startsWith('\$') ? price : '\$$price';
    }
    return '\$299'; // Default price
  }

  static String _extractColor(String? content) {
    if (content == null) return 'Multi-color';
    final lowerContent = content.toLowerCase();

    final colors = ['red', 'blue', 'green', 'beige', 'brown', 'burgundy', 'gold', 'cream'];
    for (var color in colors) {
      if (lowerContent.contains(color)) {
        return color[0].toUpperCase() + color.substring(1);
      }
    }
    return 'Multi-color';
  }

  static String _extractSize(String? content) {
    if (content == null) return 'Medium';
    final lowerContent = content.toLowerCase();

    if (lowerContent.contains('small')) return 'Small';
    if (lowerContent.contains('large')) return 'Large';
    if (lowerContent.contains('xlarge') || lowerContent.contains('x-large')) return 'X-Large';

    return 'Medium';
  }

  static String _extractDimensions(String? content) {
    if (content == null) return '6x9 ft';

    // Look for dimension patterns like 6x9, 8x10, etc.
    final dimRegex = RegExp(r'\d+\s*[xX×]\s*\d+\s*(ft|feet|m|meter)?');
    final match = dimRegex.firstMatch(content);
    if (match != null) {
      return match.group(0)!;
    }

    return '6x9 ft'; // Default
  }

  // Format price for display
  String get formattedPrice => price ?? '\$299';

  // Get short description
  String get shortDescription {
    if (description == null || description!.isEmpty) return 'Handcrafted carpet';
    return description!.length > 60
        ? '${description!.substring(0, 60)}...'
        : description!;
  }
}