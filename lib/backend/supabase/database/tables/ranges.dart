import '../database.dart';

class RangesTable extends SupabaseTable<RangesRow> {
  @override
  String get tableName => 'ranges';

  @override
  RangesRow createRow(Map<String, dynamic> data) => RangesRow(data);
}

class RangesRow extends SupabaseDataRow {
  RangesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RangesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  String? get discipline => getField<String>('discipline');
  set discipline(String? value) => setField<String>('discipline', value);

  dynamic? get certificationsOffered =>
      getField<dynamic>('certifications_offered');
  set certificationsOffered(dynamic? value) =>
      setField<dynamic>('certifications_offered', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
