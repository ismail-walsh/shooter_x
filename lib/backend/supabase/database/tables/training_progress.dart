import '../database.dart';

class TrainingProgressTable extends SupabaseTable<TrainingProgressRow> {
  @override
  String get tableName => 'training_progress';

  @override
  TrainingProgressRow createRow(Map<String, dynamic> data) =>
      TrainingProgressRow(data);
}

class TrainingProgressRow extends SupabaseDataRow {
  TrainingProgressRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TrainingProgressTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get trainingType => getField<String>('training_type');
  set trainingType(String? value) => setField<String>('training_type', value);

  String? get module => getField<String>('module');
  set module(String? value) => setField<String>('module', value);

  double? get progress => getField<double>('progress');
  set progress(double? value) => setField<double>('progress', value);

  DateTime? get lastUpdated => getField<DateTime>('last_updated');
  set lastUpdated(DateTime? value) => setField<DateTime>('last_updated', value);
}
