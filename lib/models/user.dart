// mengimplementasikan model data pengguna
// menyimpan data utama seperti id, username, nama, email, dan nomor telepon
class User {
  // menyimpan id unik pengguna
  final String id;

  // menyimpan nama pengguna untuk autentikasi
  final String username;

  // menyimpan nama lengkap pengguna
  final String name;

  // menyimpan alamat email pengguna
  final String email;

  // menyimpan nomor telepon pengguna
  final String phoneNumber;

  // menyimpan url gambar profil pengguna
  final String profileImageUrl;

  // menginisialisasi objek user baru
  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl = '',
  });

  // mengonversi objek user menjadi string untuk debugging
  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, email: $email, phoneNumber: $phoneNumber)';
  }

  // membuat salinan objek user dengan memperbarui nilai tertentu
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
