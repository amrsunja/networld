enum ReportStatusEnum {
  pending,
  resolved,
  dismissed;

  static ReportStatusEnum fromString(String value) {
    switch (value) {
      case 'pending':
        return pending;
      case 'resolved':
        return resolved;
      case 'dismissed':
        return dismissed;
      default:
        return pending;
    }
  }

  String get dbValue => name;
}
