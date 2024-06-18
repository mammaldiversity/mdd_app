import 'package:flutter/material.dart';
import 'package:mdd/screens/menu/settings.dart';
import 'package:mdd/screens/menu/version.dart';
import 'package:mdd/services/app_services.dart';

const mddWebsiteUrl = 'https://mammaldiversity.org';

class MoreMenu extends StatefulWidget {
  const MoreMenu({super.key});

  @override
  State<MoreMenu> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListView(
        children: <Widget>[
          const MDDWebTile(),
          const SizedBox(height: 16),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(thickness: 2.4),
          const AppearanceSetting(),
          const SizedBox(height: 32),
          const AppVersionView(),
        ],
      ),
    );
  }
}

class MDDWebTile extends StatelessWidget {
  const MDDWebTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: Theme.of(context).colorScheme.onSurface.withAlpha(16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        leading: const Icon(Icons.public),
        title: const Text('Visit MDD website'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          launchURL(mddWebsiteUrl);
        });
  }
}
