import '../database.dart';

class RangesTable extends SupabaseTable<RangesRow> {
  @override
  String get tableName => 'ranges';

  @override
  RangesRow createRow(Map<String, dynamic> data) => RangesRow(data);
}

class RangesRow extends SupabaseDataRow {
  RangesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RangesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  String? get discipline => getField<String>('discipline');
  set discipline(String? value) => setField<String>('discipline', value);

  dynamic? get certificationsOffered =>
      getField<dynamic>('certifications_offered');
  set certificationsOffered(dynamic? value) =>
      setField<dynamic>('certifications_offered', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  bool? get isOpen => getField<bool>('is_open');
  set isOpen(bool? value) => setField<bool>('is_open', value);

  String? get openingHours => getField<String>('opening_hours');
  set openingHours(String? value) => setField<String>('opening_hours', value);

  String? get websiteUrl => getField<String>('website_url');
  set websiteUrl(String? value) => setField<String>('website_url', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);
}
