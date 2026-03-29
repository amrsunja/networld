// ignore_for_file: curly_braces_in_flow_control_structures

part of '../ui_media_picker.dart';

///The MediaPicker widget that will select media files form storage
class MediaPicker extends StatefulWidget {
  ///CallBack on image pick is done
  final ValueChanged<List<Media>> onPick;

  ///Previously selected list of media in your app
  final List<Media> mediaList;

	///Max count of selecting items
	final int maxSelectingMediaCount;

  ///make picker to select multiple or single media file
  final MediaCount mediaCount;

  ///Make picker to select specific type of media, video or image
  final MediaType mediaType;

  ///decorate the UI of picker
  final PickerDecoration? decoration;

  ///assign a scroll controller to Media GridView of Picker
  final ScrollController? myScrollController;

  ///The MediaPicker constructor that will select media files form storage
  const MediaPicker({
		super.key, 
    required this.onPick,
    required this.mediaList,
    this.maxSelectingMediaCount = 5,
    this.mediaCount = MediaCount.multiple,
    this.mediaType = MediaType.all,
    this.decoration,
    this.myScrollController,
  });


  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  late PickerDecoration _decoration;
	bool hasGalleryAccess = true;

  AssetPathEntity? _selectedAlbum;
  List<AssetPathEntity>? _albums;

  final PanelController _albumController = PanelController();
  final HeaderController _headerController = HeaderController();
	late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _decoration = widget.decoration ?? PickerDecoration();
		scrollController = widget.myScrollController ?? ScrollController();
		WidgetsBinding.instance.addPostFrameCallback((time) async {
    	await _fetchAlbums();
		});
  }

	@override
  void dispose() {
		scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		if (!hasGalleryAccess)
			return NoAccessToGallery(
				needPermissionTitle: _decoration.needPermissionText,
				needPermissionBtnLabel: _decoration.needPermissionBtnLabel,
			);
    return Material(
      color: Colors.transparent,
      child: _albums == null
				? LoadingWidget(decoration: _decoration)
				: _albums!.isEmpty
						? NoMedia(title: _decoration.noMediaTitle)
						: Column(
								children: [
									if (_decoration.actionBarPosition == ActionBarPosition.top)
										_buildHeader(),
									Expanded(
										child: Stack(
											children: [
												Positioned.fill(
													child: MediaList(
														album: _selectedAlbum!,
														headerController: _headerController,
														previousList: widget.mediaList,
														mediaCount: widget.mediaCount,
														maxSelectingMediaCount: widget.maxSelectingMediaCount,
														decoration: _decoration,
														scrollController: scrollController,
													),
												),
												AlbumSelector(
													panelController: _albumController,
													albums: _albums!,
													decoration: _decoration,
													onSelect: (album) {
														_headerController.closeAlbumDrawer!();
														setState(() => _selectedAlbum = album);
													},
												),
											],
										),
									),
									if (_decoration.actionBarPosition == ActionBarPosition.bottom)
										_buildHeader(),
								],
							),
    );
  }

  Widget _buildHeader() {
    return Header(
      onBack: handleBackPress,
      onDone: widget.onPick,
      albumController: _albumController,
      selectedAlbum: _selectedAlbum!,
      controller: _headerController,
      mediaCount: widget.mediaCount,
      decoration: _decoration,
    );
  }

  Future<void> _fetchAlbums() async {
    RequestType type = RequestType.common;

    if (widget.mediaType == MediaType.all)
      type = RequestType.common;
    else if (widget.mediaType == MediaType.video)
      type = RequestType.video;
    else if (widget.mediaType == MediaType.image)
			type = RequestType.image;

    final accessToPhotos = await Permission.photos.request().isGranted;
    final accessToStorage = await Permission.storage.request().isGranted;
		hasGalleryAccess = Platform.isIOS
			? accessToPhotos : accessToPhotos || accessToStorage;

    if (hasGalleryAccess) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: type);
      _albums = albums;
      _selectedAlbum = _albums?.firstOrNull;
		}

		setState(() {});
  }

  void handleBackPress() {
    if (_albumController.isPanelOpen)
      _albumController.close();
  }
}

///call this function to capture and get media from camera
Future<void> openCamera({
  ///callback when capturing is done
  required ValueChanged<Media> onCapture,
}) async {
	final ImagePicker picker = ImagePicker();
	final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

	if (pickedFile != null) {
		//final converted = Media(
			//id: UniqueKey().toString(),
			//file: File(pickedFile.path),
			//thumbnail: await pickedFile.readAsBytes(),
			//creationTime: DateTime.now(),
			//mediaByte: await pickedFile.readAsBytes(),
			//title: 'capturedImage',
		//);
		//onCapture(converted);
	}
} 
