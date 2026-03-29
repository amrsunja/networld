part of '../ui_media_picker.dart';

class Header extends StatefulWidget {
  const Header({
		super.key, 
    required this.selectedAlbum,
    required this.onBack,
    required this.onDone,
    required this.albumController,
    required this.controller,
    this.mediaCount,
    this.decoration,
  });

  final AssetPathEntity selectedAlbum;
  final VoidCallback onBack;
  final PanelController albumController;
  final ValueChanged<List<Media>> onDone;
  final HeaderController controller;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TickerProviderStateMixin {
  List<Media> selectedMedia = [];

  late Animation<double> _arrowAnimation;
  late AnimationController _arrowAnimController;

  @override
  void initState() {
    _arrowAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(_arrowAnimController);

    widget.controller.updateSelection = (selectedMediaList) {
      if (widget.mediaCount == MediaCount.multiple)
        setState(() => selectedMedia = selectedMediaList.cast<Media>());
      else if (selectedMediaList.length == 1) widget.onDone(selectedMediaList);
    };

    widget.controller.closeAlbumDrawer = () {
      widget.albumController.close();
      _arrowAnimController.reverse();
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final albumTitleColor =
        widget.decoration?.albumTitleStyle?.color ?? theme.colors.contentColor;
    final albumTitleStyle =
        theme.typo.textSm.regular.copyWith(color: albumTitleColor);

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 8),
		  child: Row(
		    mainAxisAlignment: MainAxisAlignment.spaceBetween,
		    children: [
		      Padding(
		  			padding: EdgeInsets.all(8),
		        child: Center(
		          child: JumpingButton(
		            child: Row(
		              mainAxisAlignment: MainAxisAlignment.center,
		              crossAxisAlignment: CrossAxisAlignment.center,
		              children: [
		                AnimatedSwitcher(
		                  duration: const Duration(milliseconds: 200),
		                  transitionBuilder: (child, animation) {
		                    return SlideTransition(
		                      position: Tween<Offset>(
		  											begin: const Offset(0.0, -0.5),
		  											end: const Offset(0.0, 0.0),
		  										).animate(animation),
		                      child: child,
		                    );
		                  },
		  								child: Text(
												AlbumTranlator.translateAlbum(
													widget.selectedAlbum.name,
												  'fr'	
												),
                        style: albumTitleStyle,
		  								),
		                ),
		  							const SizedBox(width: 5,),
		                AnimatedBuilder(
		                  animation: _arrowAnimation,
		                  builder: (context, child) => Transform.rotate(
		                    angle: _arrowAnimation.value,// * pi,
		                    child: UIIcon(
									  			Iconic.picture,
		                      size: 15,
		                      color: albumTitleColor,
		  									),
		                  ),
		                ),
		              ],
		            ),
		            onTap: () {
		              if (widget.albumController.isPanelOpen) {
		                widget.albumController.close();
		                _arrowAnimController.reverse();
		              } else {
		                widget.albumController.open();
		                _arrowAnimController.forward();
		              }
		            },
		          ),
		        ),
		      ),
		      if (widget.mediaCount == MediaCount.multiple)
		        AnimatedSwitcher(
		          duration: const Duration(milliseconds: 100),
		          transitionBuilder: (child, animation) {
		            return SlideTransition(
		              position: Tween<Offset>(
		              	begin: const Offset(1, 0.0),
		  							end: const Offset(0.0, 0.0)
		  						).animate(animation),
		              child: child,
		            );
		          },
		          child: (selectedMedia.isNotEmpty)
								? UIButton.primary(
		  							key: const Key('button'),
										title: "${widget.decoration!.completeText} (${selectedMedia.length})",
                    height: 40,
										onTap: selectedMedia.isNotEmpty
											? () => widget.onDone(selectedMedia)
											: null,
									)
		            : Container(key: const Key('blank')),
		        ),
		    ],
		  ),
		);
  }
}
