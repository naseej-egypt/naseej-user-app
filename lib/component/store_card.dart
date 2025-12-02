import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/models/store_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Reduced margins
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
      child: Column(
        children: [
          // Store Image and Status
          Stack(
            children: [
              _buildStoreImage(),

              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: store.isOpen ? AppColor.successColor : AppColor.warningColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    store.isOpen ? 'OPEN' : 'CLOSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // // Distance Badge
              // if (store.distance > 0)
              //   Positioned(
              //     top: 12,
              //     left: 12,
              //     child: Container(
              //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //       decoration: BoxDecoration(
              //         color: Colors.black.withOpacity(0.7),
              //         borderRadius: BorderRadius.circular(20),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(0.3),
              //             blurRadius: 4,
              //             offset: Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: Text(
              //         '${store.distance.toStringAsFixed(1)} km',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 12,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),

          // Store Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColor.backgroundcolor : AppColor.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Row(
                    //   children: [
                    //     Icon(Icons.star, color: AppColor.goldAccent, size: 16),
                    //     SizedBox(width: 4),
                    //     Text(
                    //       store.rating.toStringAsFixed(1),
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: AppColor.goldAccent,
                    //       ),
                    //     ),
                    //     SizedBox(width: 4),
                    //     Text(
                    //       '(${store.reviewCount})',
                    //       style: TextStyle(
                    //         color: AppColor.grey,
                    //         fontSize: 12,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),

                SizedBox(height: 8),

                // Description
                Text(
                  store.description,
                  style: TextStyle(
                    color: AppColor.grey,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 12),

                // Location and Contact Info
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColor.primaryColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${store.address}, ${store.city}',
                        style: TextStyle(
                          color: AppColor.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColor.primaryColor),
                    SizedBox(width: 6),
                    Text(
                      store.phone,
                      style: TextStyle(
                        color: AppColor.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Opening Hours
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF3A3129) : AppColor.backgroundcolor2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColor.earthBrown),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getTodayOpeningHours(store.openingHours),
                          style: TextStyle(
                            color: AppColor.earthBrown,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showDirectionsDialog(context);
                        },
                        icon: Icon(Icons.directions, size: 16),
                        label: Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.primaryColor,
                          side: BorderSide(color: AppColor.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _callStore(store.phone, context);
                        },
                        icon: Icon(Icons.call, size: 16),
                        label: Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreImage() {
    if (store.imageUrl == null ||
        store.imageUrl!.isEmpty ||
        store.imageUrl == 'null' ||
        !store.imageUrl!.startsWith('http')) {
      return _buildPlaceholderImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: store.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmerEffect(),
          errorWidget: (context, url, error) {
            return _buildPlaceholderImage();
          },
          fadeInDuration: Duration(milliseconds: 300),
          fadeInCurve: Curves.easeIn,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor.withOpacity(0.1),
            AppColor.secondColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 48,
            color: AppColor.primaryColor.withOpacity(0.4),
          ),
          SizedBox(height: 8),
          Text(
            'Store Image',
            style: TextStyle(
              color: AppColor.primaryColor.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getTodayOpeningHours(List<String> openingHours) {
    if (openingHours.isEmpty) return 'Today: Closed';

    final now = DateTime.now();
    final today = now.weekday - 1;

    if (today < openingHours.length) {
      final hours = openingHours[today];
      if (hours.isNotEmpty) {
        return 'Today: $hours';
      }
    }

    if (openingHours.isNotEmpty && openingHours.first.isNotEmpty) {
      return 'Today: ${openingHours.first}';
    }

    return 'Today: Closed';
  }

  void _showDirectionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Get Directions'),
        content: Text('Open ${store.name} in your maps app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchMaps(store.latitude, store.longitude, store.name);
            },
            child: Text('Open Maps'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng, String label) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch maps: $url');
    }
  }

  Future<void> _callStore(String phone, BuildContext context) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = 'tel:$cleanedPhone';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showPhoneFallbackDialog(phone, context);
    }
  }

  void _showPhoneFallbackDialog(String phone, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Store'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unable to launch phone dialer.'),
            SizedBox(height: 8),
            Text('Store Phone: $phone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}