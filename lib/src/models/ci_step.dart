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
    setDefaultProperties();
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
    if (slug.contains('runs-on') && properties.isEmpty) {
      properties = {
        'runner': ['ubuntu-latest', 'windows-latest', 'macos-latest'],
      };
      defaultProperties = {
        'runner': 'ubuntu-latest',
      };
    }
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

    if (slug.contains('setup-&-cache-flutter') && properties.isEmpty) {
      properties = {
        'cache': ['with', 'without'],
        'flutterVersion': [],
      };
      defaultProperties = {'cache': 'with', 'flutterVersion': 'stable'};
    }

    if (slug.contains('trigger-events') && properties.isEmpty) {
      properties = {
        'events': ['push', 'pull_request', 'release', 'workflow_dispatch']
      };
      defaultProperties = {'events': 'push'};
    }
  }

  // @override
  // bool operator ==(Object other) {
  //   // if (identical(this, other)) return true;
  //   if (other is! CIStep) return false;
  //   return name == other.name &&
  //       isCompulsory == other.isCompulsory &&
  //       position == other.position &&
  //       slug == other.slug &&
  //       _mapsEqual(defaultProperties, other.defaultProperties);
  // }

  // @override
  // int get hashCode => _mapHashCode(defaultProperties);

  // // Helper function to compare maps
  // bool _mapsEqual(Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
  //   if (map1.length != map2.length) return false;
  //   for (var key in map1.keys) {
  //     if (!map2.containsKey(key) || map2[key] != map1[key]) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  // // Generates a hash code for a map
  // int _mapHashCode(Map<dynamic, dynamic> map) {
  //   int hashCode = 0;
  //   map.forEach((key, value) {
  //     hashCode ^= key.hashCode ^ value.hashCode;
  //   });
  //   return hashCode;
  // }
}
