class User {
  final String id;
  final String username;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }
}
