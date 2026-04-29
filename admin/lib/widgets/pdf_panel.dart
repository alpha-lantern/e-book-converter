import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfPanel extends StatelessWidget {
  final String? pdfUrl;

  const PdfPanel({super.key, this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    if (pdfUrl == null || pdfUrl!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No PDF available to display.'),
          ],
        ),
      );
    }

    return PdfViewer.uri(
      Uri.parse(pdfUrl!),
    );
  }
}
