import 'package:isar/isar.dart';

part 'isar_schemas.g.dart';

@collection
class CachedDashboard {
  Id id = 1;
  String homeDataJson = '';
  String revisionCardsJson = '';
  String performanceJson = '';
  DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(0);
}

@collection
class CachedTopicList {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String cacheKey;

  late String topicsJson;
  late DateTime cachedAt;
}
