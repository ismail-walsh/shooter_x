import '../database.dart';

class EventsTable extends SupabaseTable<EventsRow> {
  @override
  String get tableName => 'events';

  @override
  EventsRow createRow(Map<String, dynamic> data) => EventsRow(data);
}

class EventsRow extends SupabaseDataRow {
  EventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get clubId => getField<String>('club_id');
  set clubId(String? value) => setField<String>('club_id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  DateTime? get date => getField<DateTime>('date');
  set date(DateTime? value) => setField<DateTime>('date', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  int? get maxParticipants => getField<int>('max_participants');
  set maxParticipants(int? value) => setField<int>('max_participants', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get discipline => getField<String>('discipline');
  set discipline(String? value) => setField<String>('discipline', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
