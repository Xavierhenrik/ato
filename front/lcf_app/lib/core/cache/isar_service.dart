import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'isar_schemas.dart';

part 'isar_service.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isarService(IsarServiceRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance(Isar.defaultName)!;
  }
  return Isar.open(
    [CachedDashboardSchema, CachedTopicListSchema],
    directory: dir.path,
  );
}
