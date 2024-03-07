class CIStep {
  String name;
  bool isCompulsory;
  int position;
  String slug;
  Map<String, List<dynamic>> properties; // Holds property options
  Map<String, dynamic> defaultProperties; // Holds default values for properties

  CIStep({
    required this.name,
    this.isCompulsory = false,
    required this.position,
    Map<String, List<dynamic>>? properties,
    Map<String, dynamic>? defaultProperties,
  })  : slug = name.toLowerCase().replaceAll(' ', '-'),
        properties = properties ?? {},
        defaultProperties = defaultProperties ?? {} {
    // Ensure default properties are valid
    _validateDefaultProperties();
  }

  void _validateDefaultProperties() {
    defaultProperties.forEach((key, value) {
      if (!properties.containsKey(key) || !properties[key]!.contains(value)) {
        throw ArgumentError(
            'Default property `$key` with value `$value` is not a valid option.');
      }
    });
  }

  // Optional: Method to set default properties based on step name
  void setDefaultProperties() {
    if (slug.contains('build-android-app') && properties.isEmpty) {
      properties = {
        'binary': ['apk', 'aab'],
      };
      defaultProperties = {
        'binary': 'apk',
      };
    }
    if (slug.contains('run-tests') && properties.isEmpty) {
      properties = {
        'coverage': ['with', 'without']
      };
      defaultProperties = {'coverage': 'with'};
    }
  }
}
