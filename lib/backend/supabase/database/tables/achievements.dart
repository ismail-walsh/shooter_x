import '../database.dart';

class AchievementsTable extends SupabaseTable<AchievementsRow> {
  @override
  String get tableName => 'achievements';

  @override
  AchievementsRow createRow(Map<String, dynamic> data) => AchievementsRow(data);
}

class AchievementsRow extends SupabaseDataRow {
  AchievementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AchievementsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  dynamic? get criteria => getField<dynamic>('criteria');
  set criteria(dynamic? value) => setField<dynamic>('criteria', value);

  String? get iconUrl => getField<String>('icon_url');
  set iconUrl(String? value) => setField<String>('icon_url', value);
}
