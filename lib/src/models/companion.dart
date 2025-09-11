import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'companion.g.dart';

@HiveType(typeId: 5) // Core models range 0-9
class Companion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phone;

  Companion({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory Companion.create({
    required String name,
    String? email,
    String? phone,
  }) {
    return Companion(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
    );
  }

  Companion copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return Companion(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory Companion.fromJson(Map<String, dynamic> json) {
    return Companion(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
