import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final filteredUsers = adminProvider.users.where((u) {
      if (u.role == 'admin') return false; // Exclude admins
      final query = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(query) || 
             u.email.toLowerCase().contains(query) ||
             u.role.toLowerCase().contains(query);
    }).toList();

    // Sort alphabetically by name
    filteredUsers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                _buildAppBar(context),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildSearchBar(),
                ),

                // User List
                Expanded(
                  child: adminProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C1810)))
                      : filteredUsers.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                return _buildUserCard(context, filteredUsers[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: const Color(0xFF2C1810),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFFF4EBD0), width: 2),
        ),
        child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFFF4EBD0)),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE5B94C), // Retro Mustard
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF2C1810),
              offset: Offset(6, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C1810)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Text(
              'KELOLA PENGGUNA',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: const Color(0xFF2C1810),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2C1810),
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau role...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF2C1810).withOpacity(0.4),
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2C1810)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    Color roleColor = const Color(0xFFD9614C); // Red for admin
    if (user.role == 'user') roleColor = const Color(0xFFE5B94C); // Mustard for user
    if (user.role == 'teknisi') roleColor = const Color(0xFFFFFFFF); // White for teknisi

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2C1810),
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2C1810),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: roleColor,
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1810),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                Text(
                  user.email,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: const Color(0xFF2C1810).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2C1810), width: 2),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2C1810)),
                onPressed: () => _showEditUserDialog(context, user),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD9614C)),
                onPressed: () => _showDeleteConfirmation(context, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search_rounded, size: 64, color: Color(0xFF2C1810)),
          const SizedBox(height: 16),
          Text(
            'USER TIDAK DITEMUKAN',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: const Color(0xFF2C1810),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController(text: 'careu123'); // Default password
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF4EBD0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2C1810), width: 4),
          ),
          title: Text(
            'TAMBAH PENGGUNA',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField('NAMA', nameController),
                const SizedBox(height: 16),
                _buildDialogField('EMAIL', emailController),
                const SizedBox(height: 16),
                _buildDialogField('TELEPON', phoneController),
                const SizedBox(height: 16),
                _buildDialogField('PASSWORD DEFAULT', passwordController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: _dialogInputDecoration('ROLE'),
                  items: ['user', 'teknisi'].map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
            ),
            ElevatedButton(
              style: _dialogButtonStyle(const Color(0xFFD9614C)),
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) return;
                
                // Use AuthProvider to sign up
                final success = await context.read<AuthProvider>().signUp(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  phone: phoneController.text.trim(),
                  role: selectedRole,
                );
                
                if (success && context.mounted) {
                  await context.read<AdminProvider>().fetchAllUsers();
                  Navigator.pop(context);
                }
              },
              child: Text('TAMBAH', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');
    final passwordController = TextEditingController(); // Empty means no change
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF4EBD0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2C1810), width: 4),
          ),
          title: Text(
            'EDIT PENGGUNA',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField('NAMA', nameController),
                const SizedBox(height: 16),
                _buildDialogField('TELEPON', phoneController),
                const SizedBox(height: 16),
                _buildDialogField('PASSWORD BARU (KOSONGKAN JIKA TIDAK DIGANTI)', passwordController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: _dialogInputDecoration('ROLE'),
                  items: ['user', 'teknisi'].map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
            ),
            ElevatedButton(
              style: _dialogButtonStyle(const Color(0xFFD9614C)),
              onPressed: () async {
                final updatedUser = UserModel(
                  id: user.id,
                  name: nameController.text.trim(),
                  email: user.email,
                  role: selectedRole,
                  phone: phoneController.text.trim(),
                );
                
                final success = await context.read<AdminProvider>().updateUser(
                  updatedUser,
                  newPassword: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
                );
                
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User berhasil diperbarui')),
                  );
                  Navigator.pop(context);
                } else if (context.mounted) {
                  final error = context.read<AdminProvider>().errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error ?? 'Gagal memperbarui user')),
                  );
                }
              },
              child: Text('SIMPAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C1810), width: 4),
        ),
        title: Text('HAPUS USER?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        content: Text('Yakin ingin menghapus ${user.name}? Tindakan ini tidak dapat dibatalkan.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
          ),
          ElevatedButton(
            style: _dialogButtonStyle(const Color(0xFFD9614C)),
            onPressed: () async {
              final success = await context.read<AdminProvider>().deleteUser(user.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User berhasil dihapus')),
                );
                Navigator.pop(context);
              } else if (context.mounted) {
                final error = context.read<AdminProvider>().errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error ?? 'Gagal menghapus user')),
                );
              }
            },
            child: Text('HAPUS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          decoration: _dialogInputDecoration(null),
        ),
      ],
    );
  }

  InputDecoration _dialogInputDecoration(String? label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD9614C), width: 3),
      ),
    );
  }

  ButtonStyle _dialogButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2C1810), width: 2),
      ),
    );
  }
}
