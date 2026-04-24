import 'package:flutter/material.dart';

void main() {
  runApp(const ShopPlusWalletApp());
}

class ShopPlusWalletApp extends StatelessWidget {
  const ShopPlusWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ShopPlus Wallet',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('ShopPlus Wallet')),
      ),
    );
  }
}
