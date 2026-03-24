import 'dart:io';

import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';
import '../../app_ui.dart';


class UINavBar extends StatefulWidget {
	const UINavBar({
		super.key,
		required this.currentPage,
		required this.onPageChange,
		this.isBusy = false,
		this.onCreatePostTap,
	});

	final int currentPage;
	final bool isBusy;
	final Function(int) onPageChange;
	final VoidCallback? onCreatePostTap;

  @override
  State<UINavBar> createState() => _UINavBarState();
}

class _UINavBarState extends State<UINavBar> {

	@override
	Widget build(BuildContext context) {
		final theme = AppTheme.of(context);
    if (Platform.isIOS) {
      return CNTabBar(
        backgroundColor: theme.colors.fgColor,
        tint: UIColorsToken.pri500,
        iconSize: 24,
        items: [
          CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
          CNTabBarItem(label: 'Social', icon: CNSymbol('line.3.horizontal.decrease')),
          CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle')),
        ],
        //currentIndex: currentIndex,
        currentIndex: widget.currentPage,
        onTap: widget.onPageChange,
      );
    }

    return CrystalNavigationBar(
      currentIndex: widget.currentPage,
      onTap: widget.onPageChange,
      borderWidth: .5,
      marginR: .symmetric(horizontal: 70, vertical: 20),
      selectedItemColor: UIColorsToken.pri300,
      unselectedItemColor: UIColorsToken.neu400,
      outlineBorderColor: UIColorsToken.neu400,
      indicatorColor: UIColorsToken.pri350,
      // enableFloatingNavBar: false
      items: [
        CrystalNavigationBarItem(
		  		icon: Iconic.home, 
        ),
        CrystalNavigationBarItem(
		  		icon: Iconic.globe, 
        ),
        CrystalNavigationBarItem(
		  		icon: Iconic.user,
        )
        
      ],
    );
	}
}
