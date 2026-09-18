import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'repositories/item_repository_api.dart';
import 'pages/home_page.dart';
import 'pages/checkout_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Marketplace',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(repository: ItemRepositoryApi()),
      routes: {
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}