// model untuk data pengguna aplikasi
// untuk menyimpan informasi dasar pengguna seperti id, username
// nama lengkap, email, dan nomor telepon
class User {
  // ID unik pengguna
  final String id;

  // username untuk login
  final String username;

  // nama lengkap pengguna
  final String name;

  // alamat email pengguna
  final String email;

  // nomor telepon pengguna
  final String phoneNumber;

  // URL gambar profil pengguna
  final String profileImageUrl;

  // constructor untuk membuat objek user baru
  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl = '',
  });

  // mengubah objek User menjadi string untuk keperluan debugging
  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, email: $email, phoneNumber: $phoneNumber)';
  }

  // membuat salinan objek user dengan nilai yang diperbarui
  User copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
