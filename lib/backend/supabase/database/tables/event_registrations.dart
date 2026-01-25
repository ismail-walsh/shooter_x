import '../database.dart';

class EventRegistrationsTable extends SupabaseTable<EventRegistrationsRow> {
  @override
  String get tableName => 'event_registrations';

  @override
  EventRegistrationsRow createRow(Map<String, dynamic> data) =>
      EventRegistrationsRow(data);
}

class EventRegistrationsRow extends SupabaseDataRow {
  EventRegistrationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventRegistrationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get eventId => getField<String>('event_id');
  set eventId(String? value) => setField<String>('event_id', value);

  DateTime? get registeredAt => getField<DateTime>('registered_at');
  set registeredAt(DateTime? value) =>
      setField<DateTime>('registered_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
