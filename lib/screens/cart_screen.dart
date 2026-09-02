import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.userId = 5});

  final int userId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = CartService().getCartByUserId(widget.userId);
  }

  // ENHANCEMENT 1: reload the selected user's cart from the API.
  Future<void> _refreshCart() async {
    setState(() {
      _cartFuture = CartService().getCartByUserId(widget.userId);
    });
    await _cartFuture;
  }

  // ENHANCEMENT 1: retrieve full product data before opening the shared detail screen.
  Future<void> _openProduct(CartProduct cartProduct) async {
    try {
      final Product product = await ProductService().getProductById(cartProduct.id);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load that product right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cart>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(text: 'Could not load the cart.', fontSize: 15.sp),
                  SizedBox(height: 12.h),
                  FilledButton.icon(
                    onPressed: _refreshCart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final cart = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshCart,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              // ENHANCEMENT 1: summary for the single cart fetched by user id.
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Cart #${cart.id}',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        text: '${cart.totalQuantity} items from ${cart.totalProducts} products',
                        fontSize: 13.sp,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: 'Total', fontSize: 14.sp),
                          CustomText(
                            text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ...cart.products.map((product) => Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // ENHANCEMENT 1: cart items open the existing detail screen.
                      onTap: () => _openProduct(product),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                product.thumbnail,
                                height: 70.h,
                                width: 70.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(Icons.image, size: 28.sp),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text: 'Qty ${product.quantity} x \$${product.price.toStringAsFixed(2)} each',
                                    fontSize: 12.sp,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text: '\$${product.discountedTotal.toStringAsFixed(2)}',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 24.sp),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
