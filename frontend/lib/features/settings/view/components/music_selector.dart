import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/core/models/champion_config.dart';
import 'package:riot_spotify_flutter/features/settings/core/constants/settings_constants.dart';
import 'package:riot_spotify_flutter/services/apis/settings_api.dart';

/// Music selector widget with search and autocomplete functionality
class MusicSelector extends StatefulWidget {
  final MusicData? currentMusic;
  final void Function(MusicData?) onMusicSelected;

  const MusicSelector({
    super.key,
    this.currentMusic,
    required this.onMusicSelected,
  });

  @override
  State<MusicSelector> createState() => _MusicSelectorState();
}

class _MusicSelectorState extends State<MusicSelector> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final _apiService = SettingsApi();

  Timer? _debounce;
  List<MusicData> _suggestions = [];
  bool _isLoading = false;
  bool _showDropdown = false;
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _initializeController();
    _setupFocusListener();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeController() {
    if (widget.currentMusic != null) {
      _controller.text = widget.currentMusic!.asString();
    }
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _handleFocusGained();
      } else {
        _handleFocusLost();
      }
    });
  }

  void _handleFocusGained() {
    if (widget.currentMusic != null) {
      _controller.value = TextEditingValue(
        text: widget.currentMusic!.name,
        selection: TextSelection.fromPosition(
          TextPosition(offset: widget.currentMusic!.name.length),
        ),
      );
    }
    _onSearchChanged(_controller.text);
    setState(() => _showDropdown = true);
  }

  void _handleFocusLost() {
    Future.delayed(
      const Duration(milliseconds: SettingsConstants.musicDropdownCloseDelayMs),
      () {
        if (!mounted || _hasSelected) return;

        _resetControllerToCurrentMusic();
        setState(() => _showDropdown = false);
      },
    );
  }

  void _resetControllerToCurrentMusic() {
    if (widget.currentMusic != null) {
      _controller.value = TextEditingValue(
        text: widget.currentMusic!.asString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: widget.currentMusic!.asString().length),
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: SettingsConstants.musicSearchDebounceMs),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    if (!mounted || !_focusNode.hasFocus) return;

    setState(() => _isLoading = true);

    try {
      final results = await _apiService.getMusicData(query);
      
      if (!mounted || !_focusNode.hasFocus) return;

      setState(() {
        _suggestions = results;
        _showDropdown = results.isNotEmpty;
      });
    } catch (e) {
      if (!mounted || !_focusNode.hasFocus) return;

      setState(() {
        _suggestions = [];
      });
      
      debugPrint('Error searching music: $e');
    } finally {
      if (mounted && _focusNode.hasFocus) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectMusic(MusicData? music) {
    _hasSelected = true;

    if (music == null) {
      _controller.clear();
    } else {
      _controller.text = music.asString();
    }

    widget.onMusicSelected(music);

    setState(() {
      _showDropdown = false;
      _suggestions.clear();
    });

    FocusScope.of(context).unfocus();
    Future.delayed(Duration.zero, () => _hasSelected = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(),
        if (_showDropdown) _buildDropdown(),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      focusNode: _focusNode,
      controller: _controller,
      decoration: InputDecoration(
        labelText: SettingsConstants.musicFieldLabel,
        suffixIcon: _buildSuffixIcon(),
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildSuffixIcon() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return const Icon(Icons.music_note);
  }

  Widget _buildDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: SettingsConstants.musicDropdownMaxHeight,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: _buildDropdownItems(),
        ),
      ),
    );
  }

  List<Widget> _buildDropdownItems() {
    return [
      _buildNoMusicOption(),
      ..._suggestions.map(_buildMusicOption),
    ];
  }

  Widget _buildNoMusicOption() {
    return ListTile(
      dense: true,
      title: const Text(
        SettingsConstants.noMusicLabel,
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () => _selectMusic(null),
    );
  }

  Widget _buildMusicOption(MusicData music) {
    return ListTile(
      dense: true,
      title: Text(music.name),
      subtitle: Text(music.artist),
      onTap: () => _selectMusic(music),
    );
  }
}
