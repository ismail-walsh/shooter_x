import '../database.dart';

class ClubsTable extends SupabaseTable<ClubsRow> {
  @override
  String get tableName => 'clubs';

  @override
  ClubsRow createRow(Map<String, dynamic> data) => ClubsRow(data);
}

class ClubsRow extends SupabaseDataRow {
  ClubsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClubsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  String? get discipline => getField<String>('discipline');
  set discipline(String? value) => setField<String>('discipline', value);

  bool? get isPrivate => getField<bool>('is_private');
  set isPrivate(bool? value) => setField<bool>('is_private', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get websiteUrl => getField<String>('website_url');
  set websiteUrl(String? value) => setField<String>('website_url', value);

  String? get profileImg => getField<String>('profile_img');
  set profileImg(String? value) => setField<String>('profile_img', value);

  String? get coverImg => getField<String>('cover_img');
  set coverImg(String? value) => setField<String>('cover_img', value);

  String? get userClub => getField<String>('user_club');
  set userClub(String? value) => setField<String>('user_club', value);

  bool? get hoApproved => getField<bool>('ho_approved');
  set hoApproved(bool? value) => setField<bool>('ho_approved', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get openingHours => getField<String>('opening_hours');
  set openingHours(String? value) => setField<String>('opening_hours', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);
}
