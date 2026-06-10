enum TextTokenType {
  standard,
  italic,
  url,
}

class TextToken {
  const TextToken({
    required this.text,
    required this.type,
    this.url,
  });

  final String text;
  final TextTokenType type;
  final String? url;
}

class TextParser {
  /// Parses text into tokens of standard text, italic text, and URLs.
  /// Replaces '|' with ' • ' for easier reading.
  static List<TextToken> parse(String? rawText) {
    if (rawText == null || rawText.isEmpty) {
      return [];
    }

    final String text = rawText.replaceAll('|', ' • ');
    final List<TextToken> tokens = [];
    
    // Regex matches:
    // 1. HTTP/HTTPS URLs: https?://[^\s]+
    // 2. DOI URLs: doi:[^\s]+
    // 3. Italic text wrapped in underscores: _[^_]+_
    final RegExp exp = RegExp(r'(https?://[^\s]+)|(doi:[^\s]+)|(_[^_]+_)');
    
    int lastMatchEnd = 0;
    
    for (final match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        tokens.add(TextToken(
          text: text.substring(lastMatchEnd, match.start),
          type: TextTokenType.standard,
        ));
      }
      
      final String matchText = match.group(0)!;
      
      if (matchText.startsWith('http')) {
        tokens.add(TextToken(
          text: matchText,
          type: TextTokenType.url,
          url: matchText,
        ));
      } else if (matchText.startsWith('doi:')) {
        tokens.add(TextToken(
          text: matchText,
          type: TextTokenType.url,
          url: 'https://doi.org/${matchText.substring(4)}',
        ));
      } else if (matchText.startsWith('_') && matchText.endsWith('_')) {
        tokens.add(TextToken(
          text: matchText.substring(1, matchText.length - 1),
          type: TextTokenType.italic,
        ));
      }
      
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      tokens.add(TextToken(
        text: text.substring(lastMatchEnd),
        type: TextTokenType.standard,
      ));
    }
    
    return tokens;
  }
}
