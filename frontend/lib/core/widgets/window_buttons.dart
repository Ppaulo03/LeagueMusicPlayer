import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 32,
      child: WindowCaption(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        title: const SizedBox.shrink(),
      ),
    );
  }
}
