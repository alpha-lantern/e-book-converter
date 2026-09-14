import 'dart:js_interop';
import 'package:web/web.dart' as web;

void openUrlImpl(String url) {
  web.window.open(url, '_blank');
}

void downloadJsonImpl(String fileName, String jsonString) {
  final blob = web.Blob(
    [jsonString.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final blobUrl = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = blobUrl;
  anchor.download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(blobUrl);
}
