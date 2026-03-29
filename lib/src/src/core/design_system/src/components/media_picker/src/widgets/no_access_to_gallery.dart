part of '../../ui_media_picker.dart';

class NoAccessToGallery extends StatelessWidget {
  const NoAccessToGallery ({
		super.key,
		required this.needPermissionTitle,
		required this.needPermissionBtnLabel,
	});
	final String needPermissionTitle;
	final String needPermissionBtnLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
					UIIcon(
						Iconic.gallery_bold,
						size: 60,
					),
          const UISpace.vert(25),
					Text(
						needPermissionTitle,
						textAlign: TextAlign.center,
					),
          const UISpace.vert(30),
					UIButton.primary(
						title: needPermissionBtnLabel,
            height: 40,
						onTap: () async {
							await PhotoManager.openSetting();
						},
					),
        ],
      ),
    );
  }
}
