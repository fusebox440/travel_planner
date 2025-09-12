import 'package:hive/hive.dart';

part 'item_category.g.dart';

@HiveType(typeId: 27) // Enum Types range 20-29, next available is 27
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
