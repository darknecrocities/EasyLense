import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/language_screen.dart';
import 'package:minio_new/minio.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        await _uploadToCloudflareR2();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadToCloudflareR2() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final accountId = dotenv.env['ACCOUNT_ID'] ?? '';
      final accessKeyId = dotenv.env['ACCESS_KEY_ID'] ?? '';
      final secretAccessKey = dotenv.env['SECRET_ACCESS_KEY'] ?? '';
      final bucketName = dotenv.env['BUCKET_NAME'] ?? 'easylens';
      
      print('--- R2 DEBUG LOGS ---');
      print('Endpoint: $accountId.r2.cloudflarestorage.com');
      print('Bucket: $bucketName');
      print('Checking keys availability: ID=${accessKeyId.isNotEmpty}, Secret=${secretAccessKey.isNotEmpty}');

      if (accountId.isEmpty || accessKeyId.isEmpty || secretAccessKey.isEmpty) {
        throw Exception("Missing R2 credentials in .env file.");
      }

      final minio = Minio(
        endPoint: '$accountId.r2.cloudflarestorage.com',
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        useSSL: true,
        region: 'auto',
      );

      final String fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
      print('Target Filename: $fileName');

      final bytes = await _imageFile!.readAsBytes();
      print('Image size: ${bytes.length} bytes');
      
      final stream = Stream.value(bytes);

      print('Starting minio.putObject upload...');

      // Upload using putObject and a stream
      await minio.putObject(
        bucketName,
        fileName,
        stream,
        size: bytes.length,
      );

      print('Upload successful!');
      
      String apiEndpoint = dotenv.env['S3_API']?.replaceAll(RegExp(r'/$'), '') ?? 'https://$accountId.r2.cloudflarestorage.com/$bucketName';
      String uploadedUrl = "$apiEndpoint/$fileName";
      print('Dynamic URL generated: $uploadedUrl');

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Updating Firestore for user: ${user.uid}');
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profileImageUrl': uploadedUrl,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture successfully uploaded!')),
        );
        _proceedNext();
      }
    } catch (e, stack) {
      print('!!! R2 UPLOAD ERROR !!!');
      print(e);
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _proceedNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              const Text(
                'Upload your profile\npicture',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              
              const Spacer(),

              // Profile Image Display
              Center(
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF08209A), width: 6),
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: _imageFile != null
                        ? Image.network(
                            _imageFile!.path,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 200,
                            color: Color(0xFF08209A),
                          ),
                  ),
                ),
              ),
              
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF08209A))),
                ),

              const Spacer(),

              // Upload Buttons
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08209A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Upload Picture',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                  ),
                  child: const Text(
                    'Take a Picture',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF08209A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _proceedNext,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08209A),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Bottom Pagination & Next arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDot(true),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF08209A),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: _proceedNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF08209A) : Colors.transparent,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(color: const Color(0xFF08209A), width: 1),
      ),
    );
  }
}
