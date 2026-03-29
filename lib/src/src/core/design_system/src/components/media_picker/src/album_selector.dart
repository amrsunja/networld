// ignore_for_file: curly_braces_in_flow_control_structures
part of '../ui_media_picker.dart';

class AlbumSelector extends StatefulWidget {
  const AlbumSelector({
		super.key, 
		required this.onSelect,
    required this.albums,
    required this.panelController,
    required this.decoration,
	});

  final ValueChanged<AssetPathEntity> onSelect;
  final List<AssetPathEntity> albums;
  final PanelController panelController;
  final PickerDecoration decoration;

  @override
  State<AlbumSelector> createState() => _AlbumSelectorState();
}

class _AlbumSelectorState extends State<AlbumSelector> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
			builder: (context, constrains) {
				return SlidingUpPanel(
					controller: widget.panelController,
					minHeight: 0,
					color: AppTheme.of(context).colors.bgColor,
					boxShadow: const [],
					maxHeight: constrains.maxHeight,
					panelBuilder: (sc) {
						return ListView(
							controller: sc,
							children: List<Widget>.generate(
								widget.albums.length,
								(index) => AlbumTile(
									album: widget.albums[index],
									onSelect: () => widget.onSelect(widget.albums[index]),
									decoration: widget.decoration,
								),
							),
						);
					},
				);
			},
		);
  }
}

class AlbumTile extends StatefulWidget {
  const AlbumTile({
		super.key,
		required this.album,
		required this.onSelect,
		required this.decoration
	});

  final AssetPathEntity album;
  final VoidCallback onSelect;
  final PickerDecoration decoration;

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  Uint8List? albumThumb;
  bool hasError = false;
	int assetsCount = 0;

  @override
  void initState() {
    super.initState();
		WidgetsBinding.instance.addPostFrameCallback((dur) async {
    	await _getAlbumThumb(widget.album);
		});
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
		final localeValue = 'fr'; //AppLocale.of(context).media_picker_locale;
		const albumThumbSize = 67.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onSelect,
            child: Row(
              children: [
                Container(
									height: albumThumbSize,
									width: albumThumbSize,
                  padding: const EdgeInsets.all(7),
                  child: !hasError
									? albumThumb != null
										? ClipRRect(
												borderRadius: BorderRadius.circular(8),
												child: Image.memory(
													albumThumb!,
													fit: BoxFit.cover,
												),
											)
										: LoadingWidget(decoration: widget.decoration)
										: Center(
											child: UIIcon(
												Iconic.gallery_solid,
												size: 20,
											),
										),
                ),
                ConstrainedBox(
									constraints: const BoxConstraints(maxWidth: 230),
									child: Text(
										AlbumTranlator.translateAlbum(
											widget.album.name,
											localeValue
										),
										overflow: TextOverflow.fade,
                    style: theme.typo.textSm.regular,
									)
                ),
                const SizedBox(width: 5),
                Text(
                  '$assetsCount',
                  style: widget.decoration.albumCountTextStyle ?? TextStyle(
										color: Colors.grey.shade600,
										fontSize: 12,
										fontWeight: FontWeight.w400,
									),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getAlbumThumb(AssetPathEntity album) async {
    final List<AssetEntity> media = await album.getAssetListPaged(page:0, size:1);
    // ignore: sdk_version_since
    final Uint8List? thumbByte = await media.firstOrNull?.thumbnailDataWithSize(const ThumbnailSize(80, 80));
		if (thumbByte != null) {
			assetsCount = await album.assetCountAsync;
      setState(() {
        albumThumb = thumbByte;
      });
		}
    else
      setState(() => hasError = true);
  }
}
