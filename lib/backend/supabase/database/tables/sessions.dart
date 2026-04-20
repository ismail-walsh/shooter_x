import '../database.dart';

class SessionsTable extends SupabaseTable<SessionsRow> {
  @override
  String get tableName => 'sessions';

  @override
  SessionsRow createRow(Map<String, dynamic> data) => SessionsRow(data);
}

class SessionsRow extends SupabaseDataRow {
  SessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get discipline => getField<String>('discipline');
  set discipline(String? value) => setField<String>('discipline', value);

  String? get firearm => getField<String>('firearm');
  set firearm(String? value) => setField<String>('firearm', value);

  String? get ammoType => getField<String>('ammo_type');
  set ammoType(String? value) => setField<String>('ammo_type', value);

  int? get distance => getField<int>('distance');
  set distance(int? value) => setField<int>('distance', value);

  dynamic? get conditions => getField<dynamic>('conditions');
  set conditions(dynamic? value) => setField<dynamic>('conditions', value);

  double? get accuracy => getField<double>('accuracy');
  set accuracy(double? value) => setField<double>('accuracy', value);

  int? get hits => getField<int>('hits');
  set hits(int? value) => setField<int>('hits', value);

  int? get totalShots => getField<int>('total_shots');
  set totalShots(int? value) => setField<int>('total_shots', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get targetImageUrl => getField<String>('target_image_url');
  set targetImageUrl(String? value) =>
      setField<String>('target_image_url', value);

  String? get competitionId => getField<String>('competition_id');
  set competitionId(String? value) => setField<String>('competition_id', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  bool? get isPersonalBest => getField<bool>('is_personal_best');
  set isPersonalBest(bool? value) => setField<bool>('is_personal_best', value);

  double? get groupSizeMm => getField<double>('group_size_mm');
  set groupSizeMm(double? value) => setField<double>('group_size_mm', value);

  String? get bestRing => getField<String>('best_ring');
  set bestRing(String? value) => setField<String>('best_ring', value);

  double? get spreadMm => getField<double>('spread_mm');
  set spreadMm(double? value) => setField<double>('spread_mm', value);

  String? get weatherConditions => getField<String>('weather_conditions');
  set weatherConditions(String? value) =>
      setField<String>('weather_conditions', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);
}
