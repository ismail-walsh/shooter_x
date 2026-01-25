import '../database.dart';

class ProgressDetailsTable extends SupabaseTable<ProgressDetailsRow> {
  @override
  String get tableName => 'progress_details';

  @override
  ProgressDetailsRow createRow(Map<String, dynamic> data) =>
      ProgressDetailsRow(data);
}

class ProgressDetailsRow extends SupabaseDataRow {
  ProgressDetailsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProgressDetailsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get trainingId => getField<String>('training_id');
  set trainingId(String? value) => setField<String>('training_id', value);

  String? get lesson => getField<String>('lesson');
  set lesson(String? value) => setField<String>('lesson', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);
}
