import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ai_test/providers/auth_provider.dart';

class FirebaseProfilePage extends StatefulWidget {
  const FirebaseProfilePage({super.key});

  @override
  State<FirebaseProfilePage> createState() => _FirebaseProfilePageState();
}

class _FirebaseProfilePageState extends State<FirebaseProfilePage> {
  File? _profileImageFile;
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: () => _showLogoutDialog(context, authProvider),
              );
            },
          )
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.person_crop_circle_badge_exclam, 
                    size: 80, color: theme.primaryColor.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  Text(
                    'Session expirée',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                    child: const Text('Se reconnecter'),
                  ),
                ],
              ),
            );
          }

          final user = authProvider.currentUser;
          if (_nameController.text.isEmpty && user?.displayName != null) {
            _nameController.text = user!.displayName!;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileHeader(user, theme),
                const SizedBox(height: 40),
                _buildInfoCard(user, theme),
                const SizedBox(height: 24),
                _buildActionsSection(context, authProvider, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                        ? NetworkImage(user.photoURL!)
                        : null,
                child: (_profileImageFile == null &&
                        (user?.photoURL == null || user!.photoURL!.isEmpty))
                    ? Icon(CupertinoIcons.person_fill, size: 60, color: theme.primaryColor)
                    : null,
              ),
            ),
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
                  ],
                ),
                child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!_isEditing)
          Text(
            user?.displayName ?? 'Utilisateur',
            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
          )
        else
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: "Votre nom",
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
            ),
          ),
        Text(
          user?.email ?? '',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInfoCard(dynamic user, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(CupertinoIcons.mail, "Email", user?.email ?? 'N/A', theme),
            const Divider(height: 32),
            _buildInfoRow(CupertinoIcons.checkmark_shield, "Statut", 
              user?.emailVerified == true ? 'Vérifié' : 'Non vérifié', theme),
            const Divider(height: 32),
            _buildInfoRow(CupertinoIcons.calendar, "Membre depuis", 
              _formatDate(user?.metadata?.creationTime), theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.primaryColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider, ThemeData theme) {
    return Column(
      children: [
        if (!_isEditing)
          _buildActionButton(
            label: "Modifier le profil",
            icon: Icons.edit_outlined,
            onPressed: () => setState(() => _isEditing = true),
            theme: theme,
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "Sauver",
                  icon: Icons.check,
                  onPressed: () async {
                    await authProvider.updateProfile(displayName: _nameController.text);
                    setState(() => _isEditing = false);
                  },
                  theme: theme,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: "Annuler",
                  icon: Icons.close,
                  onPressed: () => setState(() => _isEditing = false),
                  theme: theme,
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: "Supprimer mon compte",
          icon: CupertinoIcons.trash,
          onPressed: () => _showDeleteAccountDialog(context, authProvider),
          theme: theme,
          isDanger: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20, color: isDanger ? Colors.redAccent : (isPrimary ? Colors.white : theme.primaryColor)),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: isPrimary ? theme.primaryColor : (isDanger ? Colors.redAccent.withOpacity(0.05) : null),
          foregroundColor: isDanger ? Colors.redAccent : (isPrimary ? Colors.white : theme.primaryColor),
          side: BorderSide(color: isDanger ? Colors.redAccent : theme.primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.camera_fill),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_fill),
                title: const Text('Sélectionner depuis galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer la photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImageFile = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo sélectionnée. Sauvegarder pour appliquer.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  Widget _buildInfoSection(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du compte',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile('Email', user?.email ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoTile(
              'Vérifié',
              user?.emailVerified == true ? 'Oui' : 'Non',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              'Créé le',
              user?.metadata?.creationTime?.toString().split('.')[0] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        if (!_isEditing)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Sauvegarder'),
                  onPressed: () async {
                    await authProvider.updateProfile(
                      displayName: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : null,
                    );
                    if (mounted) {
                      setState(() {
                        _isEditing = false;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil mis à jour'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Annuler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.security),
            label: const Text('Changer le mot de passe'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer le compte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => _showDeleteAccountDialog(context, authProvider),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              authProvider.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Tous vos données seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final success = await authProvider.deleteAccount();
              if (mounted) {
                if (success) {
                  Navigator.of(context).pushReplacementNamed('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage ?? 'Erreur'),
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
