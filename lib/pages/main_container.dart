import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/functions/alertexitapp.dart';
import 'package:naseej/component/internet_checker_widget.dart';
import 'package:naseej/pages/MyHomePage.dart' hide Text;
import 'package:naseej/pages/explore_page.dart';
import 'package:naseej/pages/cart_page.dart';
import 'package:naseej/pages/favorites_page.dart';
import 'package:naseej/pages/orders_page.dart';
import 'package:naseej/component/custom_bottom_nav.dart';
import 'package:naseej/component/app_drawer.dart';
import 'package:naseej/core/services/cart_service.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;
  //final VoidCallback? onCartUpdated;

  const MainContainer({Key? key,
    this.initialIndex = 2,
    //this.onCartUpdated,
  }) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> with WidgetsBindingObserver {
  late int _currentIndex;
  int _cartItemCount = 0;
  final CartService _cartService = CartService();

  // Keys to force rebuild pages when needed
  final Map<int, GlobalKey<State>> _pageKeys = {
    0: GlobalKey(),
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
    4: GlobalKey(),
  };

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializePages();
    WidgetsBinding.instance.addObserver(this);
    _loadCartCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh pages when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentPage();
      _loadCartCount();
    }
  }

  void _initializePages() {
    _pages = [
      ExplorePage(key: _pageKeys[0]),
      FavoritesPage(key: _pageKeys[1]),
      MyHomePage(key: _pageKeys[2], onCartUpdated: _loadCartCount),
      CartPage(key: _pageKeys[3], onCartUpdated: _loadCartCount),
      OrdersPage(key: _pageKeys[4]),
    ];
  }

  Future<void> _loadCartCount() async {
    try {
      var result = await _cartService.getCart();
      if (result['success'] == true && mounted) {
        var data = result['data'];
        if (data['summary'] != null) {
          setState(() {
            _cartItemCount = data['summary']['total_items'] ?? 0;
          });
        } else {
          setState(() {
            _cartItemCount = 0;
          });
        }
      } else {
        setState(() {
          _cartItemCount = 0;
        });
      }
    } catch (e) {
      print('Error loading cart count: $e');
      setState(() {
        _cartItemCount = 0;
      });
    }
  }

  void _refreshCurrentPage() {
    setState(() {
      // Force rebuild current page only
      if (_currentIndex == 0) {
        _pages[0] = ExplorePage(key: GlobalKey());
      } else if (_currentIndex == 1) {
        _pages[1] = FavoritesPage(key: GlobalKey());
      } else if (_currentIndex == 2) {
        _pages[2] = MyHomePage(key: GlobalKey(), onCartUpdated: _loadCartCount);
      } else if (_currentIndex == 3) {
        _pages[3] = CartPage(key: GlobalKey(), onCartUpdated: _loadCartCount);
      } else if (_currentIndex == 4) {
        _pages[4] = OrdersPage(key: GlobalKey());
      }
    });
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) {
      // If tapping the same tab, refresh it
      _refreshCurrentPage();

      // Also refresh cart count when tapping cart tab
      if (index == 3) {
        _loadCartCount();
      }
      return;
    }

    // INSTANT tab switch - no loading overlay
    setState(() {
      _currentIndex = index;

      // Refresh the page being navigated to
      if (index == 0) {
        _pages[0] = ExplorePage(key: GlobalKey());
      } else if (index == 1) {
        _pages[1] = FavoritesPage(key: GlobalKey());
      } else if (index == 2) {
        _pages[2] = MyHomePage(key: GlobalKey(), onCartUpdated: _loadCartCount);
      } else if (index == 3) {
        _pages[3] = CartPage(key: GlobalKey(), onCartUpdated: _loadCartCount);
        // Load cart count when switching to cart tab
        _loadCartCount();
      } else if (index == 4) {
        _pages[4] = OrdersPage(key: GlobalKey());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show exit dialog only on home page
        if (_currentIndex == 2) {
          return await alertExitApp(context);
        } else {
          // Go back to home page
          setState(() {
            _currentIndex = 2;
            // Refresh home page when navigating back to it
            _pages[2] = MyHomePage(key: GlobalKey(), onCartUpdated: _loadCartCount);
          });
          return false;
        }
      },
      child: InternetCheckerWidget(
        showOnlineMessage: true,
        child: Scaffold(
          drawer: AppDrawer(
            onFavoritesChanged: () {
              // Refresh favorites and home page when favorites change from drawer
              setState(() {
                _pages[1] = FavoritesPage(key: GlobalKey());
                _pages[2] = MyHomePage(key: GlobalKey(), onCartUpdated: _loadCartCount);
              });
            },
            onCartUpdated: _loadCartCount,
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavBarTap,
            cartItemCount: _cartItemCount,
          ),
        ),
      ),
    );
  }
}