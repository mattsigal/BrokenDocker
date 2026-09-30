import 'package:flutter/material.dart';
import 'search_bar.dart';

class SearchBarWithSettings extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final Widget? trailing;

  const SearchBarWithSettings({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              hintText: hintText,
              onSearchChanged: onSearchChanged,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
