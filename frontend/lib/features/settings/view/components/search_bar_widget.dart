import 'package:flutter/material.dart';
import 'package:league_music_player/features/settings/core/constants/settings_constants.dart';

/// Reusable search bar component for filtering lists
class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final EdgeInsets? padding;

  const SearchBarWidget({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: SettingsConstants.searchBarHorizontalPadding,
            vertical: SettingsConstants.searchBarVerticalPadding,
          ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: SettingsConstants.searchFieldFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              SettingsConstants.searchFieldBorderRadius,
            ),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
