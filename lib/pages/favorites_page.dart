import 'package:flutter/material.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/main.dart';
import 'package:naseej/pages/product_details_page.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/l10n/app_localizations.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with AutomaticKeepAliveClientMixin {
  Crud crud = Crud();
  List<Map<String, dynamic>> favoriteProducts = [];
  bool isLoading = true;
  String? error;

  // Keep state alive to maintain data when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (!FavoritesManager.isInitialized) {
        await FavoritesManager.initialize();
      }

      String? userId = sharedPref.getString("user_id");
      if (userId == null) {
        setState(() {
          error = AppLocalizations.of(context)!.pleaseLoginToViewFavorites;
          isLoading = false;
        });
        return;
      }

      // Fetch favorites from server
      var response = await crud.postRequest(AppLink.getFavorites, {
        "customer_id": userId,
      });

      if (response["status"] == "success" && response["data"] != null) {
        List<dynamic> serverFavorites = response["data"]["favorites"] ?? [];

        List<Map<String, dynamic>> processedFavorites = [];
        for (var fav in serverFavorites) {
          processedFavorites.add({
            'favorite_id': fav['favorite_id'],
            'product_id': fav['product_id'],
            'product_title': fav['name'],
            'product_content': fav['description'],
            'price': fav['price'],
            'discount_price': fav['discount_price'],
            'discount_percent': fav['discount_percent'],
            'final_price': fav['final_price'],
            'stock': fav['stock'],
            'in_stock': fav['in_stock'],
            'product_image': fav['images'] != null && fav['images'].isNotEmpty
                ? fav['images'][0]
                : null,
            'images': fav['images'],
            'category_name': fav['category_name'],
            'added_at': fav['added_at'],
          });
        }

        if (mounted) {
          setState(() {
            favoriteProducts = processedFavorites;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            favoriteProducts = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading favorite products: $e");
      if (mounted) {
        setState(() {
          favoriteProducts = [];
          isLoading = false;
          error = "${AppLocalizations.of(context)!.errorLoadingFavorites}: ${e.toString()}";
        });
      }
    }
  }

  void _onFavoriteChanged() {
    // Reload favorites immediately when a product is removed
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _loadFavoriteProducts();
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.favorites),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateToHome,
        ),
        actions: [
          if (favoriteProducts.isNotEmpty)
            Center(
              child: Container(
                margin: EdgeInsetsDirectional.only(end: 16),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.goldAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.goldAccent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "${favoriteProducts.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryColor,
          strokeWidth: 3,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
              SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColor.warningColor),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFavoriteProducts,
                icon: Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (favoriteProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavoriteProducts,
      color: AppColor.primaryColor,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];

          return ProductCard(
            productId: product['product_id'].toString(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    productId: product['product_id'].toString(),
                    title: product['product_title'] ?? 'Traditional Carpet',
                    content: product['product_content'] ?? 'Beautiful handmade carpet',
                    imageUrl: product['product_image'],
                    price: product['price'] != null
                        ? double.tryParse(product['price'].toString())
                        : null,
                    discountPrice: product['discount_price'] != null
                        ? double.tryParse(product['discount_price'].toString())
                        : null,
                  ),
                ),
              ).then((_) {
                // Reload favorites when returning from product details
                _loadFavoriteProducts();
              });
            },
            onFavoriteChanged: _onFavoriteChanged,
            title: product['product_title'] ?? "Traditional Carpet",
            imageUrl: product['product_image'],
            price: product['price'] != null
                ? double.tryParse(product['price'].toString())
                : null,
            images: product['images'] != null
                ? List<String>.from(product['images'])
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: Duration(seconds: 2),
                tween: Tween<double>(begin: 0.8, end: 1.1),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColor.cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.pink.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.noFavoritesYet,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppLocalizations.of(context)!.startMarkingFavorites,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.grey,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.withOpacity(0.1),
                      AppColor.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.pink.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.tapHeartIcon,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _navigateToHome,
                icon: Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context)!.backToHome),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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