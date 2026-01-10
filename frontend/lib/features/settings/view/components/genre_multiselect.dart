import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:league_music_player/features/settings/core/constants/settings_constants.dart';

/// Multi-select widget for choosing music genres with autocomplete
class GenreMultiSelect extends StatefulWidget {
  final List<String> selectedGenres;
  final Function(List<String>) onChanged;

  const GenreMultiSelect({
    super.key,
    required this.selectedGenres,
    required this.onChanged,
  });

  @override
  State<GenreMultiSelect> createState() => _GenreMultiSelectState();
}

class _GenreMultiSelectState extends State<GenreMultiSelect> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final GlobalKey _textFieldKey = GlobalKey();

  List<String> _allGenres = [];
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _loadGenres();
    _setupFocusListener();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  Future<void> _loadGenres() async {
    try {
      final content = await rootBundle.loadString('assets/genres.txt');
      _allGenres = content
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading genres: $e');
    }
  }

  void _updateSuggestions(String input) {
    final lowerInput = input.toLowerCase();
    _suggestions = _allGenres
        .where(
          (genre) =>
              genre.toLowerCase().contains(lowerInput) &&
              !widget.selectedGenres.contains(genre),
        )
        .take(SettingsConstants.maxSuggestions)
        .toList();
    _overlayEntry?.markNeedsBuild();
  }

  void _addGenre(String genre) {
    if (genre.isEmpty || widget.selectedGenres.contains(genre)) {
      return;
    }

    widget.selectedGenres.add(genre);
    widget.onChanged(widget.selectedGenres);
    _controller.clear();
    _updateSuggestions('');
    _focusNode.requestFocus();

    if (mounted) {
      setState(() {});
    }
  }

  void _removeGenre(String genre) {
    widget.selectedGenres.remove(genre);
    widget.onChanged(widget.selectedGenres);
    _updateSuggestions(_controller.text);

    if (mounted) {
      setState(() {});
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(offset, size),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay(Offset offset, Size size) {
    return Positioned(
      left: offset.dx,
      top: offset.dy + size.height + 4,
      width: size.width,
      child: Material(
        elevation: SettingsConstants.overlayElevation,
        borderRadius: BorderRadius.circular(
          SettingsConstants.overlayBorderRadius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: SettingsConstants.overlayMaxHeight,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return _buildSuggestionItem(_suggestions[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String genre) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _addGenre(genre),
      child: Container(
        width: double.infinity,
        padding: SettingsConstants.overlayItemPadding,
        child: Text(genre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: SettingsConstants.genreChipSpacing,
          runSpacing: SettingsConstants.genreChipSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [..._buildGenreChips(), _buildTextField(context)],
        ),
      ],
    );
  }

  List<Widget> _buildGenreChips() {
    return widget.selectedGenres.map((genre) {
      return InputChip(
        label: Text(genre),
        onDeleted: () => _removeGenre(genre),
      );
    }).toList();
  }

  Widget _buildTextField(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: TextField(
        key: _textFieldKey,
        controller: _controller,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          hintText: SettingsConstants.addGenreHint,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: _updateSuggestions,
        onSubmitted: (value) => _addGenre(value.trim()),
      ),
    );
  }
}
