import 'package:hive/hive.dart';
import 'package:nfc_csem/entity/tags_entity.dart';

class TagsProvider {
  var tagsBox = Hive.box<TagsEntity>('tags');
  List<TagsEntity> get tags => tagsBox.values.toList();

  saveTag(TagsEntity tag) {
    return tagsBox.add(tag);
  }

  void deleteTag(TagsEntity tag) {
    tagsBox.delete('${tag.id}');
  }

  List<TagsEntity> getTags() {
    return tags;
  }

  TagsEntity getTagsByDate(date) {
    return tags.firstWhere((tags) => tags.date == date, orElse: () => null);
  }
}