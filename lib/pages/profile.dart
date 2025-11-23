import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/users.dart';
import '../others/app_theme.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/account_dialogs.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? currentUser;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    // Initialiser le gestionnaire d'utilisateurs et récupérer l'utilisateur actuel
    UserManager.initialize();
    currentUser = UserManager.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // Si aucun utilisateur n'est connecté, afficher un message
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Mon compte",
            style:
                GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Aucun utilisateur connecté"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.back)),
        title: Text(
          "Mon compte",
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                _showLogoutDialog(context);
              })
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Section Photo de profil et informations de base
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Section Informations personnelles
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),

            // Section Paramètres
            _buildSettingsSection(context),
            const SizedBox(height: 24),

            // Section Actions
            _buildActionsSection(context),

            // Section pour changer d'utilisateur (pour tester)
            const SizedBox(height: 24),
            _buildUserSwitchSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : currentUser!.profileImageUrl.isNotEmpty
                          ? NetworkImage(currentUser!.profileImageUrl)
                          : null,
                  child: _profileImageFile == null &&
                          currentUser!.profileImageUrl.isEmpty
                      ? Text(
                          currentUser!.firstName[0] + currentUser!.lastName[0],
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.camera_fill,
                          color: Colors.white, size: 16),
                      onPressed: () {
                        _showImagePickerOptions();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentUser!.fullName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "@${currentUser!.username}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentUser!.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentUser!.isOnline ? "En ligne" : "Hors ligne",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: currentUser!.isOnline ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (currentUser!.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                currentUser!.bio,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informations personnelles",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                "Email", currentUser!.email, CupertinoIcons.mail_solid),
            const SizedBox(height: 12),
            _buildInfoRow(
                "Téléphone", currentUser!.phone, CupertinoIcons.phone_fill),
            const SizedBox(height: 12),
            _buildInfoRow("Localisation", currentUser!.location,
                CupertinoIcons.location_solid),
            const SizedBox(height: 12),
            _buildInfoRow("Membre depuis", currentUser!.formattedMemberSince,
                CupertinoIcons.calendar),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.pencil, size: 16),
          onPressed: () {
            _showEditDialog(label, value);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Paramètres",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingRow(
              "Notifications",
              CupertinoIcons.bell_fill,
              Switch(
                value: currentUser!.notificationsEnabled,
                onChanged: (value) {
                  UserManager.updateNotificationSettings(value);
                  setState(() {
                    currentUser = UserManager.currentUser;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingRow(
              "Mode sombre",
              CupertinoIcons.moon_fill,
              Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleThemeMode();
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingRow(
              "Statut en ligne",
              CupertinoIcons.circle_fill,
              Switch(
                value: currentUser!.isOnline,
                onChanged: (value) {
                  UserManager.toggleOnlineStatus();
                  setState(() {
                    currentUser = UserManager.currentUser;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, IconData icon, Widget trailing) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Actions",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionRow("Changer le mot de passe", CupertinoIcons.lock_fill,
                () {
              _showChangePasswordDialog();
            }),
            const SizedBox(height: 12),
            _buildActionRow("Historique des activités", CupertinoIcons.time,
                () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Fonctionnalité en développement")));
            }),
            const SizedBox(height: 12),
            _buildActionRow(
                "Aide et support", CupertinoIcons.question_circle_fill, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Contactez-nous à support@example.com")));
            }),
            const SizedBox(height: 12),
            _buildActionRow(
                "Politique de confidentialité", CupertinoIcons.doc_text_fill,
                () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Politique de confidentialité")));
            }),
            const SizedBox(height: 12),
            _buildActionRow("Supprimer le compte", CupertinoIcons.delete_solid,
                () {
              _showDeleteAccountDialog(context);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: isDestructive ? Colors.red : Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : null,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Section pour changer d'utilisateur (pour tester)
  Widget _buildUserSwitchSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Changer d'utilisateur (Test)",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...UserManager.allUsers.map(
              (user) => InkWell(
                onTap: () {
                  UserManager.setCurrentUser(user.id);
                  setState(() {
                    currentUser = UserManager.currentUser;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentUser!.id == user.id
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(
                          user.firstName[0] + user.lastName[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "@${user.username}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentUser!.id == user.id)
                        const Icon(Icons.check_circle,
                            color: Colors.blue, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Déconnexion",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Êtes-vous sûr de vouloir vous déconnecter?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              child: Text(
                "Annuler",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Déconnecter",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                UserManager.logout();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    AccountDialogs.showDeleteAccountDialog(
      context,
      onConfirm: (password) async {
        try {
          final authService = AuthService();
          await authService.initialize();
          await authService.deleteAccount(password);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compte supprimé avec succès'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        } catch (e) {
          rethrow;
        }
      },
    );
  }

  void _showEditDialog(String field, String currentValue) {
    final profileService = ProfileService();

    AccountDialogs.showEditProfileDialog(
      context,
      firstName: currentUser?.firstName ?? '',
      lastName: currentUser?.lastName ?? '',
      email: currentUser?.email ?? '',
      phone: currentUser?.phone ?? '',
      location: currentUser?.location ?? '',
      bio: currentUser?.bio ?? '',
      onSave: (values) async {
        try {
          await profileService.initialize();
          await profileService.updateProfile(
            firstName: values['firstName'] ?? '',
            lastName: values['lastName'] ?? '',
            email: values['email'] ?? '',
            phone: values['phone'] ?? '',
            location: values['location'] ?? '',
            bio: values['bio'] ?? '',
          );

          setState(() {
            currentUser = UserManager.currentUser;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          rethrow;
        }
      },
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Changer la photo de profil",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(CupertinoIcons.camera_fill),
                title: const Text("Prendre une photo"),
                onTap: () {
                  Navigator.pop(context);
                  _capturePhotoFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_fill),
                title: const Text("Choisir depuis la galerie"),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _profileImageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _capturePhotoFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  void _showChangePasswordDialog() {
    AccountDialogs.showChangePasswordDialog(
      context,
      onSave: (oldPassword, newPassword) async {
        try {
          final authService = AuthService();
          await authService.initialize();
          await authService.changePassword(oldPassword, newPassword);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mot de passe modifié avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          rethrow;
        }
      },
    );
  }
}
