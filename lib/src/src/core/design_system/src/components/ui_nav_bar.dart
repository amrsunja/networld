import 'dart:io';

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

	Widget _buildIcon(IconData icon, {bool isActive = false}) {
		return UIIcon(
			icon,
			color: isActive ? UIColorsToken.sec100 : UIColorsToken.grey,
		);
	}

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
          CNTabBarItem(label: 'Social', icon: CNSymbol('line.3.horizontal')),
          CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle')),
        ],
        //currentIndex: currentIndex,
        currentIndex: widget.currentPage,
        onTap: widget.onPageChange,
      );
    }
		return ClipRRect(
		  child: BottomNavigationBar(
		  	backgroundColor: theme.colors.fgColor,
		  	type: BottomNavigationBarType.fixed,
		  	unselectedItemColor: UIColorsToken.grey,
		  	iconSize: 24,
		  	onTap: widget.onPageChange,
		  	currentIndex: widget.currentPage,
		  	//selectedLabelStyle: UITextStyleToken.bodyM2,
		  	//unselectedLabelStyle: UITextStyleToken.bodyM2,
		  	selectedItemColor: UIColorsToken.sec100,
		  	items: [
		  		BottomNavigationBarItem(
		  			label: '',
		  			icon: _buildIcon(Iconic.home, isActive: widget.currentPage == 0),
		  		),
		  		BottomNavigationBarItem(
		  			label: '',
		  			icon: _buildIcon(Iconic.list, isActive: widget.currentPage == 1),
		  		),
		  		BottomNavigationBarItem(
		  			label: '',
		  			icon: _buildIcon(Iconic.user, isActive: widget.currentPage == 2),
		  		),
		  	],
		  ),
		);
	}
}
