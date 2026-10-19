import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naseej/core/constant/imgaeasset.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/component/internet_checker_widget.dart';
import 'package:naseej/pages/product_details_page.dart';
import 'package:naseej/l10n/app_localizations.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Crud crud = Crud();
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;
  bool _isSearching = false;

  // Remove _refreshKey and use a different approach for search
  String _currentSearchQuery = '';
  Timer? _searchDebounceTimer;

  // Categories from API - same as HomePage
  List<dynamic> categories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Same category loading as HomePage
  Future<void> _loadCategories() async {
    try {
      var response = await crud.postRequest(AppLink.activeCategories, {});
      if (response != null && response["status"] == "success" && response["data"] != null) {
        setState(() {
          // Add "All" category at the beginning
          categories = [
            {'category_id': 'All', 'category_name': 'All', 'short_name': 'All'},
            ...response["data"]
          ];
          _categoriesLoaded = true;
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future getAllProducts() async {
    if (_isSearching && _currentSearchQuery.isNotEmpty) {
      // Search products
      var response = await crud.postRequest(AppLink.searchProducts, {
        "query": _currentSearchQuery,
      });
      return response;
    } else {
      // Get all products or filtered by category - same as HomePage
      var response = await crud.postRequest(AppLink.allProducts, {
        "user_id": sharedPref.getString("user_id") ?? "",
        "category_id": _selectedCategory == 'All' ? '' : _selectedCategory,
      });
      return response;
    }
  }

  void _performSearch(String query) {
    // Cancel any previous debounce timer
    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      // If query is empty, reset search immediately
      setState(() {
        _isSearching = false;
        _currentSearchQuery = '';
      });
    } else {
      // Use debounce to delay the search
      _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isSearching = true;
            _currentSearchQuery = query;
          });
        }
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounceTimer?.cancel();
    setState(() {
      _isSearching = false;
      _currentSearchQuery = '';
    });
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
      // Clear search when category changes
      if (_isSearching) {
        _clearSearch();
      }
    });
  }

  // Same dynamic icon generator as HomePage
  IconData _getDynamicCategoryIcon(String categoryName) {
    categoryName = categoryName.toLowerCase();

    if (categoryName.contains('all') || categoryName.contains('product')) {
      return Icons.grid_view_rounded;
    } else if (categoryName.contains('traditional') || categoryName.contains('persian') || categoryName.contains('turkish')) {
      return Icons.architecture;
    } else if (categoryName.contains('modern') || categoryName.contains('contemporary') || categoryName.contains('geometric')) {
      return Icons.filter_none;
    } else if (categoryName.contains('vintage') || categoryName.contains('antique') || categoryName.contains('classic')) {
      return Icons.history;
    } else if (categoryName.contains('custom') || categoryName.contains('design')) {
      return Icons.palette;
    } else if (categoryName.contains('premium') || categoryName.contains('luxury') || categoryName.contains('royal')) {
      return Icons.workspace_premium;
    } else if (categoryName.contains('outdoor') || categoryName.contains('patio') || categoryName.contains('garden')) {
      return Icons.park;
    } else if (categoryName.contains('wool') || categoryName.contains('silk') || categoryName.contains('carpet')) {
      return Icons.weekend;
    } else {
      return Icons.category;
    }
  }

  String _getCategoryDisplayName(dynamic category) {
    return category['short_name'] ?? category['category_name'] ?? 'Category';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InternetCheckerWidget(
      showOnlineMessage: true,
      onConnectionRestored: _handleRefresh,
      child: Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColor.primaryColor,
              backgroundColor: AppColor.cardBackground,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 160,
                    floating: true,
                    pinned: true,
                    backgroundColor: AppColor.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        AppLocalizations.of(context)!.explore,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColor.primaryColor, AppColor.secondColor],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF2C2520) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _performSearch,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchCarpets,
                            prefixIcon: Icon(Icons.search, color: AppColor.primaryColor),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: AppColor.grey),
                              onPressed: _clearSearch,
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Categories (only show when not searching) - Same as HomePage
                  if (!_isSearching && _categoriesLoaded)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final categoryId = category['category_id'].toString();
                            final categoryName = _getCategoryDisplayName(category);
                            final isSelected = _selectedCategory == categoryId;

                            return GestureDetector(
                              onTap: () => _onCategorySelected(categoryId),
                              child: Container(
                                margin: EdgeInsetsDirectional.only(end: 12),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                    colors: [AppColor.primaryColor, AppColor.secondColor],
                                  )
                                      : null,
                                  color: isSelected ? null : (isDark ? Color(0xFF2C2520) : Colors.white),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : AppColor.primaryColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getDynamicCategoryIcon(category['category_name'] ?? ''),
                                      size: 18,
                                      color: isSelected ? Colors.white : (isDark ? Colors.white : AppColor.primaryColor),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : (isDark ? Colors.white : AppColor.primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

// Products Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              _isSearching
                                  ? _currentSearchQuery.isEmpty
                                      ? AppLocalizations.of(context)!.searchResults
                                      : AppLocalizations.of(context)!.searchResultsFor(_currentSearchQuery)
                                  : _selectedCategory == 'All'
                                      ? AppLocalizations.of(context)!.allProducts
                                      : '${_getCategoryDisplayName(categories.firstWhere((cat) => cat['category_id'] == _selectedCategory, orElse: () => {'category_name': 'Category'}))}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Products Grid
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: FutureBuilder(
                      future: getAllProducts(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: Column(
                                  children: [
                                    Lottie.asset(
                                      AppImageAsset.animationLoading,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      _isSearching ? AppLocalizations.of(context)!.searching : AppLocalizations.of(context)!.loadingProducts,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
                                    SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(context)!.errorLoadingProducts,
                                      style: TextStyle(color: AppColor.warningColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data["status"] != "success" ||
                            snapshot.data["data"] == null ||
                            snapshot.data["data"].isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: AppColor.primaryColor,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _isSearching
                                          ? AppLocalizations.of(context)!.noProductsFoundFor(_currentSearchQuery)
                                          : AppLocalizations.of(context)!.noProductsFound,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        List<dynamic> products = snapshot.data["data"];

                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, i) {
                              final product = products[i];

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
                            childCount: products.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                          fit: BoxFit.contain,
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
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}