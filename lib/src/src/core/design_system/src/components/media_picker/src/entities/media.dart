// ignore_for_file: must_be_immutable

part of '../../ui_media_picker.dart';

///This class will contain the necessary data of selected media
class Media extends AssetEntity {
  ///Type of the media, Image/Video
  MediaType mediaType;


	///Is selected
	bool isSelected;

  ///The image file in bytes format
  //Uint8List? mediaByte;

  ///Image Dimensions
  //Size? size;

  ///Creation time of the media file on local storage
  //DateTime? creationTime;

  Media({
    required super.id,
    required super.typeInt,
    required super.width,
    required super.height,
    this.mediaType = MediaType.all,
    this.isSelected = false,
  });

	factory Media.fromAssetEntity(AssetEntity asset) {
		return Media(
			id: asset.id,
			typeInt: asset.typeInt,
			height: asset.height,
			width: asset.width,
			mediaType: MediaType.fromAssetType(asset.type)
		);
	}
}
