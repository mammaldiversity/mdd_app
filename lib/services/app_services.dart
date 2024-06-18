import 'package:url_launcher/url_launcher.dart';

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
