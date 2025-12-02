import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/models/store_model.dart';
import 'package:naseej/component/store_card.dart';
import 'package:naseej/component/store_filter_sheet.dart';
import 'package:naseej/component/internet_checker_widget.dart';
import 'package:naseej/core/services/store_service.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({Key? key}) : super(key: key);

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final StoreService _storeService = StoreService();
  final TextEditingController _searchController = TextEditingController();
  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCity = 'All';
  String _selectedRegion = 'All';

  // Mock current location
  final double _currentLat = 30.0444;
  final double _currentLng = 31.2357;

  List<String> _availableCities = ['All'];
  List<String> _availableRegions = ['All'];

  @override
  void initState() {
    super.initState();
    _loadStores();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    try {
      print('=== LOADING STORES ===');
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      final result = await _storeService.searchStores(
        query: _searchQuery,
        city: _selectedCity,
        region: _selectedRegion,
      );

      print('=== API RESULT ===');
      print('Success: ${result['success']}');
      print('Error: ${result['error']}');
      print('Stores count: ${result['stores'] != null ? (result['stores'] as List).length : 0}');

      if (result['success'] == true) {
        final stores = result['stores'] as List<Store>;
        final filters = result['filters'] as Map<String, dynamic>;

        print('=== PROCESSED DATA ===');
        print('Stores received: ${stores.length}');

        setState(() {
          _stores = stores;
          _filteredStores = _calculateDistances(stores);
          _availableCities = List<String>.from(filters['available_cities'] ?? ['All']);
          _availableRegions = List<String>.from(filters['available_regions'] ?? ['All']);
          _isLoading = false;
        });

        print('Final stores count: ${_filteredStores.length}');
        print('Available cities: $_availableCities');
        print('Available regions: $_availableRegions');
      } else {
        print('=== API ERROR ===');
        print(result['error']);
        setState(() {
          _hasError = true;
          _errorMessage = result['error'] ?? 'Unknown error';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('=== EXCEPTION ===');
      print(e.toString());
      setState(() {
        _hasError = true;
        _errorMessage = 'Exception: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Store> _calculateDistances(List<Store> stores) {
    return stores.map((store) {
      final distance = _calculateDistance(store.latitude, store.longitude);
      return Store(
        id: store.id,
        name: store.name,
        description: store.description,
        address: store.address,
        city: store.city,
        region: store.region,
        latitude: store.latitude,
        longitude: store.longitude,
        phone: store.phone,
        email: store.email,
        imageUrl: store.imageUrl,
        rating: store.rating,
        reviewCount: store.reviewCount,
        isOpen: store.isOpen,
        openingHours: store.openingHours,
        workingDays: store.workingDays,
        distance: distance,
        manager: store.manager,
        deliveryMenCount: store.deliveryMenCount,
      );
    }).toList();
  }

  double _calculateDistance(double lat, double lng) {
    final double dLat = (lat - _currentLat) * 111.32;
    final double dLng = (lng - _currentLng) * 111.32 * cos((_currentLat * 3.1415926535) / 180);
    return sqrt(dLat * dLat + dLng * dLng);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
      });
      _debounceLoadStores();
    }
  }

  Timer? _debounceTimer;
  void _debounceLoadStores() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _loadStores);
  }

  void _onFiltersChanged({
    String? city,
    String? region,
  }) {
    setState(() {
      _selectedCity = city ?? _selectedCity;
      _selectedRegion = region ?? _selectedRegion;
    });
    _loadStores();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCity = 'All';
      _selectedRegion = 'All';
    });
    _loadStores();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InternetCheckerWidget(
      showOnlineMessage: true,
      child: Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColor.primaryColor,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Our Stores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16), // Reduced horizontal padding
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search stores by name, address, or city...',
                          prefixIcon: Icon(Icons.search, color: AppColor.primaryColor),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, color: AppColor.grey),
                            onPressed: () {
                              _searchController.clear();
                              _loadStores();
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showFilterBottomSheet,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColor.borderGray),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.filter_list, size: 20, color: AppColor.primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'Filters',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColor.primaryColor),
                      SizedBox(height: 16),
                      Text(
                        'Loading stores...',
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_hasError)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load stores',
                        style: TextStyle(
                          color: AppColor.warningColor,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: AppColor.grey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStores,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                        ),
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredStores.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_mall_directory, size: 64, color: AppColor.grey),
                        SizedBox(height: 16),
                        Text(
                          'No stores found',
                          style: TextStyle(
                            color: AppColor.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8), // Reduced padding
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final store = _filteredStores[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8), // Reduced spacing
                          child: StoreCard(store: store),
                        );
                      },
                      childCount: _filteredStores.length,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoreFilterSheet(
        selectedCity: _selectedCity,
        selectedRegion: _selectedRegion,
        onFiltersChanged: _onFiltersChanged,
        availableCities: _availableCities,
        availableRegions: _availableRegions,
      ),
    );
  }
}