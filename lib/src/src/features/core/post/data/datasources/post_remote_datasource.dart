import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/post/data/models/create_post_result_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

final postRemoteDatasourceProvider = Provider<PostRemoteDatasource>(
  (ref) => PostRemoteDatasource(),
);

class PostRemoteDatasource {
  static const _createPostFn = 'create-post';
  static const _imagesBucket = 'images';

  /// Uploads to `posts/{userId}/{unique}` in bucket [images].
  Future<({String publicUrl, String objectPath})> uploadPostImage({
    required File file,
    required String userId,
  }) async {
    final ext = _fileExtension(file.path);
    final objectPath = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}$ext';

    await supabase.storage.from(_imagesBucket).upload(
          objectPath,
          file,
        );

    final publicUrl = supabase.storage.from(_imagesBucket).getPublicUrl(objectPath);
    return (publicUrl: publicUrl, objectPath: objectPath);
  }

  /// Removes an object from [images] (e.g. after post creation failed).
  Future<void> deleteUploadedPostImage(String objectPath) async {
    await supabase.storage.from(_imagesBucket).remove([objectPath]);
  }

  /// Resolves a gallery [AssetEntity] to a local [File] for upload.
  Future<File?> assetToFile(AssetEntity entity) async {
    return await entity.originFile ?? await entity.file;
  }

  /// Creates a post via Edge Function (credits, moderation, ledger).
  Future<CreatePostResultModel> createPost({
    String? content,
    required String postType,
    List<Map<String, dynamic>>? pollOptions,
    String? imageUrl,
    required bool isBoosted,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'post_type': postType,
      'poll_options': pollOptions,
      'image_url': imageUrl,
      'is_boosted': isBoosted,
    };

    try {
      final res = await supabase.functions.invoke(
        _createPostFn,
        body: body,
      );

      final data = (res.data as Json?) ?? {};
      final parsed = CreatePostResultModel.fromJson(data);

      if (!parsed.success && parsed.error != null) {
        throw ServerException.fromErrorCode(parsed.error);
      }

      return parsed;
    } on FunctionException catch (e) {
      final details = e.details;
      String? code;
      if (details is Map) {
        final m = Map<String, dynamic>.from(details as Map);
        code = m['error'] as String? ?? m['code'] as String?;
        if (code == null && m['message'] is String) {
          code = m['message'] as String?;
        }
      }
      throw ServerException.fromErrorCode(code);
    }
  }

  String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    if (ext.length > 8) return '.jpg';
    return ext;
  }
}
