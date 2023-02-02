class MppmTemplate {
  Map<String, Object> basicTemplate(String projectName) {
    return {
      'name': projectName,
      'packages': ['packages/*'],
      'common_dependencies': {'path': 'any'},
      'common_dev_dependencies': {'mocktail': 'any'},
    };
  }
}
