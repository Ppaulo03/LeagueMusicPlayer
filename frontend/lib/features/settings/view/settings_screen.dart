import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/core/models/config_model.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:window_manager/window_manager.dart';
import 'package:league_music_player/core/widgets/window_buttons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String title = 'Configurações';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  String? _selectedModel;

  final List<String> _groqModels = [
    'llama-3.3-70b-versatile',
    'llama-3.1-8b-instant',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigViewModel>().fetchConfig();
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: DragToMoveArea(
        child: PageHeader(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(FluentIcons.back, size: 18.0),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(SettingsScreen.title),

          // PROPRIEDADE MÁGICA DO FLUENT UI:
          // Coloca widgets no canto direito do header
          commandBar: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seus botões de janela aqui
              WindowButtons(),
            ],
          ),
        ),
      ),
      children: [
        Consumer<ConfigViewModel>(
          builder: (context, viewModel, child) {
            // Loading State
            if (viewModel.isLoading) {
              return const SizedBox(
                height: 300,
                child: Center(child: ProgressRing()),
              );
            }

            // Lógica de preenchimento inicial (Mantida do seu código original)
            if (viewModel.config != null &&
                _selectedModel == null &&
                _apiKeyController.text.isEmpty) {
              _apiKeyController.text = viewModel.config!.apiKey ?? '';

              final configModel = viewModel.config!.model;
              if (configModel != null && _groqModels.contains(configModel)) {
                _selectedModel = configModel;
              } else {
                _selectedModel = 'llama-3.3-70b-versatile';
              }
            }

            // Reset em caso de erro
            if (viewModel.hasError && _apiKeyController.text.isEmpty) {
              _apiKeyController.text = viewModel.config?.apiKey ?? '';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SELEÇÃO DE MODELO (ComboBox) ---
                InfoLabel(
                  label: 'Modelo IA (Groq)',
                  child: ComboBox<String>(
                    placeholder: const Text('Selecione um modelo'),
                    isExpanded: true, // Ocupa a largura total
                    value: _selectedModel,
                    items: _groqModels.map((e) {
                      return ComboBoxItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedModel = value);
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Texto de ajuda pequeno (estilo Caption)
                Text(
                  'O modelo que será usado para gerar a playlist.',
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                    color: Colors.grey[100].withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 20),

                // --- API KEY (PasswordBox) ---
                InfoLabel(
                  label: 'Chave API',
                  child: PasswordBox(
                    controller: _apiKeyController,
                    placeholder: 'Insira sua chave API aqui (gsk_...)',
                    revealMode: PasswordRevealMode.peek,
                  ),
                ),

                const SizedBox(height: 16),

                // --- INFO BAR (Link para obter chave) ---
                InfoBar(
                  title: const Text('Necessário Chave API'),
                  content: const Text(
                    'Você precisa gerar uma chave gratuita no console da Groq.',
                  ),
                  severity: InfoBarSeverity.info,
                  isLong: true,
                  action: Button(
                    child: const Text('Obter Chave'),
                    onPressed: () async {
                      final Uri url = Uri.parse('https://console.groq.com/');
                      if (!await launchUrl(url)) {
                        if (context.mounted) {
                          displayInfoBar(
                            context,
                            builder: (context, close) {
                              return InfoBar(
                                title: const Text('Erro'),
                                content: const Text(
                                  'Não foi possível abrir o link',
                                ),
                                severity: InfoBarSeverity.error,
                                onClose: close,
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // --- BOTÃO SALVAR ---
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _saveConfig(viewModel),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: ProgressRing(
                              strokeWidth: 2.5,
                              activeColor: Colors.white,
                            ),
                          )
                        : const Text('Salvar Alterações'),
                  ),
                ),

                // --- MENSAGENS DE ERRO/SUCESSO ---
                if (viewModel.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: InfoBar(
                      title: const Text('Erro ao salvar'),
                      content: Text(viewModel.error!),
                      severity: InfoBarSeverity.error,
                    ),
                  ),

                if (viewModel.hasSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: InfoBar(
                      title: const Text('Sucesso'),
                      content: Text(viewModel.successMessage!),
                      severity: InfoBarSeverity.success,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _saveConfig(ConfigViewModel viewModel) {
    final model = _selectedModel;
    final apiKey = _apiKeyController.text.trim();

    final newConfig = ConfigModel(
      model: model,
      apiKey: apiKey.isEmpty ? null : apiKey,
    );

    if (viewModel.config != null &&
        viewModel.config!.model == newConfig.model &&
        viewModel.config!.apiKey == newConfig.apiKey) {
      return;
    }

    context.read<ConfigViewModel>().updateConfig(newConfig);
  }
}
