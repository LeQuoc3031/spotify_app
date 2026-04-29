import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? action;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool searchIcon;
  final bool isBack;
  const BasicAppbar({
    super.key,
    this.searchIcon = false,
    this.isBack = false,
    this.title,
    this.backgroundColor,
    this.action,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      actions: actions ?? [action ?? Container()],
      leading: searchIcon
          ? Center(
              child: SvgPicture.asset(
                AppVectors.searchIcon,
                colorFilter: ColorFilter.mode(
                  context.isDarkMode ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
                height: 25,
                width: 25,
              ),
            )
          : isBack
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 15,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
