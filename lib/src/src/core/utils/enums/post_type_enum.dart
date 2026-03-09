enum PostTypeEnum {
  standard,
  poll;

  static PostTypeEnum fromString(String value) {
    switch (value) {
      case 'standard':
        return standard;
      case 'poll':
        return poll;
      default:
        return standard;
    }
  }

  String get dbValue => name;
}
