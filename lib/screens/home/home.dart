import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mammal Diversity Database'),
      ),
      body: Center(
        child: Image.asset(
          'assets/icons/favicon512.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
