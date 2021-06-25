import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final IconData? leftIcon;
  final bool showMenuIcon;
  final VoidCallback? leftIconClicked;
  final menuIconClicked;
  final Iterable<String>? menuOptions;
  final bool automaticallyImplyLeading;
  final bool? transparent;
  final bool dark;
  final bool? focused;
  final bool centerTitle;
  final double? height;
  final double elevation;
  CustomAppBar(
      {this.titleText = "Beauty-FYI",
      this.leftIcon,
      required this.showMenuIcon,
      this.leftIconClicked,
      this.menuIconClicked,
      this.menuOptions,
      this.automaticallyImplyLeading = true,
      this.transparent,
      this.dark = false,
      this.focused,
      this.centerTitle = true,
      this.height,
      this.elevation = 10});
  @override
  Size get preferredSize => const Size.fromHeight(45);
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: this.focused! ? 1 : 0.3,
        duration: Duration(milliseconds: 300),
        child: new AppBar(
          brightness: this.dark ? Brightness.dark : Brightness.light,
          backgroundColor: this.dark
              ? Colors.black
              : this.transparent!
                  ? Colors.transparent
                  : Colors.black,
          elevation: this.transparent! ? 0 : this.elevation,
          automaticallyImplyLeading: automaticallyImplyLeading,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: this.transparent!
                  ? null
                  : this.dark
                      ? null
                      : LinearGradient(
                          colors: [
                            // colorStyles['dark_purple']!,
                            // colorStyles['light_purple']!,
                            colorStyles['blue']!,
                            colorStyles['blue']!,
                            // colorStyles['green']!
                          ],
                          // stops: [0.1, 1.0, 0.5],
                        ),
            ),
          ),
          centerTitle: centerTitle,
          title: Text(titleText!, style: TextStyle(color: Colors.white)),
          leading: GestureDetector(
            onTap: () => leftIconClicked!(),
            child: Icon(
              leftIcon, // add custom icons also
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String val) => menuIconClicked(val),
              itemBuilder: (BuildContext context) {
                return menuOptions!.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ));
  }
}
