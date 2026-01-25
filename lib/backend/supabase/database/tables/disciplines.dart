import '../database.dart';

class DisciplinesTable extends SupabaseTable<DisciplinesRow> {
  @override
  String get tableName => 'disciplines';

  @override
  DisciplinesRow createRow(Map<String, dynamic> data) => DisciplinesRow(data);
}

class DisciplinesRow extends SupabaseDataRow {
  DisciplinesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DisciplinesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get clubs => getField<String>('clubs');
  set clubs(String? value) => setField<String>('clubs', value);

  String? get disciplineName => getField<String>('discipline_name');
  set disciplineName(String? value) =>
      setField<String>('discipline_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);
}
