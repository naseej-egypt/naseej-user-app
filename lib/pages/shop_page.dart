import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/imgaeasset.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/pages/product_details_page.dart';
import 'package:naseej/l10n/app_localizations.dart';

class ShopPage extends StatefulWidget {
  final String category;

  const ShopPage({Key? key, required this.category}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Crud crud = Crud();
  bool _isRefreshing = false;
  Key _refreshKey = UniqueKey();

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _refreshKey = UniqueKey();
      });
    }
  }

  Future getproducts() async {
    var response = await crud.postRequest(AppLink.allProducts, {
      "user_id": sharedPref.getString("user_id") ?? "",
      "category_id": widget.category == 'All' ? '' : widget.category,
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(widget.category == 'All' ? AppLocalizations.of(context)!.recommendedForYou : '${widget.category} ${AppLocalizations.of(context)!.carpets}'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColor.primaryColor,
            child: FutureBuilder(
              key: _refreshKey,
              future: getproducts(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          AppImageAsset.animationLoading,
                          width: 150,
                          height: 150,
                        ),
                        SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.loadingProducts,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.errorLoadingProducts,
                          style: TextStyle(color: AppColor.warningColor),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleRefresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data["status"] != "success" ||
                    snapshot.data["data"] == null ||
                    snapshot.data["data"].isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          size: 64,
                          color: AppColor.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noProductsFound,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColor.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<dynamic> products = snapshot.data["data"];

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final product = products[i];

                    return ProductCard( // ADD THIS RETURN STATEMENT
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
                    );
                  },
                );
              },
            ),
          ),

          if (_isRefreshing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        AppImageAsset.animationLoading,
                        width: 150,
                        height: 150,
                      ),
                      SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.refreshing,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}