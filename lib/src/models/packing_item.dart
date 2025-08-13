import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'packing_item.g.dart';

@HiveType(typeId: 4) // Use the next available typeId
class PackingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  bool isChecked;

  PackingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
  });

  factory PackingItem.create({required String name}) {
    return PackingItem(id: const Uuid().v4(), name: name);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isChecked: json['isChecked'] as bool,
    );
  }
}