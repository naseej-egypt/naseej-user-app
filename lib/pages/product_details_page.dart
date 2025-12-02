import 'package:flutter/material.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/pages/main_container.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/main.dart';

import '../component/product_card.dart';
import '../core/services/cart_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final String title;
  final String content;
  final String? imageUrl;
  final double? price;
  final double? discountPrice;
  final VoidCallback? onCartUpdated; // Add this

  const ProductDetailsPage({
    Key? key,
    required this.productId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.price,
    this.discountPrice,
    this.onCartUpdated, // Add this
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {

  Crud crud = Crud();
  bool isFavorite = false;
  bool _isAddingToCart = false;
  bool _isLoading = true;

  // Product data from API
  Map<String, dynamic>? productData;
  List<String> productImages = [];
  List<dynamic> relatedProducts = [];

  // Product options
  int selectedQuantity = 1;
  String? selectedSize;
  String? selectedColor;
  int currentImageIndex = 0;

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Available options - now populated from database
  List<String> availableSizes = [];
  List<String> availableColors = [];

  @override
  void initState() {
    super.initState();
    isFavorite = FavoritesManager.isFavorite(widget.productId);

    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch product details from API
    _loadProductDetails();
  }


  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    try {
      var response = await crud.postRequest(AppLink.productDetails, {
        "product_id": widget.productId,
      });

      if (response != null && response["status"] == "success" && response["data"] != null) {
        if (mounted) {
          setState(() {
            productData = response["data"];

            // Update images from API
            if (productData!['images'] != null && productData!['images'] is List) {
              productImages = List<String>.from(productData!['images']);
            } else if (productData!['product_image'] != null) {
              productImages = [productData!['product_image']];
            }

            // Fallback to widget imageUrl if no images from API
            if (productImages.isEmpty && widget.imageUrl != null) {
              productImages = [widget.imageUrl!];
            }

            // ✅ GET REAL SIZES FROM DATABASE
            if (productData!['sizes'] != null && productData!['sizes'] is List) {
              availableSizes = List<String>.from(productData!['sizes']);
            }
            // Fallback to default sizes if none in database
            if (availableSizes.isEmpty) {
              availableSizes = [
                'Small (4x6 ft)',
                'Medium (6x9 ft)',
                'Large (8x10 ft)',
                'X-Large (9x12 ft)'
              ];
            }
            // Set default selected size
            if (availableSizes.isNotEmpty) {
              selectedSize = availableSizes[0];
            }

            // ✅ GET REAL COLORS FROM DATABASE
            if (productData!['colors'] != null && productData!['colors'] is List) {
              availableColors = List<String>.from(productData!['colors']);
            }
            // Fallback to default colors if none in database
            if (availableColors.isEmpty) {
              availableColors = ['Burgundy', 'Gold', 'Brown', 'Cream', 'Multi-color'];
            }
            // Set default selected color
            if (availableColors.isNotEmpty) {
              selectedColor = availableColors[0];
            }

            // Get related products
            if (productData!['related_products'] != null) {
              relatedProducts = productData!['related_products'];
            }

            _isLoading = false;
          });
        }
      } else {
        // If API fails, use widget data
        if (mounted) {
          setState(() {
            if (widget.imageUrl != null) {
              productImages = [widget.imageUrl!];
            }
            // Use default values
            availableSizes = [
              'Small (4x6 ft)',
              'Medium (6x9 ft)',
              'Large (8x10 ft)',
              'X-Large (9x12 ft)'
            ];
            availableColors = ['Burgundy', 'Gold', 'Brown', 'Cream', 'Multi-color'];
            selectedSize = availableSizes[0];
            selectedColor = availableColors[0];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading product details: $e");
      // Fallback to widget data
      if (mounted) {
        setState(() {
          if (widget.imageUrl != null) {
            productImages = [widget.imageUrl!];
          }
          availableSizes = [
            'Small (4x6 ft)',
            'Medium (6x9 ft)',
            'Large (8x10 ft)',
            'X-Large (9x12 ft)'
          ];
          availableColors = ['Burgundy', 'Gold', 'Brown', 'Cream', 'Multi-color'];
          selectedSize = availableSizes[0];
          selectedColor = availableColors[0];
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Helper method to get color from name
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'burgundy':
        return Color(0xFF8b3c3c);
      case 'gold':
        return Color(0xFFd4a574);
      case 'brown':
        return Color(0xFF8b7355);
      case 'cream':
        return Color(0xFFf1e9db);
      case 'multi-color':
      case 'multicolor':
        return Color(0xFFc26b6b);
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'beige':
        return Color(0xFFF5F5DC);
      default:
        return AppColor.primaryColor;
    }
  }

  bool _isTogglingFavorite = false;

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;
    _isTogglingFavorite = true;

    // Animate the heart icon
    _animationController.forward().then((_) => _animationController.reverse());

    // Update UI immediately for instant feedback
    final newState = !isFavorite;
    setState(() {
      isFavorite = newState;
    });

    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(newState ? 'Adding to favorites...' : 'Removing from favorites...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: AppColor.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      // Sync with backend
      bool success = await FavoritesManager.toggleFavorite(widget.productId);

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    newState ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(newState ? 'Added to favorites!' : 'Removed from favorites!'),
                ],
              ),
              duration: Duration(seconds: 2),
              backgroundColor: newState ? AppColor.primaryColor : AppColor.grey,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        // Revert UI if backend failed
        if (mounted) {
          setState(() {
            isFavorite = !newState;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Failed to update favorites. Please try again.'),
                ],
              ),
              backgroundColor: AppColor.warningColor,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert UI on error
      if (mounted) {
        setState(() {
          isFavorite = !newState;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('An error occurred. Please try again.'),
              ],
            ),
            backgroundColor: AppColor.warningColor,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      _isTogglingFavorite = false;
    }
  }

// Replace the existing _addToCart method with this:

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartService = CartService();

      var response = await cartService.addToCart(
        productId: widget.productId,
        quantity: selectedQuantity,
        color: selectedColor,
        size: selectedSize,
      );

      if (response['success'] == true) {
        // CRITICAL: Notify parent about cart update for badge count and cart page refresh
        widget.onCartUpdated?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Added to cart successfully!')),
              ],
            ),
            backgroundColor: AppColor.successColor,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MainContainer(initialIndex: 3),
                  ),
                      (route) => false,
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to add to cart"),
            backgroundColor: AppColor.warningColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding to cart: ${e.toString()}"),
          backgroundColor: AppColor.warningColor,
        ),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  String _getDisplayPrice() {
    if (productData != null) {
      if (productData!['discount_price'] != null && productData!['discount_price'] > 0) {
        return '\$${productData!['discount_price'].toStringAsFixed(2)}';
      } else if (productData!['price'] != null) {
        return '\$${productData!['price'].toStringAsFixed(2)}';
      }
    }

    // Fallback to widget props
    if (widget.discountPrice != null && widget.discountPrice! > 0) {
      return '\$${widget.discountPrice!.toStringAsFixed(2)}';
    } else if (widget.price != null) {
      return '\$${widget.price!.toStringAsFixed(2)}';
    }

    return '\$299';
  }

  String _getOriginalPrice() {
    if (productData != null && productData!['price'] != null) {
      return '\$${productData!['price'].toStringAsFixed(2)}';
    }
    if (widget.price != null) {
      return '\$${widget.price!.toStringAsFixed(2)}';
    }
    return '\$299';
  }

  bool _hasDiscount() {
    if (productData != null) {
      return productData!['discount_price'] != null &&
          productData!['discount_price'] > 0 &&
          productData!['discount_price'] < productData!['price'];
    }
    return widget.discountPrice != null &&
        widget.discountPrice! > 0 &&
        widget.price != null &&
        widget.discountPrice! < widget.price!;
  }

  int? _getDiscountPercentage() {
    if (productData != null && productData!['discount_percentage'] != null) {
      return productData!['discount_percentage'];
    }
    return null;
  }

  bool _isFreeShipping() {
    if (productData != null && productData!['free_shipping_eligible'] != null) {
      return productData!['free_shipping_eligible'];
    }
    return false;
  }

  int _getStock() {
    if (productData != null && productData!['stock'] != null) {
      return productData!['stock'];
    }
    return 10; // Default
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        body: CustomScrollView(
          slivers: [
          // App Bar with Image Gallery
          SliverAppBar(
          expandedHeight: 400,
          floating: false,
          pinned: true,
          backgroundColor: AppColor.primaryColor,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: AppColor.primaryColor),
              ),
              onPressed: () {
                // Pop with result to notify parent that favorites may have changed
                Navigator.of(context).pop(true);
              },
            ),
          actions: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.pink : AppColor.primaryColor,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Image Gallery
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentImageIndex = index;
                    });
                  },
                  itemCount: productImages.isEmpty ? 1 : productImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(index),
                      child: _buildProductImage(
                          productImages.isEmpty ? null : productImages[index]
                      ),
                    );
                  },
                ),

                // Image Indicators
                if (productImages.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        productImages.length,
                            (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentImageIndex == index
                                ? AppColor.goldAccent
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Horizontal Image Gallery
        if (productImages.length > 1)
    SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: productImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 80,
                margin: EdgeInsets.only(
                  left: index == 0 ? 24 : 12,
                  right: index == productImages.length - 1 ? 24 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentImageIndex == index
                        ? AppColor.primaryColor
                        : AppColor.borderGray,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(productImages[index]),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle error
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),

    // Product Details
    SliverToBoxAdapter(
    child: Container(
    decoration: BoxDecoration(
    color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
    ),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Title and Price Section
    Container(
    padding: EdgeInsets.all(24),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [AppColor.goldAccent, AppColor.earthBrown],
    ),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    children: [
    Icon(Icons.verified, color: Colors.white, size: 16),
    SizedBox(width: 4),
    Text(
    'Handcrafted',
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    Spacer(),
    Row(
    children: [
    Icon(Icons.star, color: AppColor.goldAccent, size: 20),
    SizedBox(width: 4),
    Text(
    '4.8',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
    ),
    ),
    Text(
    ' (124)',
    style: TextStyle(fontSize: 14, color: AppColor.grey),
    ),
    ],
    ),
    ],
    ),
    SizedBox(height: 16),
    Text(
    widget.title,
    style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
    fontFamily: 'PlayfairDisplay',
    ),
    ),
    SizedBox(height: 12),
    Row(
    children: [
    if (_hasDiscount()) ...[
    Text(
    _getOriginalPrice(),
    style: TextStyle(
    fontSize: 18,
    decoration: TextDecoration.lineThrough,
    color: AppColor.grey,
    ),
    ),
    SizedBox(width: 8),
    ],
    Text(
    _getDisplayPrice(),
    style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
    ),
    ),
    if (_getDiscountPercentage() != null) ...[
    SizedBox(width: 12),
    Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
    color: AppColor.warningColor,
    borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
    '-${_getDiscountPercentage()}%',
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ],
    ],
    ),
    if (_isFreeShipping()) ...[
    SizedBox(height: 8),
    Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
    color: AppColor.successColor.withOpacity(0.2),
    borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.local_shipping,
    color: AppColor.successColor, size: 16),
    SizedBox(width: 4),
    Text(
    'Free Shipping',
    style: TextStyle(
    color: AppColor.successColor,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ],
    SizedBox(height: 12),
    Row(
    children: [
    Icon(Icons.inventory_2_outlined,
    size: 18, color: AppColor.grey),
    SizedBox(width: 6),
    Text(
    _getStock() > 0
    ? 'In Stock (${_getStock()} available)'
        : 'Out of Stock',
    style: TextStyle(
    fontSize: 14,
    color: _getStock() > 0
    ? AppColor.successColor
        : AppColor.warningColor,
    fontWeight: FontWeight.w600,
    ),
    ),
    ],
    ),
    ],
    ),
    ),

    // Size Selection
    _buildSectionTitle('Select Size', Icons.straighten),
    Container(
    height: 60,
    child: ListView.builder(
    key: PageStorageKey('sizeList'),
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 24),
    itemCount: availableSizes.length,
    itemBuilder: (context, index) {
    final size = availableSizes[index];
    final isSelected = selectedSize == size;
    return GestureDetector(
    onTap: () {
    setState(() {
    selectedSize = size;
    });
    },
    child: Container(
    margin: EdgeInsets.only(right: 12),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
    gradient: isSelected
    ? LinearGradient(
    colors: [AppColor.primaryColor, AppColor.secondColor],
    )
        : null,
    color: isSelected
    ? null
        : (isDark ? Color(0xFF2C2520) : AppColor.cardBackground),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isSelected ? Colors.transparent : AppColor.borderGray,
    width: 1.5,
    ),
    ),
    child: Center(
    child: Text(
    size,
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: isSelected
    ? Colors.white
        : (isDark ? AppColor.goldAccent : AppColor.primaryColor),
    ),
    ),
    ),
    ),
    );
    },
    ),
    ),

    SizedBox(height: 24),

    // Color Selection - ✅ UPDATED TO USE DATABASE COLORS
    _buildSectionTitle('Select Color', Icons.palette),
    Container(
    height: 80,
    child: ListView.builder(
    key: PageStorageKey('colorList'),
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 24),
    itemCount: availableColors.length,
    itemBuilder: (context, index) {
    final colorName = availableColors[index];
    final isSelected = selectedColor == colorName;
    return GestureDetector(
    onTap: () {
    setState(() {
    selectedColor = colorName;
    });
    },
    child: Container(
    margin: EdgeInsets.only(right: 16),
    child: Column(
    children: [
    Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
    color: _getColorFromName(colorName),
    shape: BoxShape.circle,
    border: Border.all(
    color: isSelected
    ? AppColor.goldAccent
        : AppColor.borderGray,
    width: isSelected ? 3 : 1,
    ),
    boxShadow: isSelected
    ? [
    BoxShadow(
    color: _getColorFromName(colorName).withOpacity(0.4),
    blurRadius: 8,
    offset: Offset(0, 4),
    ),
    ]
        : null,
    ),
    child: isSelected
    ? Icon(Icons.check, color: Colors.white, size: 24)
        : null,
    ),
    SizedBox(height: 6),
    Text(
    colorName,
    style: TextStyle(
    fontSize: 11,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    color: isSelected
    ? (isDark ? AppColor.goldAccent : AppColor.primaryColor)
        : AppColor.grey,
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),
    ),

    SizedBox(height: 24),

    // Quantity Selection
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Quantity',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
    ),
    ),
    Container(
    decoration: BoxDecoration(
    color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColor.borderGray),
    ),
    child: Row(
    children: [
    IconButton(
    onPressed: () {
    if (selectedQuantity > 1) {
    setState(() {
    selectedQuantity--;
    });
    }
    },
    icon: Icon(Icons.remove, color: AppColor.primaryColor),
    ),
    Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Text(
    '$selectedQuantity',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
    ),
    ),
    ),
    IconButton(
    onPressed: () {
    if (selectedQuantity < _getStock()) {
    setState(() {
    selectedQuantity++;
    });
    }
    },
    icon: Icon(Icons.add, color: AppColor.primaryColor),
    ),
    ],
    ),
    ),
    ],
    ),
    ),

    SizedBox(height: 24),

    // Description
    _buildSectionTitle('Description', Icons.description),
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Text(
    widget.content,
    style: TextStyle(
    fontSize: 15,
    height: 1.6,
    color: AppColor.grey,
    ),
    ),
    ),

    SizedBox(height: 24),

    // Features
    _buildSectionTitle('Features', Icons.check_circle_outline),
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Column(
    children: [
    _buildFeatureItem('100% Handmade Egyptian Craftsmanship', Icons.handyman),
    _buildFeatureItem('Premium Quality Wool Material', Icons.verified),
    _buildFeatureItem('Traditional Weaving Technique', Icons.architecture),
    _buildFeatureItem('Easy to Clean & Maintain', Icons.cleaning_services),
    _buildFeatureItem('Free Shipping on Orders Over \$300', Icons.local_shipping),
    ],
    ),
    ),

    SizedBox(height: 24),

    if (relatedProducts.isNotEmpty) ...[
    _buildSectionTitle('Related Products', Icons.grid_view),
    Container(
    height: 240,
    margin: EdgeInsets.only(bottom: 20),
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
    itemCount: relatedProducts.length,
    itemBuilder: (context, index) {
    final related = relatedProducts[index];
    return GestureDetector(
    onTap: () {
    Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => ProductDetailsPage(
        productId: related['product_id'].toString(),
        title: related['product_title'] ?? '',
        content: '',
        imageUrl: related['product_image'],
        price: related['price'] != null && related['price'].toString().isNotEmpty
            ? double.tryParse(related['price'].toString())
            : null,
        discountPrice: related['discount_price'] != null && related['discount_price'].toString().isNotEmpty
            ? double.tryParse(related['discount_price'].toString())
            : null,
      ),
    ),
    );
    },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(
          right: 12,
          left: index == 0 ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2520) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: related['product_image'] != null && related['product_image'].toString().isNotEmpty
                  ? Image.network(
                related['product_image'],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColor.backgroundcolor2,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColor.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              )
                  : Container(
                height: 120,
                width: double.infinity,
                color: AppColor.backgroundcolor2,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColor.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        related['product_title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      related['price'] != null
                          ? '${related['price']}'
                          : '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    },
    ),
    ),
    ],
      SizedBox(height: 100),
    ],
    ),
    ),
    ),
          ],
        ),
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2520) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total Price
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(fontSize: 12, color: AppColor.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getDisplayPrice(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12),

              // Add to Cart Button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isAddingToCart || _getStock() == 0) ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColor.primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isAddingToCart
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black12,
      child: imageUrl == null
          ? _buildPlaceholder()
          : Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
  Widget _buildPlaceholder() {
    return Container(
      color: AppColor.backgroundcolor2,
      child: Center(
        child: Icon(Icons.image_outlined, size: 80, color: AppColor.grey),
      ),
    );
  }
  Widget _buildSectionTitle(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColor.primaryColor, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColor.successColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.4, color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }
  void _showFullScreenImage(int initialIndex) {
    if (productImages.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Center(
                      child: Image.network(
                        productImages[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_outlined,
                              size: 100, color: Colors.white54);
                        },
                      ),
                    ),
                  );
                },
              ),
              SafeArea(
                child: Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}