import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/imgaeasset.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/pages/product_details_page.dart';

class FreeShippingPage extends StatefulWidget {
  const FreeShippingPage({Key? key}) : super(key: key);

  @override
  State<FreeShippingPage> createState() => _FreeShippingPageState();
}

class _FreeShippingPageState extends State<FreeShippingPage> {
  Crud crud = Crud();
  bool _isRefreshing = false;
  Key _refreshKey = UniqueKey();

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _refreshKey = UniqueKey();
      });
    }
  }

  // Modified to fetch all products and filter locally
  Future getAllProducts() async {
    var response = await crud.postRequest(AppLink.allProducts, {
      "user_id": "", // Empty user_id to get all products
      "category_id": "", // Empty category_id to get all categories
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Free Shipping'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, AppColor.secondColor],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping, size: 18, color: Colors.white),
                SizedBox(width: 4),
                Text('Free', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColor.primaryColor,
        child: FutureBuilder(
          key: _refreshKey,
          future: getAllProducts(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(AppImageAsset.animationLoading, width: 150, height: 150),
                    SizedBox(height: 20),
                    Text('Loading products...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColor.primaryColor)),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data["status"] != "success") {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
                    SizedBox(height: 16),
                    Text('Error loading products', style: TextStyle(fontSize: 18, color: AppColor.warningColor)),
                  ],
                ),
              );
            }

            List<dynamic> products = snapshot.data["data"] ?? [];

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 64, color: AppColor.grey),
                    SizedBox(height: 16),
                    Text('No products available', style: TextStyle(fontSize: 18, color: AppColor.grey)),
                  ],
                ),
              );
            }

            // Filter products locally
            const double freeShippingThreshold = 300.0;

            List<dynamic> eligibleProducts = products.where((product) {
              double price = (product['price'] ?? 0.0).toDouble();
              return price >= freeShippingThreshold;
            }).toList();

            List<dynamic> otherProducts = products.where((product) {
              double price = (product['price'] ?? 0.0).toDouble();
              return price < freeShippingThreshold;
            }).toList();

            return CustomScrollView(
              slivers: [
                // Info Banner - Matching Home Page Promotion Style
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.earthBrown, AppColor.bronzeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Optional: Add tap action if needed
                        },
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.local_shipping, color: Colors.white, size: 28),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Free Shipping',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Orders Over \$$freeShippingThreshold',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Eligible Products Section
                if (eligibleProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColor.successColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                          SizedBox(width: 8),
                          Text('Free Shipping Available',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                color: isDark ? AppColor.goldAccent : AppColor.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, i) => _buildProductCard(eligibleProducts[i], true),
                        childCount: eligibleProducts.length,
                      ),
                    ),
                  ),
                ],

                // Other Products Section - Always show if there are products
                if (otherProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, eligibleProducts.isNotEmpty ? 24 : 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2, color: AppColor.grey, size: 24),
                          SizedBox(width: 8),
                          Text('Other Products',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                color: isDark ? AppColor.goldAccent : AppColor.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, i) => _buildProductCard(otherProducts[i], false),
                        childCount: otherProducts.length,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isFreeShipping) {
    return Stack(
      children: [
        ProductCard(
          productId: product['product_id'].toString(),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                  productId: product['product_id'].toString(),
                  title: product['product_title'] ?? 'Traditional Carpet',
                  content: product['product_content'] ?? 'Beautiful handmade carpet',
                  imageUrl: product['product_image'],
                  price: product['price'] != null ? double.tryParse(product['price'].toString()) : null,
                  discountPrice: product['discount_price'] != null ? double.tryParse(product['discount_price'].toString()) : null,
                ),
              ),
            ).then((favoritesChanged) {
              // Refresh when returning if favorites changed
              if (favoritesChanged == true && mounted) {
                setState(() {
                  //_refreshKey = UniqueKey();
                });
              }
            });
          },
          onFavoriteChanged: () {
            setState(() {});
          },
          title: product['product_title'] ?? "Traditional Carpet",
          imageUrl: product['product_image'],
          price: product['price'] != null ? double.tryParse(product['price'].toString()) : null,
          images: product['images'] != null ? List<String>.from(product['images']) : null,
        ),
        if (isFreeShipping)
          Positioned(
            top: 8,
            left: 8, // Changed from right to left
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.secondColor],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2)
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text('FREE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}