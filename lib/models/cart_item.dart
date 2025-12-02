class CartItem {
  final String cartId;
  final String productId;
  final String productName;
  final String? description;
  final String? categoryName;
  final List<String> images;
  final String? productImage;
  final List<String> colors;
  final List<String> sizes;
  final int quantity;
  final double price;
  final double? discountPrice;
  final double finalPrice;
  final double subtotal;
  final int stock;
  final bool isAvailable;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.productName,
    this.description,
    this.categoryName,
    required this.images,
    this.productImage,
    required this.colors,
    required this.sizes,
    required this.quantity,
    required this.price,
    this.discountPrice,
    required this.finalPrice,
    required this.subtotal,
    required this.stock,
    required this.isAvailable,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Parse images
    List<String> images = [];
    if (json['images'] is List) {
      images = List<String>.from(json['images']);
    } else if (json['product_image'] != null) {
      images = [json['product_image']];
    }

    // Parse colors and sizes
    List<String> colors = [];
    if (json['colors'] is List) {
      colors = List<String>.from(json['colors']);
    }

    List<String> sizes = [];
    if (json['sizes'] is List) {
      sizes = List<String>.from(json['sizes']);
    }

    return CartItem(
      cartId: json['cart_id']?.toString() ?? json['cart_item_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      description: json['description'],
      categoryName: json['category_name'],
      images: images,
      productImage: json['product_image'],
      colors: colors,
      sizes: sizes,
      quantity: (json['quantity'] ?? 1).toInt(),
      price: (json['price'] ?? 0.0).toDouble(),
      discountPrice: json['discount_price'] != null ? (json['discount_price']).toDouble() : null,
      finalPrice: (json['final_price'] ?? json['price'] ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      stock: (json['stock'] ?? 0).toInt(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'product_name': productName,
      'description': description,
      'category_name': categoryName,
      'images': images,
      'product_image': productImage,
      'colors': colors,
      'sizes': sizes,
      'quantity': quantity,
      'price': price,
      'discount_price': discountPrice,
      'final_price': finalPrice,
      'subtotal': subtotal,
      'stock': stock,
      'is_available': isAvailable,
    };
  }

  CartItem copyWith({
    String? cartId,
    String? productId,
    String? productName,
    String? description,
    String? categoryName,
    List<String>? images,
    String? productImage,
    List<String>? colors,
    List<String>? sizes,
    int? quantity,
    double? price,
    double? discountPrice,
    double? finalPrice,
    double? subtotal,
    int? stock,
    bool? isAvailable,
  }) {
    return CartItem(
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      productImage: productImage ?? this.productImage,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      subtotal: subtotal ?? this.subtotal,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class CartSummary {
  final int totalItems;
  final int itemsCount;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final double freeShippingThreshold;
  final double amountForFreeShipping;

  CartSummary({
    required this.totalItems,
    required this.itemsCount,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.freeShippingThreshold,
    required this.amountForFreeShipping,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalItems: (json['total_items'] ?? 0).toInt(),
      itemsCount: (json['items_count'] ?? 0).toInt(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      shipping: (json['shipping'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      freeShippingThreshold: (json['free_shipping_threshold'] ?? 500.0).toDouble(),
      amountForFreeShipping: (json['amount_for_free_shipping'] ?? 0.0).toDouble(),
    );
  }
}