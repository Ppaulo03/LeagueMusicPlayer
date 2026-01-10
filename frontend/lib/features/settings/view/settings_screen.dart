import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riot_spotify_flutter/core/models/config_model.dart';
import 'package:riot_spotify_flutter/features/settings/viewmodel/config_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String title = 'Configurações';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigViewModel>().fetchConfig();
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SettingsScreen.title),
        centerTitle: true,
      ),
      body: Consumer<ConfigViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Update controllers when config is loaded
          if (viewModel.config != null) {
            _modelController.text = viewModel.config!.model ?? '';
            _apiKeyController.text = viewModel.config!.apiKey ?? '';
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Chave API',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Hide API key
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveConfig,
                  child: const Text('Salvar'),
                ),
                if (viewModel.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveConfig() {
    final model = _modelController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    final newConfig = ConfigModel(
      model: model.isEmpty ? null : model,
      apiKey: apiKey.isEmpty ? null : apiKey,
    );

    context.read<ConfigViewModel>().updateConfig(newConfig);
  }
}
