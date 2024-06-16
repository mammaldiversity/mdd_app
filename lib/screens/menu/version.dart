import 'package:flutter/material.dart';
import 'package:mdd/services/system.dart';

class AppVersionView extends StatelessWidget {
  const AppVersionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'App version',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const VersionText(),
      ],
    );
  }
}

class VersionText extends StatelessWidget {
  const VersionText({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getVersion(),
      builder: (BuildContext context, AsyncSnapshot<AppVersion> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Text(
              '${snapshot.data?.version}+${snapshot.data?.buildNumber}',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          } else if (snapshot.hasError) {
            return Text(
              'Failed to load version information. Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Future<AppVersion> _getVersion() async {
    AppVersion appVersion = AppVersion.empty();
    appVersion.getVersions();
    return appVersion;
  }
}
