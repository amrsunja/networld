extension DateTimeExtension on DateTime {
  DateTime onlyDate() {
    return DateTime(year, month, day);
  }
}
