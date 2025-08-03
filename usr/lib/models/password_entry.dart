class PasswordEntry {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String notes;
  final String userId;

  PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.notes = '',
    required this.userId,
  });

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'],
      title: map['title'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'] ?? '',
      userId: map['user_id'] ?? '',
    );
  }
}
