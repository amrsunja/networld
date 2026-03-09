enum PostStatusEnum {
  published,
  review,
  rejected,
  deleted;

  static PostStatusEnum fromString(String value) {
    switch (value) {
      case 'published':
        return published;
      case 'review':
        return review;
      case 'rejected':
        return rejected;
      case 'deleted':
        return deleted;
      default:
        return published;
    }
  }

  String get dbValue => name;
}
