import 'package:material_ui/material_ui.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
    this.expandText = false,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  final bool expandText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final marker = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isSquare ? BorderRadius.circular(3) : null,
        color: color,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
    );
    final label = Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor ?? colorScheme.onSurface,
      ),
    );

    return Row(
      mainAxisSize: expandText ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        marker,
        const SizedBox(width: 6),
        if (expandText) Expanded(child: label) else label,
      ],
    );
  }
}
