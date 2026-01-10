import 'package:flutter/material.dart';

/// Constants used throughout the settings feature
class SettingsConstants {
  // Padding and spacing
  static const double searchBarHorizontalPadding = 12.0;
  static const double searchBarVerticalPadding = 12.0;
  static const double listViewHorizontalPadding = 16.0;
  static const double listViewTopPadding = 16.0;
  static const double listViewBottomPadding = 16.0;
  static const double regionsListBottomPadding = 200.0;
  
  static const double cardBottomMargin = 12.0;
  static const double cardPadding = 12.0;
  static const double cardBorderRadius = 12.0;
  
  static const double searchFieldBorderRadius = 16.0;
  
  // Text
  static const String searchChampionsHint = 'Buscar campeões...';
  static const String searchRegionsHint = 'Buscar regiões...';
  
  // Styles
  static const Color searchFieldFillColor = Colors.white10;
  static const double titleFontSize = 18.0;
  static const FontWeight titleFontWeight = FontWeight.bold;
  
  // Overlay
  static const double overlayMaxHeight = 200.0;
  static const double overlayElevation = 4.0;
  static const double overlayBorderRadius = 8.0;
  static const EdgeInsets overlayItemPadding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 12,
  );
  
  // Genre Multi-select
  static const int maxSuggestions = 25;
  static const double genreChipSpacing = 6.0;
  static const String addGenreHint = 'Adicionar estilo...';
  
  // Music Selector
  static const int musicSearchDebounceMs = 200;
  static const int musicDropdownCloseDelayMs = 500;
  static const double musicDropdownMaxHeight = 250.0;
  static const String noMusicLabel = 'Nenhuma música';
  static const String musicFieldLabel = 'Música';
  
  // Image
  static const double championImageHeight = 100.0;
  static const double championImageBorderRadius = 12.0;
}
