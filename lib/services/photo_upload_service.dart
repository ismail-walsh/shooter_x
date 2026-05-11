import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/auth/supabase_auth/auth_util.dart';

class PhotoUploadService {
  static final PhotoUploadService _instance = PhotoUploadService._internal();
  factory PhotoUploadService() => _instance;
  PhotoUploadService._internal();

  final _picker = ImagePicker();
  final _client = Supabase.instance.client;

  /// Pick an image from gallery and upload it.
  /// Returns the public URL, or null if cancelled/failed.
  Future<String?> pickAndUpload({
    required String bucket,
    required String folder,
  }) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 82,
    );
    if (xfile == null) return null;
    return _uploadFile(File(xfile.path), bucket: bucket, folder: folder);
  }

  Future<String?> _uploadFile(
    File file, {
    required String bucket,
    required String folder,
  }) async {
    final uid = currentUserUid;
    if (uid.isEmpty) return null;

    final ext = file.path.split('.').last.toLowerCase();
    final path = '$folder/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }
}

final photoUploadService = PhotoUploadService();
