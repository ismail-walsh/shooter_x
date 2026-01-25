import '../database.dart';

class ClubMembershipsTable extends SupabaseTable<ClubMembershipsRow> {
  @override
  String get tableName => 'club_memberships';

  @override
  ClubMembershipsRow createRow(Map<String, dynamic> data) =>
      ClubMembershipsRow(data);
}

class ClubMembershipsRow extends SupabaseDataRow {
  ClubMembershipsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClubMembershipsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get clubId => getField<String>('club_id');
  set clubId(String? value) => setField<String>('club_id', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);
}
