import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/core/models/champion_config.dart';
import 'package:riot_spotify_flutter/features/settings/core/constants/settings_constants.dart';
import 'package:riot_spotify_flutter/features/settings/view/components/genre_multiselect.dart';
import 'package:riot_spotify_flutter/features/settings/view/components/music_selector.dart';

/// Configuration tile for individual champion settings
class ChampionConfigTile extends StatefulWidget {
  final ChampionConfig champion;
  final VoidCallback onSave;

  const ChampionConfigTile({
    super.key,
    required this.champion,
    required this.onSave,
  });

  @override
  State<ChampionConfigTile> createState() => _ChampionConfigTileState();
}

class _ChampionConfigTileState extends State<ChampionConfigTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: SettingsConstants.cardBottomMargin,
      ),
      child: Padding(
        padding: const EdgeInsets.all(SettingsConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 8),
            if (widget.champion.imageUrl.isNotEmpty) _buildImage(),
            if (widget.champion.imageUrl.isNotEmpty) const SizedBox(height: 8),
            _buildGenreSelector(),
            const SizedBox(height: 8),
            _buildMusicSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.champion.name,
      style: const TextStyle(
        fontWeight: SettingsConstants.titleFontWeight,
        fontSize: SettingsConstants.titleFontSize,
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        SettingsConstants.championImageBorderRadius,
      ),
      child: Image.network(
        widget.champion.imageUrl,
        height: SettingsConstants.championImageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: SettingsConstants.championImageHeight,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 48),
          );
        },
      ),
    );
  }

  Widget _buildGenreSelector() {
    return GenreMultiSelect(
      selectedGenres: _parseGenres(widget.champion.styles),
      onChanged: _handleGenresChanged,
    );
  }

  Widget _buildMusicSelector() {
    return MusicSelector(
      currentMusic: widget.champion.music,
      onMusicSelected: _handleMusicSelected,
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
    widget.champion.styles = newGenres.join(', ');
    widget.onSave();
  }

  void _handleMusicSelected(MusicData? music) {
    setState(() {
      widget.champion.music = music ?? MusicData.fromMap({});
    });
    widget.onSave();
  }
}
