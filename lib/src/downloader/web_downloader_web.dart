// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadFile(String yamlContent, String fileName) {
  final blob = html.Blob([yamlContent]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
