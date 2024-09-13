import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  //! Widgets for different screen sizes
  final Widget mobileBody; // Widget to display on mobile devices
  final Widget tabletBody; // Widget to display on tablet devices
  final Widget desktopBody; // Widget to display on desktop devices

  //! Constructor for the ResponsiveLayout. Requires the mobile, tablet, and desktop widgets.
  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
  });

  //! Builds the layout based on the screen size.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //! If the screen width is less than 500 pixels, return the mobile layout.
        if (constraints.maxWidth < 500) {
          return mobileBody;

          //! If the screen width is between 500 and 1100 pixels, return the tablet layout.
        } else if (constraints.maxWidth < 1100) {
          return tabletBody;

          //! If the screen width is more than 1100 pixels, return the desktop layout.
        } else {
          return desktopBody;
        }
      },
    );
  }
}
