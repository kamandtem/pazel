import 'package:shamsi_date/shamsi_date.dart';
String latinDigits(String input) {
  const fa = '۰۱۲۳۴۵۶۷۸۹', ar = '٠١٢٣٤٥٦٧٨٩';
  var s = input;
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
  }
  return s;
}
class Fmt {
  const Fmt(this.persian);
  final bool persian;
  String n(Object value) {
    var s = value.toString();
    if (persian) {
      for (var i = 0; i < 10; i++) { s = s.replaceAll('$i', '۰۱۲۳۴۵۶۷۸۹'[i]); }
    }
    return s;
  }
  String duration(int seconds) => n('${seconds ~/ 3600}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}');
  String timer(int seconds) => n('${(seconds ~/ 3600).toString().padLeft(2, '0')}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}');
  String clock(int minutes) => n('${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}');
  String date(DateTime d) {
    final j = Jalali.fromDateTime(d.toLocal());
    return n('${j.day} ${j.formatter.mN} ${j.year}');
  }
  String shortDate(DateTime d) {
    final j = Jalali.fromDateTime(d.toLocal());
    return n('${j.month}/${j.day}');
  }
  String dateInput(DateTime d) {
    final j = Jalali.fromDateTime(d);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }
  static DateTime? parseDate(String input) {
    final parts = latinDigits(input).split('/').map(int.tryParse).toList();
    if (parts.length != 3 || parts.any((p) => p == null)) return null;
    try { return Jalali(parts[0]!, parts[1]!, parts[2]!).toDateTime(); }
    catch (_) { return null; }
  }
  static int? parseClock(String input) {
    final parts = latinDigits(input).split(':').map(int.tryParse).toList();
    if (parts.length != 2 || parts.any((p) => p == null) || parts[0]! < 0 ||
      parts[0]! > 23 || parts[1]! < 0 || parts[1]! > 59) return null;
    return parts[0]! * 60 + parts[1]!;
  }
}
