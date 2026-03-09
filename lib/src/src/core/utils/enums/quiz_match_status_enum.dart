enum QuizMatchStatusEnum {
  searching,
  active,
  finished;

  static QuizMatchStatusEnum fromString(String value) {
    switch (value) {
      case 'searching':
        return searching;
      case 'active':
        return active;
      case 'finished':
        return finished;
      default:
        return searching;
    }
  }

  String get dbValue => name;
}
