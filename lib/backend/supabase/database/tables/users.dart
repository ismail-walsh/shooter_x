import '../database.dart';

class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  UsersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UsersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get email => getField<String>('email')!;
  set email(String value) => setField<String>('email', value);

  String get username => getField<String>('username')!;
  set username(String value) => setField<String>('username', value);

  String get passwordHash => getField<String>('password_hash')!;
  set passwordHash(String value) => setField<String>('password_hash', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  String? get preferredDiscipline => getField<String>('preferred_discipline');
  set preferredDiscipline(String? value) =>
      setField<String>('preferred_discipline', value);

  String? get profileImg => getField<String>('profile_img');
  set profileImg(String? value) => setField<String>('profile_img', value);

  String? get coverImg => getField<String>('cover_img');
  set coverImg(String? value) => setField<String>('cover_img', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  int? get level => getField<int>('level');
  set level(int? value) => setField<int>('level', value);

  int? get totalXp => getField<int>('total_xp');
  set totalXp(int? value) => setField<int>('total_xp', value);
}
