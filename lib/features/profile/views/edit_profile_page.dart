import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/profile/models/user_profile.dart';
import 'package:suka_emam_app/features/profile/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  late final TextEditingController _usernameController;
  late final TextEditingController _instagramController;
  late final TextEditingController _tiktokController;
  late final TextEditingController _facebookController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data awal dari profil
    _usernameController = TextEditingController(text: widget.userProfile.name);
    _instagramController = TextEditingController(text: widget.userProfile.instagramUsername);
    _tiktokController = TextEditingController(text: widget.userProfile.tiktokUsername);
    _facebookController = TextEditingController(text: widget.userProfile.facebookProfileUrl);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final dataToUpdate = {
        'username': _usernameController.text,
        'instagram_username': _instagramController.text,
        'tiktok_username': _tiktokController.text,
        'facebook_profile_url': _facebookController.text,
      };

      // Panggil service untuk update profil
      await _profileService.updateProfile(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        // Kembali ke halaman sebelumnya
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(labelText: 'Instagram Username', prefixText: '@'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tiktokController,
              decoration: const InputDecoration(labelText: 'TikTok Username', prefixText: '@'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facebookController,
              decoration: const InputDecoration(labelText: 'URL Profil Facebook'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
