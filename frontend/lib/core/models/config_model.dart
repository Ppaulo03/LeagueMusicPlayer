class ConfigModel {
  final String? model;
  final String? apiKey;

  ConfigModel({this.model, this.apiKey});

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      model: json['model'] as String?,
      apiKey: json['api_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'model': model, 'api_key': apiKey};
  }

  ConfigModel copyWith({String? model, String? apiKey}) {
    return ConfigModel(
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
