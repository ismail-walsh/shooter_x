import '../database.dart';

class EventPassesTable extends SupabaseTable<EventPassesRow> {
  @override
  String get tableName => 'event_passes';

  @override
  EventPassesRow createRow(Map<String, dynamic> data) => EventPassesRow(data);
}

class EventPassesRow extends SupabaseDataRow {
  EventPassesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventPassesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get registrationId => getField<String>('registration_id');
  set registrationId(String? value) =>
      setField<String>('registration_id', value);

  String? get qrCodeUrl => getField<String>('qr_code_url');
  set qrCodeUrl(String? value) => setField<String>('qr_code_url', value);

  DateTime? get passExpiry => getField<DateTime>('pass_expiry');
  set passExpiry(DateTime? value) => setField<DateTime>('pass_expiry', value);

  DateTime? get generatedAt => getField<DateTime>('generated_at');
  set generatedAt(DateTime? value) => setField<DateTime>('generated_at', value);
}
