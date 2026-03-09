enum ReportCategoryEnum {
  spam,
  harassment,
  inappropriate,
  other;

  static ReportCategoryEnum fromString(String value) {
    switch (value) {
      case 'spam':
        return spam;
      case 'harassment':
        return harassment;
      case 'inappropriate':
        return inappropriate;
      case 'other':
        return other;
      default:
        return other;
    }
  }

  String get dbValue => name;
}
