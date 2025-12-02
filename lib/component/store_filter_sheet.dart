import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';

class StoreFilterSheet extends StatefulWidget {
  final String selectedCity;
  final String selectedRegion;
  final Function({
  String? city,
  String? region,
  }) onFiltersChanged;
  final List<String> availableCities;
  final List<String> availableRegions;

  const StoreFilterSheet({
    Key? key,
    required this.selectedCity,
    required this.selectedRegion,
    required this.onFiltersChanged,
    required this.availableCities,
    required this.availableRegions,
  }) : super(key: key);

  @override
  State<StoreFilterSheet> createState() => _StoreFilterSheetState();
}

class _StoreFilterSheetState extends State<StoreFilterSheet> {
  late String _selectedCity;
  late String _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _selectedRegion = widget.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1614) : AppColor.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Stores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColor.backgroundcolor : AppColor.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Filter
                  Text(
                    'City',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? AppColor.backgroundcolor : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.availableCities.map((city) {
                      final isSelected = _selectedCity == city;
                      return FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCity = selected ? city : 'All';
                          });
                        },
                        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor,
                        selectedColor: AppColor.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColor.backgroundcolor : AppColor.primaryColor),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Region Filter
                  Text(
                    'Region',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? AppColor.backgroundcolor : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.availableRegions.map((region) {
                      final isSelected = _selectedRegion == region;
                      return FilterChip(
                        label: Text(region),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRegion = selected ? region : 'All';
                          });
                        },
                        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor,
                        selectedColor: AppColor.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColor.backgroundcolor : AppColor.primaryColor),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action Buttons (Fixed at bottom)
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCity = 'All';
                        _selectedRegion = 'All';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primaryColor,
                      side: BorderSide(color: AppColor.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Reset Filters'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltersChanged(
                        city: _selectedCity,
                        region: _selectedRegion,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}