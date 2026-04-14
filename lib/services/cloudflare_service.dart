import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minio_new/minio.dart';
import 'package:path/path.dart' as path;

class CloudflareService {
  static Minio? _minio;
  
  static Minio get minio {
    if (_minio == null) {
      final accountId = dotenv.env['ACCOUNT_ID'] ?? '';
      _minio = Minio(
        endPoint: '$accountId.r2.cloudflarestorage.com',
        accessKey: dotenv.env['ACCESS_KEY_ID'] ?? '',
        secretKey: dotenv.env['SECRET_ACCESS_KEY'] ?? '',
        useSSL: true,
      );
    }
    return _minio!;
  }

  /// Uploads an image to Cloudflare R2 and returns the public URL
  static Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final bucketName = dotenv.env['BUCKET_NAME'] ?? 'easylens';
      
      // Ensure bucket exists (or skip if R2 bucket is pre-configured)
      bool exists = await minio.bucketExists(bucketName);
      if (!exists) {
        // Technically R2 buckets are usually pre-created, but just in case
        await minio.makeBucket(bucketName);
      }

      // Create a unique filename based on the user ID to prevent caching issues
      final extension = path.extension(imageFile.path);
      final filename = 'profiles/${userId}_${DateTime.now().microsecondsSinceEpoch}$extension';

      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      final stream = Stream.value(bytes);

      // Upload to minio
      await minio.putObject(
        bucketName,
        filename,
        stream,
        size: bytes.length,
      );

      // Return the public URL for the image
      // Note: This assumes the bucket is public or you have a custom domain hooked up.
      // E.g., https://pub-xxxxxxxxxx.r2.dev/profiles/...
      // If there is a public custom domain, you should use that. For now, we will construct the R2 dev URL,
      // or simply rely on the presigned URL if it's private.
      // Usually, we return the direct URL if public. Since we don't have the dev domain in .env,
      // we can return a signed URL that's valid for a long time, OR construct a typical URL.
      
      // Since Profile pictures should be readable, we'll try to generate a presigned GET URL first
      // just in case the bucket isn't totally public.
      final url = await minio.presignedGetObject(bucketName, filename, expires: 60 * 60 * 24 * 7); // 7 days
      return url;
    } catch (e) {
      print('Error uploading to Cloudflare R2: $e');
      return null;
    }
  }

  static Future<void> deleteProfileImage(String oldUrl) async {
    // If we need to clean up old URLs, we extract the object name
    try {
      final bucketName = dotenv.env['BUCKET_NAME'] ?? 'easylens';
      // Basic extraction of path from a url...
      final uri = Uri.tryParse(oldUrl);
      if (uri != null) {
        // Find the index of the bucket name and get the rest of the path
        final pathSegments = uri.pathSegments;
        if (pathSegments.contains('profiles')) {
          final profileIndex = pathSegments.indexOf('profiles');
          final objectName = pathSegments.sublist(profileIndex).join('/');
          await minio.removeObject(bucketName, objectName);
        }
      }
    } catch (e) {
      print('Error deleting old image from Cloudflare R2: $e');
    }
  }
}
