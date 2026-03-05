import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../app_ui.dart';


class UINavBar extends StatefulWidget {
	const UINavBar({
		super.key,
		required this.currentPage,
		this.onPageChange,
		this.isBusy = false,
		this.onCreatePostTap,
	});

	final int currentPage;
	final bool isBusy;
	final Function(int)? onPageChange;
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
		  			icon: _buildIcon(FontAwesomeIcons.home, isActive: widget.currentPage == 0),
		  		),
		  		BottomNavigationBarItem(
		  			label: '',
		  			icon: _buildIcon(FontAwesomeIcons.list, isActive: widget.currentPage == 1),
		  		),
		  		BottomNavigationBarItem(
		  			label: '',
		  			icon: _buildIcon(FontAwesomeIcons.person, isActive: widget.currentPage == 2),
		  		),
		  	],
		  ),
		);
	}
}
