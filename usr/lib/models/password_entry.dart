import 'package:hive/hive.dart';

part 'password_entry.g.dart';

@HiveType(typeId: 0)
class PasswordEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  @HiveField(3)
  String notes;

  PasswordEntry({
    required this.title,
    required this.username,
    required this.password,
    this.notes = '',
  });
}
