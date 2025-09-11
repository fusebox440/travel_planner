import 'package:hive/hive.dart';

part 'item_category.g.dart';

@HiveType(typeId: 25) // Enum Types range 20-29, next available is 25
enum ItemCategory {
  @HiveField(0)
  Clothing,
  @HiveField(1)
  Electronics,
  @HiveField(2)
  Toiletries,
  @HiveField(3)
  Documents,
  @HiveField(4)
  Medication,
  @HiveField(5)
  Other
}
