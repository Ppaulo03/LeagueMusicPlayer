import 'package:fluent_ui/fluent_ui.dart';

class GradientBackground extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 1. GARANTIA DE CORES
    // Se a lista vier vazia ou curta, completamos com segurança
    final safeColors = List<Color>.from(colors);
    if (safeColors.isEmpty) safeColors.add(const Color(0xFF091428)); // Azul LoL
    if (safeColors.length < 2) safeColors.add(safeColors[0]);
    if (safeColors.length < 3) safeColors.add(safeColors[1]);

    final baseColor = safeColors[0];
    final ambientColor = safeColors[1];
    final accentColor = safeColors[2];

    return Container(
      color: baseColor, // Fundo sólido para garantir contraste
      child: Stack(
        children: [
          // 2. LUZ AMBIENTE (Topo Esquerdo)
          // Muito sutil, espalhada, para tirar o "preto chapado"
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.3,
                colors: [
                  ambientColor.withValues(alpha: 0.15), // Bem fraquinho (15%)
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 3. LUZ DE DESTAQUE (Baixo Direito)
          // Um pouco mais forte e menor, para ser o "ponto de interesse"
          AnimatedContainer(
            duration: const Duration(milliseconds: 1200),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.0,
                colors: [
                  accentColor.withValues(
                    alpha: 0.25,
                  ), // Um pouco mais visível (25%)
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 4. REFLEXO CENTRAL (Opcional - "Glass shine")
          // Um brilho diagonal muito leve cruzando a tela para dar textura
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.02),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 5. VINHETA (Escurece as bordas)
          // Isso é CRUCIAL para não parecer que as cores estão vazando
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0, // Foco no centro
                colors: [
                  Colors.transparent,
                  baseColor.withValues(
                    alpha: 0.8,
                  ), // Escurece as bordas com a cor base
                ],
                stops: const [0.6, 1.0], // Só afeta os cantos extremos
              ),
            ),
          ),

          // 6. CONTEÚDO
          child,
        ],
      ),
    );
  }
}
