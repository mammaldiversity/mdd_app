import 'package:flutter/material.dart';

class MddStats extends StatefulWidget {
  const MddStats({super.key});

  @override
  State<MddStats> createState() => _SearchSpeciesState();
}

class _SearchSpeciesState extends State<MddStats> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Species'),
    );
  }
}
