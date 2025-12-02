import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/pages/shop_page.dart';
import 'package:naseej/pages/special_offers_page.dart';
import 'package:naseej/pages/free_shipping_page.dart';
import 'package:naseej/pages/new_arrivals_page.dart';
import 'package:naseej/pages/product_details_page.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/component/app_drawer.dart';
import '../component/internet_checker_widget.dart';
import '../core/constant/imgaeasset.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const MyHomePage({Key? key, this.onCartUpdated}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Crud crud = Crud();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';

  // Refresh functionality
  bool _isRefreshing = false;
  Key _refreshKey = UniqueKey();

  // Categories from API
  List<dynamic> categories = [];
  bool _categoriesLoaded = false;
  bool _isBackgroundRefreshing = false;

  // Auto-scroll ONLY for promotions
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  Future<void> _silentRefresh() async {
    setState(() {
      _isBackgroundRefreshing = true;
    });

    // Just trigger rebuild
    setState(() {
      _refreshKey = UniqueKey();
    });

    // Small delay to show indicator
    await Future.delayed(Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isBackgroundRefreshing = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Reload both categories and products
    await _loadCategories();
    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _refreshKey = UniqueKey();
      });
    }
  }

  final List<Map<String, dynamic>> _promotions = [
    {
      'title': 'Special Offer',
      'subtitle': 'Up to 30% OFF',
      'description': 'On Traditional Handwoven Carpets',
      'gradient': LinearGradient(
        colors: [AppColor.primaryColor, AppColor.secondColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.local_offer,
      'type': 'offer',
    },
    {
      'title': 'New Arrival',
      'subtitle': 'Premium Collection',
      'description': 'Discover Our Latest Designs',
      'gradient': LinearGradient(
        colors: [AppColor.goldAccent, AppColor.earthBrown],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.auto_awesome,
      'type': 'new_arrivals',
    },
    {
      'title': 'Free Shipping',
      'subtitle': 'Orders Over \$300',
      'description': 'Limited Time Offer',
      'gradient': LinearGradient(
        colors: [AppColor.earthBrown, AppColor.bronzeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.local_shipping,
      'type': 'shipping',
    },
  ];

  @override
  void initState() {
    super.initState();
    final userId = sharedPref.getString("user_id");
    if (userId != null) {
      FavoritesManager.setCurrentUser(userId);
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _loadCategories();

    // Initialize PageController
    _pageController = PageController(initialPage: 0);

    // Start auto-scroll
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _promotions.length;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      var response = await crud.postRequest(AppLink.activeCategories, {});
      if (response != null && response["status"] == "success" && response["data"] != null) {
        setState(() {
          // Add "All" category at the beginning
          categories = [
            {
              'category_id': 'All',
              'category_name': 'All Products',
              'short_name': 'All',
            },
            ...response["data"]
          ];
          _categoriesLoaded = true;
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Get products with category filtering
  getproducts() async {
    var response = await crud.postRequest(AppLink.allProducts, {
      "user_id": sharedPref.getString("user_id") ?? "",
      "category_id": _selectedCategory == 'All' ? '' : _selectedCategory,
    });
    return response;
  }

  void _handlePromotionTap(Map<String, dynamic> promotion) {
    final String type = promotion['type'];

    if (type == 'offer') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SpecialOffersPage(),
        ),
      );
    } else if (type == 'shipping') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FreeShippingPage(),
        ),
      );
    } else if (type == 'new_arrivals') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewArrivalsPage(),
        ),
      );
    }
  }

  // Dynamic icon generator based on category name
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
        drawer: AppDrawer(
          onFavoritesChanged: () {
            setState(() {});
          },
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColor.primaryColor,
              backgroundColor: AppColor.cardBackground,
              child: CustomScrollView(
                key: _refreshKey,
                slivers: [
                  // Custom App Bar with Gradient
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColor.primaryColor,
                    iconTheme: IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        'Naseej',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColor.primaryColor,
                              AppColor.secondColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Welcome Section
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Handcrafted Egyptian Carpets',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Discover timeless elegance woven with tradition',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Promotions Section - AUTO SCROLL ONLY HERE
                  SliverToBoxAdapter(
                    child: Container(
                      height: 180,
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _promotions.length,
                        onPageChanged: (index) {
                          _currentPage = index; // NO setState here!
                        },
                        itemBuilder: (context, index) {
                          final promotion = _promotions[index];
                          return _buildPromotionCard(
                            title: promotion['title'],
                            subtitle: promotion['subtitle'],
                            description: promotion['description'],
                            gradient: promotion['gradient'],
                            icon: promotion['icon'],
                            type: promotion['type'],
                            onTap: () => _handlePromotionTap(promotion),
                          );
                        },
                      ),
                    ),
                  ),

                  // Recommended Section - STATIC "Recommended for You"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppColor.goldAccent, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Recommended for You', // Static title
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ShopPage(category: _selectedCategory),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Category Filter (Real Categories from API)
                  if (_categoriesLoaded)
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
                              onTap: () {
                                setState(() {
                                  _selectedCategory = categoryId;
                                  _refreshKey = UniqueKey(); // This will refresh the products
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                    colors: [AppColor.primaryColor, AppColor.secondColor],
                                  )
                                      : null,
                                  color: isSelected ? null : (isDark ? Color(0xFF2C2520) : AppColor.cardBackground),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : AppColor.borderGray,
                                    width: 1.5,
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
                                      color: isSelected ? Colors.white : (isDark ? AppColor.goldAccent : AppColor.primaryColor),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : (isDark ? AppColor.goldAccent : AppColor.primaryColor),
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

                  // Products Grid
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: FutureBuilder(
                      key: _refreshKey,
                      future: getproducts(),
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
                                      'Loading products...',
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
                                      "Error loading products",
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
                            child: _buildEmptyState(),
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

                              //ProductCard
                              return  ProductCard(
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
                                        onCartUpdated: widget.onCartUpdated, // Add this line
                                      ),
                                    ),
                                  ).then((favoritesChanged) {
                                    // Refresh when returning if favorites changed
                                    if (favoritesChanged == true && mounted) {
                                      setState(() {
                                        _refreshKey = UniqueKey();
                                      });
                                    }
                                  });
                                },
                                onFavoriteChanged: () {
                                  setState(() {
                                    _refreshKey = UniqueKey();
                                  });
                                },
                                onCartUpdated: widget.onCartUpdated, // Add this line
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
                          'Refreshing...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColor.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              _selectedCategory == 'All'
                  ? 'No products available'
                  : 'No products found in ${_getCategoryDisplayName(categories.firstWhere((cat) => cat['category_id'] == _selectedCategory, orElse: () => {'category_name': 'this category'}))}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            if (_selectedCategory != 'All')
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _refreshKey = UniqueKey();
                  });
                },
                child: Text(
                  'View All Products',
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard({
    required String title,
    required String subtitle,
    required String description,
    required Gradient gradient,
    required IconData icon,
    required String type,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: gradient,
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
          onTap: onTap,
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
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16, color: AppColor.primaryColor),
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
    );
  }
}