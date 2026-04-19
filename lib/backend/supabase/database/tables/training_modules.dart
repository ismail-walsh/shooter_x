import '../database.dart';

class TrainingModulesTable extends SupabaseTable<TrainingModulesRow> {
  @override
  String get tableName => 'training_modules';

  @override
  TrainingModulesRow createRow(Map<String, dynamic> data) =>
      TrainingModulesRow(data);
}

class TrainingModulesRow extends SupabaseDataRow {
  TrainingModulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TrainingModulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get discipline => getField<String>('discipline');
  set discipline(String? value) => setField<String>('discipline', value);

  int? get duration => getField<int>('duration');
  set duration(int? value) => setField<int>('duration', value);

  String? get level => getField<String>('level');
  set level(String? value) => setField<String>('level', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);
}
