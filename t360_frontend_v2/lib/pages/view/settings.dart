import 'package:flutter/cupertino.dart'; // For using CupertinoSwitch
import 'package:provider/provider.dart'; // For state management with Provider

import '../../components/my_tile.dart'; // Custom tile component
import '../../themes/theme_provider.dart'; // ThemeProvider for managing dark mode

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    //! Use LayoutBuilder to support responsive design
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            //! A custom tile to toggle Dark Mode with a CupertinoSwitch
            MyMainTile(
              title: 'Dark Mode',
              action: CupertinoSwitch(
                //! Fetch the current theme mode (Dark/Light) from the ThemeProvider
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                //! Toggle the theme mode when the switch is toggled
                onChanged: (value) =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme(),
              ),
            ),
          ],
        );
      },
    );
  }
}
