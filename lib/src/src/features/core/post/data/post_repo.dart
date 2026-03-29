import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/post/data/datasources/post_remote_datasource.dart';
import 'package:networld/src/src/features/core/post/data/models/create_post_result_model.dart';
import 'package:networld/src/src/features/core/post/data/models/poll_option_payload.dart';

final postRepoProvider = Provider<PostRepo>(
  (ref) => PostRepo(remote: ref.read(postRemoteDatasourceProvider)),
);

class PostRepo {
  PostRepo({required this.remote});

  final PostRemoteDatasource remote;

  /// [imageFile] is uploaded first; the public URL is sent to `create-post`.
  Future<SuccessOrError<CreatePostResultModel>> createPost({
    String? content,
    required bool isPoll,
    List<String>? pollOptions,
    File? imageFile,
    required bool isBoosted,
    required String userId,
  }) {
    return Failure.exceptionsCatcher(() async {
      String? imageUrl;
      String? uploadedObjectPath;

      try {
        if (imageFile != null) {
          final uploaded = await remote.uploadPostImage(
            file: imageFile,
            userId: userId,
          );
          imageUrl = uploaded.publicUrl;
          uploadedObjectPath = uploaded.objectPath;
        }

        return await remote.createPost(
          content: content,
          postType: isPoll ? 'poll' : 'standard',
          pollOptions: isPoll && pollOptions != null && pollOptions.isNotEmpty
              ? PollOptionPayload.jsonListFromTitles(pollOptions)
              : null,
          imageUrl: imageUrl,
          isBoosted: isBoosted,
        );
      } catch (_) {
        if (uploadedObjectPath != null) {
          try {
            await remote.deleteUploadedPostImage(uploadedObjectPath);
          } catch (_) {
            // Best-effort cleanup; failure is logged upstream as post error.
          }
        }
        rethrow;
      }
    });
  }
}
