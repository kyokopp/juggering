class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isFavorite;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = '',
    this.isFavorite = false,
  });

  factory Contact.fromMap(Map<String, dynamic> data, String documentId) {
    return Contact(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isFavorite': isFavorite,
      'createdAt': DateTime.now(),
    };
  }
}