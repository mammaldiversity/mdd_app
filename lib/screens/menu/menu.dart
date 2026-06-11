import 'package:flutter/material.dart';
import 'package:mdd/screens/menu/settings.dart';
import 'package:mdd/screens/menu/version.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/essential_url.dart';
import 'package:mdd/services/system.dart';

class MoreMenu extends StatefulWidget {
  const MoreMenu({super.key});

  @override
  State<MoreMenu> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 8),
          const SettingSection(),
          const SizedBox(height: 16),
          const EssentialUrls(),
          const SizedBox(height: 16),
          const AppVersionView(),
        ],
      ),
    );
  }
}

class SettingSection extends StatelessWidget {
  const SettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = getPlatformType() == PlatformType.desktop;
    return CommonCard(
      title: 'Settings',
      child: Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          child: Column(
            children: [
              const AppearanceSetting(),
              const SizedBox(height: 16),
              const DisplaySetting(),
              const SizedBox(height: 16),
              Visibility(
                // Show only on desktop because mobile database
                // Cannot be changed
                visible: isDesktop,
                child: const DatabaseLocationSetting(),
              ),
            ],
          )),
    );
  }
}

class EssentialUrls extends StatelessWidget {
  const EssentialUrls({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: 'Essential URLs',
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const UrlTile(
                title: 'American Society of Mammalogists (ASM)',
                url: asmUrl,
                icon: Icons.public,
              ),
              const SizedBox(height: 8),
              const UrlTile(
                title: 'The Mammal Diversity Database (MDD)',
                url: mddWebsiteUrl,
              ),
              const SizedBox(height: 8),
              const UrlTile(
                title: 'Mammal Image Library (MIL)',
                url: milUrl,
                icon: Icons.image,
              ),
              const SizedBox(height: 8),
              const UrlTile(
                title: 'MDD on GitHub',
                url: mddGitHub,
                icon: Icons.code,
              ),
              const SizedBox(height: 8),
              const UrlTile(
                title: 'MDD App Source Code',
                url: appSourceCode,
                icon: Icons.code,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UrlTile extends StatelessWidget {
  const UrlTile({super.key, required this.title, required this.url, this.icon});

  final String title;
  final String url;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: Theme.of(context).colorScheme.onSurface.withAlpha(16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        leading: Icon(icon ?? Icons.public),
        title: Text(title),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          launchURL(url);
        });
  }
}
