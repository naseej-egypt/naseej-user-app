import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/models/cart_item.dart';
import 'package:naseej/core/services/cart_service.dart';
import 'package:naseej/pages/explore_page.dart';
import 'checkout_page.dart';
import 'main_container.dart';

class CartPage extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const CartPage({Key? key, this.onCartUpdated}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  CartSummary? cartSummary;
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      isLoading = true;
    });

    var result = await _cartService.getCart();

    if (result['success'] == true && mounted) {
      var data = result['data'];

      // Parse cart items
      List<CartItem> items = [];
      if (data['cart_items'] is List) {
        for (var item in data['cart_items']) {
          items.add(CartItem.fromJson(item));
        }
      }

      // Parse summary
      CartSummary? summary;
      if (data['summary'] != null) {
        summary = CartSummary.fromJson(data['summary']);
      }

      setState(() {
        cartItems = items;
        cartSummary = summary;
        isLoading = false;
      });

      // Notify parent about cart update for badge count
      widget.onCartUpdated?.call();
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar(result['message'] ?? 'Failed to load cart');
      }
    }
  }

  Future<void> _updateQuantity(String cartId, int newQuantity) async {
    if (isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    // If quantity becomes 0, remove the item instead of updating
    if (newQuantity < 1) {
      await _removeItem(cartId);
      return;
    }

    var result = await _cartService.updateCartItem(
      cartId: cartId,
      quantity: newQuantity,
    );

    if (result['success'] == true && mounted) {
      // Reload cart to get updated data
      await _loadCart();
    } else if (mounted) {
      _showErrorSnackBar(result['message'] ?? 'Failed to update quantity');
    }

    if (mounted) {
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future<void> _removeItem(String cartId) async {
    var result = await _cartService.removeFromCart(cartId);

    if (result['success'] == true && mounted) {
      // Remove item from local list immediately for better UX
      setState(() {
        cartItems.removeWhere((item) => item.cartId == cartId);
      });

      // Reload cart to get updated summary
      await _loadCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: AppColor.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showErrorSnackBar(result['message'] ?? 'Failed to remove item');
    }
  }

  Future<void> _clearCart() async {
    var result = await _cartService.clearCart();

    if (result['success'] == true && mounted) {
      setState(() {
        cartItems.clear();
        cartSummary = null;
      });

      // Notify parent about cart update
      widget.onCartUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart cleared successfully'),
          backgroundColor: AppColor.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showErrorSnackBar(result['message'] ?? 'Failed to clear cart');
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

  void _navigateToCheckout() {
    if (cartItems.isEmpty) {
      _showErrorSnackBar('Your cart is empty');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: cartItems,
          cartSummary: cartSummary!,
        ),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Cart?', style: TextStyle(color: AppColor.primaryColor)),
        content: Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.warningColor,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _navigateToExplore() {
    // Navigate to explore page (index 0 in bottom nav)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainContainer(initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (cartItems.isNotEmpty && !isLoading)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _showClearCartDialog,
            ),
        ],
      ),
      body: isLoading
          ? _buildLoading()
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(isDark),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColor.primaryColor),
          SizedBox(height: 16),
          Text('Loading your cart...'),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
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
                Icons.shopping_cart_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Add beautiful carpets to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToExplore,
              icon: Icon(Icons.shopping_bag),
              label: Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(bool isDark) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(cartItems[index], isDark);
            },
          ),
        ),

        // Summary Card
        if (cartSummary != null)
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF2C2520) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSummaryRow('Subtotal', cartSummary!.subtotal),
                    if (cartSummary!.shipping > 0)
                      _buildSummaryRow('Shipping', cartSummary!.shipping),
                    _buildSummaryRow('Tax', cartSummary!.tax),

                    Divider(height: 16, thickness: 1),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Text(
                          '\$${cartSummary!.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _navigateToCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_forward, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Continue to Checkout',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Free shipping hint
                    if (cartSummary!.shipping > 0) ...[
                      SizedBox(height: 8),
                      Text(
                        'Add \$${cartSummary!.amountForFreeShipping.toStringAsFixed(2)} more for free shipping!',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.goldAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (cartSummary!.subtotal >= cartSummary!.freeShippingThreshold) ...[
                      SizedBox(height: 8),
                      Text(
                        'You got free shipping!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.goldAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.backgroundcolor2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.images.isNotEmpty
                    ? Image.network(
                  item.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImagePlaceholder();
                  },
                )
                    : _buildImagePlaceholder(),
              ),
            ),
            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.productName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (item.colors.isNotEmpty || item.sizes.isNotEmpty)
                    Text(
                      '${item.sizes.isNotEmpty ? item.sizes.first : ''}${item.sizes.isNotEmpty && item.colors.isNotEmpty ? ' • ' : ''}${item.colors.isNotEmpty ? item.colors.first : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '\$${item.finalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: isUpdating ? null : () => _updateQuantity(item.cartId, item.quantity - 1),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isUpdating
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: isUpdating ? null : () => _updateQuantity(item.cartId, item.quantity + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!item.isAvailable)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Not available',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.warningColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColor.warningColor, size: 20),
              onPressed: isUpdating ? null : () => _removeItem(item.cartId),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
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

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: onPressed == null ? AppColor.grey : AppColor.primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.grey,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }
}