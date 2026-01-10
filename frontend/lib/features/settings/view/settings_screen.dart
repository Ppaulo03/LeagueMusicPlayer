import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/core/models/config_model.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

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

          // Reset controllers to config values when there's an error
          if (viewModel.hasError) {
            _modelController.text = viewModel.config?.model ?? '';
            _apiKeyController.text = viewModel.config?.apiKey ?? '';
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'Obtenha sua chave API no site do Groq:\n',
                              ),
                              TextSpan(
                                text: 'https://console.groq.com/',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                // Torna o link clicável
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final Uri url = Uri.parse(
                                      'https://console.groq.com/',
                                    );
                                    if (!await launchUrl(url)) {
                                      // Opcional: Mostrar erro se não conseguir abrir
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Não foi possível abrir o link',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _saveConfig(viewModel),
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
                if (viewModel.hasSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.successMessage!,
                      style: const TextStyle(color: Colors.green),
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

  void _saveConfig(ConfigViewModel viewModel) {
    final model = _modelController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    final newConfig = ConfigModel(
      model: model.isEmpty ? null : model,
      apiKey: apiKey.isEmpty ? null : apiKey,
    );

    // Check if there are changes
    if (viewModel.config != null &&
        viewModel.config!.model == newConfig.model &&
        viewModel.config!.apiKey == newConfig.apiKey) {
      // No changes, do nothing
      return;
    }

    context.read<ConfigViewModel>().updateConfig(newConfig);
  }
}
