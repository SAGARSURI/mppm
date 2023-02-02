import 'package:dcli/dcli.dart';

const mppmFilePath = 'mppm.yaml';
const pubspecFileName = 'pubspec.yaml';

bool isDartProject() {
  return exists('pubspec.yaml') && exists('lib');
}

String mppmTemplate(String projectName) {
  return """
name: $projectName

packages:
  #- packages/*
  
common_dependencies:
  #path: 1.8.1
  
common_dev_dependencies:  
  #lints: 1.0.1 
""".trim();
}