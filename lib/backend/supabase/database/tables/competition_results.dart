import '../database.dart';

class CompetitionResultsTable extends SupabaseTable<CompetitionResultsRow> {
  @override
  String get tableName => 'competition_results';

  @override
  CompetitionResultsRow createRow(Map<String, dynamic> data) =>
      CompetitionResultsRow(data);
}

class CompetitionResultsRow extends SupabaseDataRow {
  CompetitionResultsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CompetitionResultsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get eventId => getField<String>('event_id');
  set eventId(String? value) => setField<String>('event_id', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);

  int? get rank => getField<int>('rank');
  set rank(int? value) => setField<int>('rank', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
