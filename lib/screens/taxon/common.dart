import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/text_parser.dart';

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
    if (content == null || content!.isEmpty || content == 'NA') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          RichTextContent(content: content!, isItalic: isItalic),
        ],
      ),
    );
  }
}

class RichTextContent extends StatelessWidget {
  const RichTextContent({
    super.key,
    required this.content,
    this.isItalic = false,
  });

  final String content;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    final tokens = TextParser.parse(content);
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    
    final defaultStyle = isItalic
        ? baseStyle.apply(fontStyle: FontStyle.italic, letterSpacingDelta: 0.8)
        : baseStyle;

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        children: tokens.map((token) {
          switch (token.type) {
            case TextTokenType.standard:
              return TextSpan(
                text: token.text,
                style: defaultStyle,
              );
            case TextTokenType.italic:
              return TextSpan(
                text: token.text,
                style: defaultStyle.apply(
                  fontStyle: FontStyle.italic,
                  letterSpacingDelta: 0.8,
                ),
              );
            case TextTokenType.url:
              return TextSpan(
                text: token.text,
                style: defaultStyle.apply(
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (token.url != null) {
                      launchURL(token.url!);
                    }
                  },
              );
          }
        }).toList(),
      ),
    );
  }
}
