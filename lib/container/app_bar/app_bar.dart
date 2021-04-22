import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final IconData leftIcon;
  final IconData rightIcon;
  final VoidCallback leftIconClicked;
  final VoidCallback rightIconClicked;
  final bool automaticallyImplyLeading;
  final bool transparent;
  final bool focused;
  final bool centerTitle;
  CustomAppBar(
      {this.titleText = "Beauty-FYI",
      this.leftIcon,
      this.rightIcon,
      this.leftIconClicked,
      this.rightIconClicked,
      this.automaticallyImplyLeading = true,
      this.transparent,
      this.focused,
      this.centerTitle = true});
  @override
  Size get preferredSize => const Size.fromHeight(55);
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: this.focused ? 1 : 0.3,
        duration: Duration(milliseconds: 300),
        child: new AppBar(
          backgroundColor: this.transparent ? Colors.transparent : Colors.red,
          elevation: this.transparent ? 0 : 10,
          automaticallyImplyLeading: automaticallyImplyLeading,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: this.transparent
                  ? null
                  : LinearGradient(
                      colors: [
                        colorStyles['dark_purple'],
                        colorStyles['light_purple'],
                        colorStyles['blue'],
                        colorStyles['green']
                      ],
                      // stops: [0.1, 1.0, 0.5],
                    ),
            ),
          ),
          centerTitle: centerTitle,
          title: Text(titleText, style: TextStyle(color: Colors.white)),
          leading: GestureDetector(
            onTap: () => leftIconClicked(),
            child: Icon(
              leftIcon, // add custom icons also
            ),
          ),
          actions: [
            GestureDetector(
                onTap: () => rightIconClicked(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Icon(
                    rightIcon,
                    color: Colors.white,
                  ),
                )),
          ],
        ));
  }
}
