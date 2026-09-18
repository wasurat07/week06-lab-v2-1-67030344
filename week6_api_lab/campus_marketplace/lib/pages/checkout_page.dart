import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตะกร้าสินค้า')),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('ไม่มีสินค้าในตะกร้า'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text('\$${item.price}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ราคารวม: \$${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () {
                        cart.removeAll();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('สั่งซื้อเรียบร้อย!')),
                        );
                      },
                      child: const Text('ชำระเงิน'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}