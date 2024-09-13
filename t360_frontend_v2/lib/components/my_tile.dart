import 'package:flutter/material.dart';

class MyMainTile extends StatefulWidget {
  final String title; // Title text for the ListTile
  final Widget action; // Widget for the trailing action (e.g., icon, button)

  const MyMainTile({super.key, required this.title, required this.action});

  @override
  State<MyMainTile> createState() => _MyMainTileState();
}

class _MyMainTileState extends State<MyMainTile> {
  @override
  Widget build(BuildContext context) {
    //! Build method for the ListTile widget
    return ListTile(
      //! Set the title's text style from the current theme
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,

      //! Set the shape of the ListTile (e.g., rounded corners) from the theme
      shape: Theme.of(context).listTileTheme.shape,

      //! Set the background color of the ListTile from the theme
      tileColor: Theme.of(context).listTileTheme.tileColor,

      //! Display the title text passed from the widget's parameters
      title: Text(widget.title),

      //! Display the trailing widget (e.g., an action button or icon) passed from the widget's parameters
      trailing: widget.action,
    );
  }
}
