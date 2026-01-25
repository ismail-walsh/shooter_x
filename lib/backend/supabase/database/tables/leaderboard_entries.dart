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

  String? get clubId => getField<String>('club_id');
  set clubId(String? value) => setField<String>('club_id', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get competitionId => getField<String>('competition_id');
  set competitionId(String? value) => setField<String>('competition_id', value);
}
