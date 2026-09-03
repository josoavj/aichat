import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _nameController = TextEditingController(text: profile.userName);
    _bioController = TextEditingController(text: profile.userBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profile, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileHeader(profile, theme),
                const SizedBox(height: 40),
                if (!_isEditing) _buildInfoCard(profile, theme) else _buildEditFields(theme),
                const SizedBox(height: 32),
                _buildActions(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider profile, ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: profile.photoPath != null ? FileImage(File(profile.photoPath!)) : null,
                child: profile.photoPath == null
                    ? Icon(CupertinoIcons.person_fill, size: 60, color: theme.primaryColor)
                    : null,
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
                ),
                child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!_isEditing)
          Text(
            profile.userName,
            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildInfoCard(ProfileProvider profile, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(CupertinoIcons.info, 'Bio', profile.userBio, theme),
            const Divider(height: 32),
            _buildInfoRow(CupertinoIcons.device_phone_portrait, 'Stockage', 'Local uniquement', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEditFields(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nom'),
          style: GoogleFonts.poppins(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(labelText: 'Bio'),
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_isEditing) {
                context.read<ProfileProvider>().updateProfile(
                  name: _nameController.text,
                  bio: _bioController.text,
                );
              }
              setState(() => _isEditing = !_isEditing);
            },
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            label: Text(_isEditing ? 'Enregistrer' : 'Modifier le profil'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      context.read<ProfileProvider>().updateProfile(photo: pickedFile.path);
    }
  }
}
