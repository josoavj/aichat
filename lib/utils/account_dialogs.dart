import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountDialogs {
  /// Dialogue pour éditer le profil
  static Future<bool?> showEditProfileDialog(
    BuildContext context, {
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String location,
    required String bio,
    required Function(Map<String, String>) onSave,
  }) async {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phone);
    final locationController = TextEditingController(text: location);
    final bioController = TextEditingController(text: bio);
    String? errorMessage;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Éditer le profil',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  'Prénom',
                  firstNameController,
                  CupertinoIcons.person_fill,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Nom',
                  lastNameController,
                  CupertinoIcons.person_fill,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Email',
                  emailController,
                  CupertinoIcons.mail_solid,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Téléphone',
                  phoneController,
                  CupertinoIcons.phone_fill,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Localisation',
                  locationController,
                  CupertinoIcons.location_solid,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Bio',
                  bioController,
                  CupertinoIcons.pencil_outline,
                  maxLines: 3,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await onSave({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'location': locationController.text,
                    'bio': bioController.text,
                  });
                  Navigator.pop(context, true);
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Enregistrer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialogue pour changer le mot de passe
  static Future<bool?> showChangePasswordDialog(
    BuildContext context, {
    required Function(String, String) onSave,
  }) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? errorMessage;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Changer le mot de passe',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildPasswordField(
                  'Ancien mot de passe',
                  oldPasswordController,
                  obscureOld,
                  onVisibilityToggle: () {
                    setState(() => obscureOld = !obscureOld);
                  },
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  'Nouveau mot de passe',
                  newPasswordController,
                  obscureNew,
                  onVisibilityToggle: () {
                    setState(() => obscureNew = !obscureNew);
                  },
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  'Confirmer le nouveau',
                  confirmPasswordController,
                  obscureConfirm,
                  onVisibilityToggle: () {
                    setState(() => obscureConfirm = !obscureConfirm);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    setState(() {
                      errorMessage =
                          'Les nouveaux mots de passe ne correspondent pas';
                    });
                    return;
                  }

                  await onSave(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Changer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialogue de confirmation de suppression de compte
  static Future<bool?> showDeleteAccountDialog(
    BuildContext context, {
    required Function(String) onConfirm,
  }) async {
    final passwordController = TextEditingController();
    bool obscure = true;
    String? errorMessage;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Supprimer le compte',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attention !',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
                        style: GoogleFonts.poppins(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildPasswordField(
                  'Confirmer avec votre mot de passe',
                  passwordController,
                  obscure,
                  onVisibilityToggle: () {
                    setState(() => obscure = !obscure);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await onConfirm(passwordController.text);
                  Navigator.pop(context, true);
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Supprimer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Widgets privés ===

  static Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  static Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure, {
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(CupertinoIcons.lock_fill, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
            size: 18,
          ),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
