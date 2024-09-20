import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  //! Build the customized AppBar widget
  @override
  Widget build(BuildContext context) {
    return AppBar(
      //! Set the icon theme for the AppBar
      iconTheme: IconThemeData(
        color: Theme.of(context)
            .colorScheme
            .secondary, // Set the icon color to black
        size: 30, // Set the icon size to 30
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Set the AppBar background color to match the scaffold's background color for a seamless look

      //! Set the logo as the AppBar title
      title: SvgPicture.asset(
        'lib/assets/logo.svg', // Load the SVG logo from assets
        height: 80, // Set the height of the logo
      ),
      centerTitle:
          false, // Align the title (logo) to the left (default behavior)

      //! Optional: Remove the AppBar's elevation (shadow) for a flat look
      elevation: 0.0,
    );
  }

  //! Override preferredSize to specify the height of the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  // kToolbarHeight is a predefined constant for the standard AppBar height
}
