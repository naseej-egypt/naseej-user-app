import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/l10n/app_localizations.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/pages/main_container.dart';

import '../core/services/cart_service.dart';

class ProductCard extends StatefulWidget {
  final void Function() onTap;
  final void Function()? onFavoriteChanged;
  final String productId;
  final String title;
  final String? imageUrl;
  final double? price;
  final List<String>? images;
  final List<String>? colors;
  final List<String>? sizes;
  final VoidCallback? onCartUpdated;

  const ProductCard({
    Key? key,
    required this.onTap,
    this.onFavoriteChanged,
    required this.productId,
    required this.title,
    this.imageUrl,
    this.price,
    this.images,
    this.colors,
    this.sizes,
    this.onCartUpdated,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool _disposed = false;
  bool _isTogglingFavorite = false;
  bool _isAddingToCart = false;
  int _currentImageIndex = 0;
  PageController? _pageController;
  bool _showCarouselIndicators = false;

  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();

    if (_hasMultipleImages) {
      _pageController = PageController();
    }
  }

  void _loadFavoriteStatus() {
    if (widget.productId.isNotEmpty) {
      try {
        setState(() {
          isFavorite = FavoritesManager.isFavorite(widget.productId);
        });
      } catch (e) {
        isFavorite = false;
      }
    }
  }

  bool get _hasMultipleImages {
    return widget.images != null && widget.images!.length > 1;
  }

  void _onPageChanged(int index) {
    if (_disposed) return;
    setState(() {
      _currentImageIndex = index;
    });
  }

  void _toggleCarouselIndicators(bool show) {
    if (_disposed || !_hasMultipleImages) return;
    setState(() {
      _showCarouselIndicators = show;
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite || _disposed || widget.productId.isEmpty) return;
    _isTogglingFavorite = true;

    try {
      if (mounted && !_disposed) {
        // Update UI immediately for instant feedback
        final newState = !isFavorite;
        setState(() => isFavorite = newState);

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
                Text(newState ? AppLocalizations.of(context)!.addingToFavorites : AppLocalizations.of(context)!.removingFromFavorites),
              ],
            ),
            duration: Duration(seconds: 1),
            backgroundColor: AppColor.primaryColor,
          ),
        );

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
                    Text(newState ? AppLocalizations.of(context)!.addedToFavorites : AppLocalizations.of(context)!.removedFromFavorites),
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

          // Notify parent to refresh
          if (widget.onFavoriteChanged != null) {
            // Use a small delay to ensure the UI updates smoothly
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                widget.onFavoriteChanged!();
              }
            });
          }
        } else {
          // Revert UI if backend failed
          if (mounted && !_disposed) {
            setState(() => isFavorite = !newState);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.failedToUpdateFavorite),
                backgroundColor: AppColor.warningColor,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert UI on error
      if (mounted && !_disposed) {
        setState(() => isFavorite = !isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseTryAgainLater),
            backgroundColor: AppColor.warningColor,
          ),
        );
      }
    } finally {
      _isTogglingFavorite = false;
    }
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart || _disposed || widget.productId.isEmpty) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Get default color and size if available
      String? selectedColor;
      String? selectedSize;

      if (widget.colors != null && widget.colors!.isNotEmpty) {
        selectedColor = widget.colors!.first;
      }

      if (widget.sizes != null && widget.sizes!.isNotEmpty) {
        selectedSize = widget.sizes!.first;
      }

      // Add to cart using CartService
      final result = await _cartService.addToCart(
        productId: widget.productId,
        quantity: 1,
        color: selectedColor,
        size: selectedSize,
      );

      if (result['success'] == true && mounted) {
        widget.onCartUpdated?.call();

        // Capture context-dependent objects BEFORE showing snackbar
        // to prevent crash when user taps action after widget disposal
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        final l10n = AppLocalizations.of(context)!;

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.addedToCart,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColor.successColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: l10n.viewCart,
              textColor: Colors.white,
              onPressed: () {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => MainContainer(initialIndex: 3),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? AppLocalizations.of(context)!.failedToAddToCart,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColor.warningColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.pleaseTryAgainLater,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColor.warningColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted && !_disposed) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  String _getDisplayPrice() {
    final price = widget.price;
    if (price == null) return '\$299';
    return '\$${price.toStringAsFixed(2)}';
  }

  String _getProductName() {
    return widget.title.trim().isEmpty ? 'Traditional Carpet' : widget.title;
  }

  List<String> _getAllImages() {
    if (widget.images != null && widget.images!.isNotEmpty) {
      return widget.images!;
    }
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return [widget.imageUrl!];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = _getAllImages();
    final hasMultipleImages = _hasMultipleImages;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _toggleCarouselIndicators(true),
        onExit: (_) => _toggleCarouselIndicators(false),
        child: Container(
          width: 165,
          height: 240,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Image Section - Fixed height
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: _buildImageSection(images, hasMultipleImages, isDark),
                  ),
                ),
              ),

              // Content Section - Fixed height
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 92,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product Name
                      Container(
                        height: 16,
                        child: Text(
                          _getProductName(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                            fontFamily: 'PlayfairDisplay',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Price
                      Container(
                        height: 18,
                        child: Text(
                          _getDisplayPrice(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          ),
                        ),
                      ),

                      // Add to Cart Button
                      GestureDetector(
                        onTap: _addToCart,
                        child: Container(
                          height: 26,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColor.primaryColor, AppColor.secondColor],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: _isAddingToCart
                                ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              AppLocalizations.of(context)!.addToCart,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite Button with animation
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isFavorite
                              ? AppColor.primaryColor.withOpacity(0.3)
                              : Colors.black.withOpacity(0.15),
                          blurRadius: isFavorite ? 6 : 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: _isTogglingFavorite
                        ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                      ),
                    )
                        : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColor.primaryColor : AppColor.grey,
                      size: 14,
                    ),
                  ),
                ),
              ),

              // Image Carousel Indicator
              if (hasMultipleImages && images.length > 1 && _showCarouselIndicators)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? AppColor.goldAccent
                              : AppColor.bronzeAccent.withOpacity(0.5),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(List<String> images, bool hasMultipleImages, bool isDark) {
    if (images.isEmpty) {
      return _buildPlaceholder(isDark);
    }

    if (hasMultipleImages) {
      return PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(isDark),
            errorWidget: (context, url, error) => _buildPlaceholder(isDark),
            fadeInDuration: Duration(milliseconds: 300),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: images.first,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(isDark),
        errorWidget: (context, url, error) => _buildPlaceholder(isDark),
        fadeInDuration: Duration(milliseconds: 300),
      );
    }
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF2C2520), Color(0xFF1A1614)]
              : [AppColor.backgroundcolor2, AppColor.backgroundcolor],
        ),
      ),
      child: Icon(
        Icons.photo_outlined,
        size: 40,
        color: AppColor.earthBrown.withOpacity(0.3),
      ),
    );
  }
}