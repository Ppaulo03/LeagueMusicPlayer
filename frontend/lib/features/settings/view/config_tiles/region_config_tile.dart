import 'package:flutter/material.dart';
import 'package:league_music_player/core/models/region_config.dart';
import 'package:league_music_player/features/settings/core/constants/settings_constants.dart';
import 'package:league_music_player/features/settings/view/components/genre_multiselect.dart';

/// Configuration tile for individual region settings
class RegionConfigTile extends StatelessWidget {
  final RegionConfig region;
  final VoidCallback onSave;

  const RegionConfigTile({
    super.key,
    required this.region,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SettingsConstants.cardBottomMargin),
      child: Padding(
        padding: const EdgeInsets.all(SettingsConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 8),
            _buildGenreSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      region.name,
      style: const TextStyle(
        fontWeight: SettingsConstants.titleFontWeight,
        fontSize: SettingsConstants.titleFontSize,
      ),
    );
  }

  Widget _buildGenreSelector() {
    return GenreMultiSelect(
      selectedGenres: _parseGenres(region.styles),
      onChanged: _handleGenresChanged,
    );
  }

  List<String> _parseGenres(String styles) {
    return styles
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _handleGenresChanged(List<String> newGenres) {
    region.styles = newGenres.join(', ');
    onSave();
  }
}
