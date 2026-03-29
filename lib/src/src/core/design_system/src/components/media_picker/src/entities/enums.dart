part of '../../ui_media_picker.dart';

///make picker to select multiple or single media file
enum MediaCount {
  ///make picker to select single media file
  single,

  ///make picker to select multiple media file
  multiple,
}

///Media picker selection type
enum MediaType {
  ///make picker to select only video file
  video,

  ///make picker to select only image file
  image,

  ///make picker to select any media file
  all;

	static MediaType fromAssetType(AssetType type) {
		switch (type) {
			case AssetType.image:
				return image;
			case AssetType.video:
				return video;
			default:
				return all;
		}
	}

	String converToString() {
		switch (this) {
			case image: return 'image';
			case video: return 'video';
			default: return 'all';
		}
	}
}

///position of action bar of media picker
enum ActionBarPosition {
  ///set action bar position top of media picker
  top,

  ///set action bar position bottom of media picker
  bottom,
}
