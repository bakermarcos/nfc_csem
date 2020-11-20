import 'package:hive/hive.dart';
import 'package:nfc_csem/entity/tags_entity.dart';
import "package:collection/collection.dart";

class TagsProvider {
  var tagsBox = Hive.box<TagsEntity>('tags');
  List<TagsEntity> get tags => tagsBox.values.toList();

  saveTag(TagsEntity tag) {
    return tagsBox.add(tag);
  }

  filterTag(id) {
    var newMap = groupBy(tags, (obj) => obj.id).map(
    (k, v) => MapEntry(k, v.map((item) {  return item;}).toList()));
    print(newMap);
    return newMap;
  }

  void deleteTag(TagsEntity tag) {
    tagsBox.delete(tag.key);
  }

  List<TagsEntity> getTags() {
    return tags;
  }

  TagsEntity getTagsByDate(date) {
    return tags.firstWhere((tags) => tags.date == date, orElse: () => null);
  }

}
