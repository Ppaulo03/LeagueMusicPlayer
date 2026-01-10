import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/core/models/champion_config.dart';
import 'package:league_music_player/features/settings/core/constants/settings_constants.dart';
import 'package:league_music_player/features/settings/view/components/loading_indicator.dart';
import 'package:league_music_player/features/settings/view/components/search_bar_widget.dart';
import 'package:league_music_player/features/settings/view/components/empty_state_widget.dart';
import 'package:league_music_player/features/settings/view/config_tiles/champion_config_tile.dart';
import 'package:league_music_player/features/settings/viewmodel/champions_viewmodel.dart';

/// Champions configuration tab with search functionality
class ChampionsTab extends StatefulWidget {
  const ChampionsTab({super.key});

  @override
  State<ChampionsTab> createState() => _ChampionsTabState();
}

class _ChampionsTabState extends State<ChampionsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChampionConfigViewModel>();

    if (viewModel.isLoading) {
      return const LoadingIndicator();
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildChampionsList(viewModel)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      hintText: SettingsConstants.searchChampionsHint,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildChampionsList(ChampionConfigViewModel viewModel) {
    final filteredChampions = _filterChampions(viewModel.champions);

    if (filteredChampions.isEmpty) {
      return EmptyStateWidget(
        message: _searchQuery.isEmpty
            ? 'Nenhum campeão disponível'
            : 'Nenhum campeão encontrado para "$_searchQuery"',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: SettingsConstants.listViewHorizontalPadding,
        vertical: SettingsConstants.listViewTopPadding,
      ),
      itemCount: filteredChampions.length,
      itemBuilder: (context, index) {
        return ChampionConfigTile(
          champion: filteredChampions[index],
          onSave: viewModel.saveAll,
        );
      },
    );
  }

  List<ChampionConfig> _filterChampions(List<ChampionConfig> champions) {
    if (_searchQuery.isEmpty) {
      return champions;
    }

    final query = _searchQuery.toLowerCase();
    return champions.where((champion) {
      return champion.name.toLowerCase().contains(query);
    }).toList();
  }
}
