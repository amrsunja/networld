part of '../../ui_media_picker.dart';

class NoMedia extends StatelessWidget {
  const NoMedia({
		super.key,
		required this.title
	});

	final String title;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
							title,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
