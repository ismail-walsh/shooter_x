import '../database.dart';

class LeaderboardEntriesTable extends SupabaseTable<LeaderboardEntriesRow> {
  @override
  String get tableName => 'leaderboard_entries';

  @override
  LeaderboardEntriesRow createRow(Map<String, dynamic> data) =>
      LeaderboardEntriesRow(data);
}

class LeaderboardEntriesRow extends SupabaseDataRow {
  LeaderboardEntriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaderboardEntriesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get eventId => getField<String>('event_id');
  set eventId(String? value) => setField<String>('event_id', value);

  String? get competitionName => getField<String>('competition_name');
  set competitionName(String? value) =>
      setField<String>('competition_name', value);

  int? get rank => getField<int>('rank');
  set rank(int? value) => setField<int>('rank', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);

  int? get level => getField<int>('level');
  set level(int? value) => setField<int>('level', value);

  int? get xp => getField<int>('xp');
  set xp(int? value) => setField<int>('xp', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get scope => getField<String>('scope');
  set scope(String? value) => setField<String>('scope', value);

  String? get profileImg => getField<String>('profile_img');
  set profileImg(String? value) => setField<String>('profile_img', value);
}
