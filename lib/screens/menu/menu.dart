import 'package:flutter/material.dart';
import 'package:mdd/screens/menu/settings.dart';
import 'package:mdd/screens/menu/version.dart';

class MoreMenu extends StatefulWidget {
  const MoreMenu({super.key});

  @override
  State<MoreMenu> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        AppearanceSetting(),
        SizedBox(height: 32),
        AppVersionView(),
      ],
    );
  }
}