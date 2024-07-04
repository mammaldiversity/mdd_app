import 'package:flutter/material.dart';

class CommonSearchField extends StatefulWidget {
  const CommonSearchField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<CommonSearchField> createState() => _CommonSearchFieldState();
}

class _CommonSearchFieldState extends State<CommonSearchField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        focusNode: widget.focusNode,
        controller: widget.controller,
        leading: const Icon(Icons.search),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onSurface.withAlpha(32),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevation: const WidgetStatePropertyAll(0), // Convert int to double
        hintText: 'Search database',
        trailing: [
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: widget.onClear,
            ),
        ],
        onChanged: widget.onChanged,
      ),
    );
  }
}
