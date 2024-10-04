import 'package:flutter/material.dart';
import 'package:mdd/services/app_services.dart';

class ContentText extends StatelessWidget {
  const ContentText({
    super.key,
    required this.title,
    required this.content,
    this.isUrl = false,
    this.isItalic = false,
  });

  final String title;
  final String? content;
  final bool isUrl;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return content != null && content!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                isUrl
                    ? UrlText(content: content)
                    : StandardText(content: content, isItalic: isItalic),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class UrlText extends StatelessWidget {
  const UrlText({super.key, required this.content});

  final String? content;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(
        content ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.apply(
              decoration: TextDecoration.underline,
            ),
        textAlign: TextAlign.center,
      ),
      onTap: () {
        launchURL(content ?? '');
      },
    );
  }
}

class StandardText extends StatelessWidget {
  const StandardText({
    super.key,
    required this.content,
    required this.isItalic,
  });

  final String? content;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return Text(
      _cleanText(content),
      style: isItalic
          ? Theme.of(context).textTheme.bodyMedium?.apply(
                fontStyle: FontStyle.italic,
                letterSpacingDelta: 0.8,
              )
          : Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  String _cleanText(String? text) {
    if (text == null) {
      return '';
    }
    // We use middle dot as a separator for
    // easier reading in the database
    return text.replaceAll('|', ' • ');
  }
}
