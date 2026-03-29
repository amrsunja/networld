part of '../../ui_media_picker.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.decoration});

  final PickerDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (decoration.loadingWidget != null)
          ? decoration.loadingWidget
          : const UICircularProgressBar(),
    );
  }
}
