class RegionConfig {
  final String name;
  String styles;

  RegionConfig({required this.name, required this.styles});

  factory RegionConfig.fromMap(String name, styles) {
    return RegionConfig(name: name, styles: styles ?? '');
  }
}
