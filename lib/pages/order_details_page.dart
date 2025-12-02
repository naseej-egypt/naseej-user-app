import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/pages/orders_page.dart';
class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final Crud _crud = Crud();
  OrderDetailsModel? _orderDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final token = sharedPref.getString("token");
      var response = await _crud.postRequest(
        AppLink.getOrderDetails,
        {"order_id": widget.orderId},
        headers: {"Authorization": "Bearer $token"},
      );

      if (response != null && response["status"] == "success" && response["data"] != null) {
        setState(() {
          _orderDetails = OrderDetailsModel.fromJson(response["data"]);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        _showErrorSnackBar(response?['message'] ?? 'Failed to load order details');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load order details: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_orderDetails != null && _orderDetails!.status == OrderStatus.preparing)
            IconButton(
              icon: Icon(Icons.cancel_outlined),
              onPressed: _cancelOrder,
              tooltip: 'Cancel Order',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
          ? _buildErrorState()
          : _orderDetails == null
          ? _buildEmptyState()
          : _buildOrderDetails(_orderDetails!, isDark),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColor.primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading order details...',
            style: TextStyle(
              fontSize: 16,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColor.warningColor,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load order details',
            style: TextStyle(
              fontSize: 18,
              color: AppColor.warningColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColor.primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'Order not found',
            style: TextStyle(
              fontSize: 18,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The order you\'re looking for doesn\'t exist',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(OrderDetailsModel order, bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadOrderDetails,
      backgroundColor: AppColor.primaryColor,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildOrderSummaryCard(order, isDark),
            SizedBox(height: 16),

            // Delivery Information Card
            _buildDeliveryInfoCard(order, isDark),
            SizedBox(height: 16),

            // Order Items Card
            _buildOrderItemsCard(order, isDark),
            SizedBox(height: 16),

            // Payment Summary Card
            _buildPaymentSummaryCard(order, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderDetailsModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColor.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Order Number', order.orderNumber, isDark),
            _buildInfoRow('Order Date', _formatDate(order.createdAt), isDark),
            _buildInfoRow('Order Status', _getStatusText(order.status), isDark,
                valueColor: _getStatusColor(order.status)),
            _buildInfoRow('Payment Status', _getPaymentStatusText(order.paymentStatus), isDark,
                valueColor: _getPaymentStatusColor(order.paymentStatus)),
            _buildInfoRow('Payment Method', _getPaymentMethodText(order.paymentMethod), isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard(OrderDetailsModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: AppColor.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Delivery Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (order.deliveryAddress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (order.deliveryAddress!['street'] != null)
                    Text(
                      order.deliveryAddress!['street']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  if (order.deliveryAddress!['city'] != null)
                    Text(
                      '${order.deliveryAddress!['city']!}, ${order.deliveryAddress!['state'] ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  if (order.deliveryAddress!['country'] != null)
                    Text(
                      order.deliveryAddress!['country']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              )
            else if (order.storeInfo != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Pickup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    order.storeInfo!['name'] ?? 'Store',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (order.storeInfo!['address'] != null)
                    Text(
                      order.storeInfo!['address']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  if (order.storeInfo!['phone'] != null)
                    Text(
                      'Phone: ${order.storeInfo!['phone']!}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            SizedBox(height: 12),
            if (order.deliveryManName != null && order.deliveryManName!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Personnel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    order.deliveryManName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            if (order.notes != null && order.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    'Special Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(OrderDetailsModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: AppColor.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Order Items (${order.items.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...order.items.map((item) => _buildOrderItem(item, isDark)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF3A312B) : AppColor.backgroundcolor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
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
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColor.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.grey,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$${item.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.goldAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)} each',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(OrderDetailsModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppColor.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}', isDark),
            _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}', isDark),
            _buildSummaryRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}', isDark),
            Divider(height: 20, thickness: 1),
            _buildSummaryRow(
              'Total',
              '\$${order.total.toStringAsFixed(2)}',
              isDark,
              isBold: true,
              valueColor: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: AppColor.backgroundcolor2,
        child: Icon(
          Icons.image_outlined,
          size: 30,
          color: AppColor.grey,
        ),
      );
    }

    String finalImageUrl = imageUrl;
    if (!imageUrl.startsWith('http')) {
      finalImageUrl = '${AppLink.server}/upload/products/$imageUrl';
    }

    return Image.network(
      finalImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColor.backgroundcolor2,
          child: Icon(
            Icons.image_outlined,
            size: 30,
            color: AppColor.grey,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Future<void> _cancelOrder() async {
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
        final token = sharedPref.getString("token");
        var response = await _crud.postRequest(
          AppLink.cancelOrder,
          {
            "order_id": widget.orderId,
            "reason": "Cancelled by user from order details"
          },
          headers: {"Authorization": "Bearer $token"},
        );

        if (response != null && response["status"] == "success") {
          _showSuccessSnackBar('Order cancelled successfully');
          // Reload order details to reflect the change
          _loadOrderDetails();
        } else {
          _showErrorSnackBar(response?['message'] ?? 'Failed to cancel order');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to cancel order: ${e.toString()}');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return AppColor.goldAccent;
      case OrderStatus.onTheWay:
        return AppColor.primaryColor;
      case OrderStatus.delivered:
        return AppColor.successColor;
      case OrderStatus.cancelled:
        return AppColor.warningColor;
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'refunded':
        return 'Refunded';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return AppColor.successColor;
      case 'pending':
        return AppColor.goldAccent;
      case 'refunded':
        return AppColor.primaryColor;
      case 'failed':
        return AppColor.warningColor;
      default:
        return AppColor.grey;
    }
  }

  String _getPaymentMethodText(String? method) {
    switch (method?.toLowerCase()) {
      case 'credit_card':
        return 'Credit Card';
      case 'cash':
        return 'Cash on Delivery';
      case 'paypal':
        return 'PayPal';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method ?? 'Unknown';
    }
  }
}