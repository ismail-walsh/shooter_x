import '../database.dart';

class MembershipCardsTable extends SupabaseTable<MembershipCardsRow> {
  @override
  String get tableName => 'membership_cards';

  @override
  MembershipCardsRow createRow(Map<String, dynamic> data) =>
      MembershipCardsRow(data);
}

class MembershipCardsRow extends SupabaseDataRow {
  MembershipCardsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembershipCardsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get clubId => getField<String>('club_id');
  set clubId(String? value) => setField<String>('club_id', value);

  String get cardNumber => getField<String>('card_number')!;
  set cardNumber(String value) => setField<String>('card_number', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  String? get barcodeUrl => getField<String>('barcode_url');
  set barcodeUrl(String? value) => setField<String>('barcode_url', value);

  DateTime? get issuedAt => getField<DateTime>('issued_at');
  set issuedAt(DateTime? value) => setField<DateTime>('issued_at', value);
}
