import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riot_spotify_flutter/features/home/core/constants/home_constants.dart';
import 'package:riot_spotify_flutter/features/settings/view/settings_screen.dart'
    as settings_ref;
import 'package:riot_spotify_flutter/features/settings/viewmodel/config_viewmodel.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Color> gradientColors;

  const HomeAppBar({super.key, required this.gradientColors});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        HomeConstants.appBarTitle,
        style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => ConfigViewModel(),
                  child: const settings_ref.SettingsScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
