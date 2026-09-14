import 'web_helpers_stub.dart' if (dart.library.html) 'web_helpers_web.dart';

class WebHelpers {
  static void openUrl(String url) {
    openUrlImpl(url);
  }

  static void downloadJson(String fileName, String jsonString) {
    downloadJsonImpl(fileName, jsonString);
  }
}
