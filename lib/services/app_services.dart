import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

/// Directory name to store app data
const appDataDirName = 'mdd_data';

void launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

Future<Directory> getAppDir() async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final appDataDir = Directory(path.join(appDir.path, appDataDirName));
  if (!appDataDir.existsSync()) {
    await appDataDir.create();
  }
  return appDataDir;
}
