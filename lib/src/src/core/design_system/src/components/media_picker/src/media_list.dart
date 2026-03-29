part of '../ui_media_picker.dart';

class MediaList extends StatefulWidget {
  final AssetPathEntity album;
  final HeaderController headerController;
  final List<Media> previousList;
  final MediaCount? mediaCount;
	final int maxSelectingMediaCount;
  final PickerDecoration decoration;
  final ScrollController scrollController;

  const MediaList({
		super.key, 
    required this.album,
    required this.headerController,
    required this.previousList,
    this.mediaCount,
    required this.maxSelectingMediaCount,
    required this.decoration,
    required this.scrollController,
  });

  @override
  State<MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<Media> mediaList = [];
  int currentPage = 0;
	bool hasGalleryAccess = true;
  bool canLoadMoreMedias = true;
  AssetPathEntity? album;
	List<Media> selectedMediaList = [];

  @override
  void initState() {
    album = widget.album;
    if (widget.mediaCount == MediaCount.multiple) {
      selectedMediaList.addAll(widget.previousList);
			WidgetsBinding.instance.addPostFrameCallback(
				(_) => widget.headerController.updateSelection!(selectedMediaList),
			);
    }
    _fetchNewMedia();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _resetAlbum();
		if (!hasGalleryAccess)
			return NoAccessToGallery(
				needPermissionTitle: widget.decoration.needPermissionText,
				needPermissionBtnLabel: widget.decoration.needPermissionBtnLabel,
			);
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
				if (scroll is ScrollEndNotification && widget.scrollController.position.extentAfter == 0)
					_nextMediaPage();
        return false;
      },
      child: GridView.builder(
        controller: widget.scrollController,
        itemCount: mediaList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      		crossAxisCount: widget.decoration.columnCount,
					crossAxisSpacing: 4,
					mainAxisSpacing: 4
				),
        itemBuilder: (context, index) {
					final media = mediaList[index];
          return MediaTile(
						media: media,
						selectIf: () => selectedMediaList.length < widget.maxSelectingMediaCount,
						onSelecte: (isSelected) {
							if (isSelected)
								selectedMediaList.add(media);
							else
								selectedMediaList.removeWhere((_media) => _media.id == media.id);
							widget.headerController.updateSelection!(selectedMediaList);
						},
						isSelected: selectedMediaList.contains(media),
						decoration: widget.decoration,
					);
        },
      ),
    );
  }

  void _resetAlbum() {
    if (album != null) {
      if (album!.id != widget.album.id) {
        mediaList.clear();
        album = widget.album;
        currentPage = 0;
        _fetchNewMedia();
      }
    }
  }

  void _nextMediaPage() {
		if (canLoadMoreMedias) _fetchNewMedia();
  }

  Future<void> _fetchNewMedia() async {
		const mediasPerPage = 200;
    final accessToPhotos = await Permission.photos.request().isGranted;
    final accessToStorage = await Permission.storage.request().isGranted;
		hasGalleryAccess = Platform.isIOS
			? accessToPhotos : accessToPhotos || accessToStorage;

    if (hasGalleryAccess) {
			final newMedias = await album!.getAssetListPaged(
				page: currentPage,
				size: mediasPerPage
			);

    	canLoadMoreMedias = newMedias.length == mediasPerPage;
			if (newMedias.isNotEmpty)
					mediaList.addAll(newMedias.map((asset) => Media.fromAssetEntity(asset)));
					currentPage++;
		}

		setState(() {});
  }
}
