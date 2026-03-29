part of '../../ui_media_picker.dart';

class MediaTile extends StatefulWidget {
  final Media media;
  final Function(bool) onSelecte;
  final bool Function() selectIf;
  final bool isSelected;
  final PickerDecoration decoration;

  const MediaTile({
    super.key,
    required this.media,
    required this.selectIf,
    required this.onSelecte,
    this.isSelected = false,
    required this.decoration,
  });

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  bool selected = false;


  final _duration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    selected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
		return FutureBuilder(
			future: widget.media.thumbnailData,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null)
					return const Center(child: UICircularProgressBar());
				return Padding(
          padding: const EdgeInsets.all(0.5),
          child: UITap(
            onTap: () {
              final canSelect = widget.selectIf();
              if (canSelect || selected) {
                setState(() => selected = !selected);
                widget.onSelecte(selected);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
                // If it is a video show video indicator
                if (widget.media.mediaType == MediaType.video)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      child: UIIcon(
                        Iconic.play
                      ),
                    ),
                  ),
                AnimatedOpacity(
                  curve: Curves.easeOut,
                  duration: _duration,
                  opacity: selected ? 1 : 0,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: UIIcon(
                        Iconic.plus,
                      )
                    ),
                  ),
                ),
              ],
            ),
          ),
				);
			}
		);
  }
}
