enum NetworthInputMethodEnum {
  manual,
  powens;

  static NetworthInputMethodEnum fromString(String value) {
    switch (value) {
      case 'manual':
        return manual;
      case 'powens':
        return powens;
      default:
        return manual;
    }
  }

  String get dbValue => name;
}
