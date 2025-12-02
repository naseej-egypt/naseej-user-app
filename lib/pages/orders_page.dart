import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/core/services/cart_service.dart';
import 'package:naseej/pages/order_details_page.dart';
import 'main_container.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  Crud crud = Crud();
  List<OrderModel> orders = [];
  bool isLoading = true;
  late TabController _tabController;
  final CartService _cartService = CartService();
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await crud.postRequest(
        AppLink.getOrders,
        {},
        headers: _getAuthHeaders(),
      );

      if (response != null && response["status"] == "success" && response["data"] != null) {
        List<dynamic> ordersData = response["data"]["orders"];

        List<OrderModel> loadedOrders = [];
        for (var orderData in ordersData) {
          try {
            loadedOrders.add(OrderModel.fromApiJson(orderData));
          } catch (e) {
            print('Error parsing order: $e');
          }
        }

        setState(() {
          orders = loadedOrders;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar(response?['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load orders: ${e.toString()}');
    }
  }

  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    return {"Authorization": "Bearer $token"};
  }

  List<OrderModel> get activeOrders {
    return orders.where((order) =>
    order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled
    ).toList();
  }

  List<OrderModel> get completedOrders {
    return orders.where((order) =>
    order.status == OrderStatus.delivered
    ).toList();
  }

  List<OrderModel> get cancelledOrders {
    return orders.where((order) => order.status == OrderStatus.cancelled).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColor.warningColor),
            SizedBox(width: 12),
            Text('Cancel Order', style: TextStyle(color: AppColor.primaryColor)),
          ],
        ),
        content: Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep Order', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.warningColor),
            child: Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        var response = await crud.postRequest(
          AppLink.cancelOrder,
          {
            "order_id": order.id,
            "reason": "Cancelled by user"
          },
          headers: _getAuthHeaders(),
        );

        if (response != null && response["status"] == "success") {
          setState(() {
            order.status = OrderStatus.cancelled;
          });
          _showSuccessSnackBar('Order cancelled successfully');
          _loadOrders();
        } else {
          _showErrorSnackBar(response?['message'] ?? 'Failed to cancel order');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to cancel order: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  void _trackOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderTrackingDialog(order: order),
    );
  }

  Future<void> _reorder(OrderModel order) async {
    if (_isReordering) return;

    // Show warning for cancelled orders
    if (order.status == OrderStatus.cancelled) {
      bool? proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColor.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColor.goldAccent),
              SizedBox(width: 12),
              Text('Reorder Cancelled Order', style: TextStyle(color: AppColor.primaryColor,fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This order was previously cancelled.'),
              SizedBox(height: 8),
              Text('Please verify product availability and pricing before proceeding.',
                  style: TextStyle(fontSize: 12, color: AppColor.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: AppColor.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
              child: Text('Continue'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() {
      _isReordering = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColor.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColor.primaryColor),
              SizedBox(height: 16),
              Text(
                'Adding items to cart...',
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

      int successfulAdds = 0;
      int failedAdds = 0;
      List<String> failedProducts = [];

      for (var item in order.items) {
        try {
          var response = await _cartService.addToCart(
            productId: item.productId,
            quantity: item.quantity,
          );

          if (response['success'] == true) {
            successfulAdds++;
          } else {
            failedAdds++;
            failedProducts.add(item.name);
          }
        } catch (e) {
          failedAdds++;
          failedProducts.add(item.name);
        }
      }

      Navigator.of(context).pop();

      if (failedAdds == 0) {
        _showSuccessSnackBar('All ${successfulAdds} items added to cart successfully!');
      } else if (successfulAdds > 0 && failedAdds > 0) {
        _showPartialReorderSuccess(successfulAdds, failedAdds, failedProducts);
      } else {
        _showReorderFailed(failedProducts);
      }

    } catch (e) {
      Navigator.of(context).pop();
      _showErrorSnackBar('Failed to reorder: ${e.toString()}');
    } finally {
      setState(() {
        _isReordering = false;
      });
    }
  }

  void _showPartialReorderSuccess(int successful, int failed, List<String> failedProducts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColor.goldAccent),
            SizedBox(width: 12),
            Text('Partial Success', style: TextStyle(color: AppColor.primaryColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$successful item${successful > 1 ? 's' : ''} added to cart successfully.',
              style: TextStyle(color: AppColor.successColor),
            ),
            SizedBox(height: 8),
            Text(
              '$failed item${failed > 1 ? 's' : ''} could not be added:',
              style: TextStyle(color: AppColor.warningColor),
            ),
            SizedBox(height: 8),
            ...failedProducts.take(3).map((product) =>
                Text('• $product', style: TextStyle(fontSize: 12, color: AppColor.grey))
            ).toList(),
            if (failedProducts.length > 3)
              Text('... and ${failedProducts.length - 3} more',
                  style: TextStyle(fontSize: 12, color: AppColor.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue Shopping', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MainContainer(initialIndex: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: Text('View Cart'),
          ),
        ],
      ),
    );
  }

  void _showReorderFailed(List<String> failedProducts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColor.warningColor),
            SizedBox(width: 12),
            Text('Reorder Failed', style: TextStyle(color: AppColor.primaryColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unable to add items to cart. This might be because:'),
            SizedBox(height: 8),
            Text('• Products are out of stock', style: TextStyle(fontSize: 12, color: AppColor.grey)),
            Text('• Products are no longer available', style: TextStyle(fontSize: 12, color: AppColor.grey)),
            Text('• Network connection issues', style: TextStyle(fontSize: 12, color: AppColor.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColor.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBackPressed,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 16.0),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'Active (${activeOrders.length})'),
            Tab(text: 'Completed (${completedOrders.length})'),
            Tab(text: 'Cancelled (${cancelledOrders.length})'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(activeOrders, isDark),
          _buildOrdersList(completedOrders, isDark),
          _buildOrdersList(cancelledOrders, isDark),
        ],
      ),
    );
  }

  void _handleBackPressed() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainContainer(initialIndex: 2),
        ),
      );
    }
  }

  Widget _buildOrdersList(List<OrderModel> ordersToShow, bool isDark) {
    if (ordersToShow.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      backgroundColor: AppColor.primaryColor,
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: ordersToShow.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(ordersToShow[index], isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your orders will appear here once you make a purchase',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainContainer(initialIndex: 0),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Start Shopping', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark) {
    return GestureDetector(
      onTap: () => _viewOrderDetails(order),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2520) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ordered on ${_formatDate(order.orderDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.grey,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  _buildStatusChip(order.status),
                ],
              ),
            ),

            // Items
            ...order.items.take(2).map((item) => _buildOrderItem(item, isDark)).toList(),

            if (order.items.length > 2)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '+ ${order.items.length - 2} more items',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            Divider(height: 1),

            // Footer
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (order.itemCount > 0)
                          Text(
                            '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 12, color: AppColor.grey),
                          ),
                        if (order.storeName != null && order.storeName!.isNotEmpty)
                          Text(
                            'Store: ${order.storeName}',
                            style: TextStyle(fontSize: 12, color: AppColor.goldAccent),
                          ),
                      ],
                    ),
                  ),
                  _buildActionButtons(order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColor.backgroundcolor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(item.image),
            ),
          ),
          SizedBox(width: 12),
          // Product Details - Takes available space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColor.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: AppColor.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Price - Fixed width to prevent overflow
          Container(
            constraints: BoxConstraints(minWidth: 70),
            child: Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.goldAccent,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    String finalImageUrl = imageUrl;
    if (!imageUrl.startsWith('http')) {
      finalImageUrl = '${AppLink.server}/upload/products/$imageUrl';
    }

    return Image.network(
      finalImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColor.backgroundcolor2,
      child: Icon(
        Icons.image_outlined,
        size: 30,
        color: AppColor.grey,
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 14, color: statusInfo.color),
          SizedBox(width: 6),
          Text(
            statusInfo.text,
            style: TextStyle(
              color: statusInfo.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    return Row(
      children: [
        if (order.status == OrderStatus.onTheWay || order.status == OrderStatus.preparing)
          IconButton(
            onPressed: () => _trackOrder(order),
            icon: Icon(Icons.track_changes_outlined, size: 20),
            color: AppColor.primaryColor,
            tooltip: 'Track Order',
          ),
        if (order.status == OrderStatus.preparing)
          IconButton(
            onPressed: () => _cancelOrder(order),
            icon: Icon(Icons.cancel_outlined, size: 20),
            color: AppColor.warningColor,
            tooltip: 'Cancel Order',
          ),
        if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled)
          IconButton(
            onPressed: _isReordering ? null : () => _reorder(order),
            icon: _isReordering
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(Icons.replay_outlined, size: 20),
            color: order.status == OrderStatus.delivered ? AppColor.successColor : AppColor.goldAccent,
            tooltip: 'Reorder',
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  StatusInfo _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return StatusInfo(
          text: 'Preparing',
          color: AppColor.goldAccent,
          icon: Icons.schedule_outlined,
        );
      case OrderStatus.onTheWay:
        return StatusInfo(
          text: 'On the Way',
          color: AppColor.primaryColor,
          icon: Icons.local_shipping_outlined,
        );
      case OrderStatus.delivered:
        return StatusInfo(
          text: 'Delivered',
          color: AppColor.successColor,
          icon: Icons.check_circle_outline,
        );
      case OrderStatus.cancelled:
        return StatusInfo(
          text: 'Cancelled',
          color: AppColor.warningColor,
          icon: Icons.cancel_outlined,
        );
    }
  }
}

// Order Tracking Dialog
class OrderTrackingDialog extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingDialog({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Color(0xFF2C2520) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes_outlined, color: AppColor.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Order Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Tracking Number: ${order.trackingNumber ?? 'Not available'}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            _buildTrackingStepper(order.status),
            SizedBox(height: 20),
            if (order.estimatedDelivery != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColor.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Estimated Delivery: ${_formatDate(order.estimatedDelivery!)}',
                      style: TextStyle(color: AppColor.primaryColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStepper(OrderStatus currentStatus) {
    final steps = [
      _TrackingStep('Order Placed', OrderStatus.preparing, Icons.shopping_bag_outlined),
      _TrackingStep('Preparing', OrderStatus.preparing, Icons.schedule_outlined),
      _TrackingStep('On the Way', OrderStatus.onTheWay, Icons.local_shipping_outlined),
      _TrackingStep('Delivered', OrderStatus.delivered, Icons.check_circle_outlined),
    ];

    int currentStepIndex = steps.indexWhere((step) => step.status == currentStatus);
    if (currentStepIndex == -1) currentStepIndex = steps.length - 1;

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentStepIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColor.primaryColor : AppColor.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, size: 16, color: Colors.white),
            ),
            SizedBox(width: 12),
            // Step Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColor.primaryColor : AppColor.grey,
                    ),
                  ),
                  if (!isLast) SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TrackingStep {
  final String title;
  final OrderStatus status;
  final IconData icon;

  _TrackingStep(this.title, this.status, this.icon);
}

// Models and Enums
enum OrderStatus {
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double totalAmount;
  OrderStatus status;
  final int itemCount;
  final String? storeName;
  final String? deliveryManName;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? deliveredAt;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.itemCount,
    this.storeName,
    this.deliveryManName,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveredAt,
    this.trackingNumber,
    this.estimatedDelivery,
  });

  factory OrderModel.fromApiJson(Map<String, dynamic> json) {
    // Parse items
    List<OrderItem> items = [];
    if (json['items'] is List) {
      for (var itemData in json['items']) {
        items.add(OrderItem.fromApiJson(itemData));
      }
    }

    // Map API status to OrderStatus
    OrderStatus status = _mapApiStatusToOrderStatus(json['status']);

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? 'N/A',
      orderDate: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      items: items,
      totalAmount: (json['total'] ?? 0.0).toDouble(),
      status: status,
      itemCount: (json['item_count'] ?? items.length).toInt(),
      storeName: json['store_name'],
      deliveryManName: json['delivery_man_name'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      trackingNumber: json['tracking_number'],
      estimatedDelivery: json['estimated_delivery'] != null ? DateTime.parse(json['estimated_delivery']) : null,
    );
  }

  static OrderStatus _mapApiStatusToOrderStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
      case 'confirmed':
      case 'processing':
        return OrderStatus.preparing;
      case 'shipped':
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.preparing;
    }
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final String? image;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromApiJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      name: json['product_name'] ?? 'Unknown Product',
      image: json['product_image'],
      quantity: (json['quantity'] ?? 1).toInt(),
      price: (json['price'] ?? 0.0).toDouble(),
      total: (json['total'] ?? (json['price'] ?? 0.0) * (json['quantity'] ?? 1)).toDouble(),
    );
  }
}

class OrderDetailsModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String paymentStatus;
  final String paymentMethod;
  final String? deliveryManName;
  final String? storeName;
  final Map<String, dynamic>? deliveryAddress;
  final Map<String, dynamic>? storeInfo;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveredAt;

  OrderDetailsModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.deliveryManName,
    this.storeName,
    this.deliveryAddress,
    this.storeInfo,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse items
    List<OrderItem> items = [];
    if (json['items'] is List) {
      for (var itemData in json['items']) {
        items.add(OrderItem.fromApiJson(itemData));
      }
    }

    // Parse delivery address
    Map<String, dynamic>? deliveryAddress;
    if (json['delivery_address'] is Map) {
      deliveryAddress = Map<String, dynamic>.from(json['delivery_address']);
    }

    // Parse store info
    Map<String, dynamic>? storeInfo;
    if (json['store_info'] is Map) {
      storeInfo = Map<String, dynamic>.from(json['store_info']);
    }

    return OrderDetailsModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? 'N/A',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      items: items,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      status: _mapApiStatusToOrderStatus(json['status']),
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'unknown',
      deliveryManName: json['delivery_man_name'],
      storeName: json['store_name'],
      deliveryAddress: deliveryAddress,
      storeInfo: storeInfo,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
    );
  }

  static OrderStatus _mapApiStatusToOrderStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
      case 'confirmed':
      case 'processing':
        return OrderStatus.preparing;
      case 'shipped':
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.preparing;
    }
  }
}

class StatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  StatusInfo({required this.text, required this.color, required this.icon});
}