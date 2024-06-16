import 'package:flutter/material.dart';

class FavoriteSpecies extends StatefulWidget {
  const FavoriteSpecies({super.key});

  @override
  State<FavoriteSpecies> createState() => _SearchSpeciesState();
}

class _SearchSpeciesState extends State<FavoriteSpecies> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Species'),
    );
  }
}
