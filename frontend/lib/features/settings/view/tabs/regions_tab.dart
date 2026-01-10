import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riot_spotify_flutter/core/models/region_config.dart';
import 'package:riot_spotify_flutter/features/settings/core/constants/settings_constants.dart';
import 'package:riot_spotify_flutter/features/settings/view/components/loading_indicator.dart';
import 'package:riot_spotify_flutter/features/settings/view/components/search_bar_widget.dart';
import 'package:riot_spotify_flutter/features/settings/view/components/empty_state_widget.dart';
import 'package:riot_spotify_flutter/features/settings/view/config_tiles/region_config_tile.dart';
import 'package:riot_spotify_flutter/features/settings/viewmodel/regions_viewmodel.dart';

/// Regions configuration tab with search functionality
class RegionsTab extends StatefulWidget {
  const RegionsTab({super.key});

  @override
  State<RegionsTab> createState() => _RegionsTabState();
}

class _RegionsTabState extends State<RegionsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegionConfigViewModel>();

    if (viewModel.isLoading) {
      return const LoadingIndicator();
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildRegionsList(viewModel),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      hintText: SettingsConstants.searchRegionsHint,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildRegionsList(RegionConfigViewModel viewModel) {
    final filteredRegions = _filterRegions(viewModel.regions);

    if (filteredRegions.isEmpty) {
      return EmptyStateWidget(
        message: _searchQuery.isEmpty
            ? 'Nenhuma região disponível'
            : 'Nenhuma região encontrada para "$_searchQuery"',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        SettingsConstants.listViewHorizontalPadding,
        SettingsConstants.listViewTopPadding,
        SettingsConstants.listViewHorizontalPadding,
        SettingsConstants.regionsListBottomPadding,
      ),
      itemCount: filteredRegions.length,
      itemBuilder: (context, index) {
        return RegionConfigTile(
          region: filteredRegions[index],
          onSave: viewModel.saveRegions,
        );
      },
    );
  }

  List<RegionConfig> _filterRegions(List<RegionConfig> regions) {
    if (_searchQuery.isEmpty) {
      return regions;
    }

    final query = _searchQuery.toLowerCase();
    return regions.where((region) {
      return region.name.toLowerCase().contains(query);
    }).toList();
  }
}
