import '../database.dart';

class ClubPostsTable extends SupabaseTable<ClubPostsRow> {
  @override
  String get tableName => 'club_posts';

  @override
  ClubPostsRow createRow(Map<String, dynamic> data) => ClubPostsRow(data);
}

class ClubPostsRow extends SupabaseDataRow {
  ClubPostsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClubPostsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get clubId => getField<String>('club_id');
  set clubId(String? value) => setField<String>('club_id', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  String? get mediaUrl => getField<String>('media_url');
  set mediaUrl(String? value) => setField<String>('media_url', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
