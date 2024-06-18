import 'package:flutter/material.dart';

class DataLoadingMessages extends StatelessWidget {
  const DataLoadingMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              )),
          Text('Retrieving and parsing MDD data... ⏳'),
          Text(
            'These may take several minutes. '
            'We are making sure you can access the data offline'
            ' from anywhere in the world. 🌍',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
