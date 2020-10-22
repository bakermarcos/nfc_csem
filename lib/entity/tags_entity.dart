import 'package:hive/hive.dart';

part 'tags_entity.g.dart';

@HiveType(typeId: 1)
class TagsEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String date;

  @HiveField(2)
  String temperature;

  TagsEntity({this.id, this.date, this.temperature});
}
