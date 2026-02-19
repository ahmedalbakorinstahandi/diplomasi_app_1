import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoicePdfPreviewScreen extends StatefulWidget {
  final String invoiceNumber;
  final String pdfBase64;

  const InvoicePdfPreviewScreen({
    super.key,
    required this.invoiceNumber,
    required this.pdfBase64,
  });

  @override
  State<InvoicePdfPreviewScreen> createState() =>
      _InvoicePdfPreviewScreenState();
}

class _InvoicePdfPreviewScreenState extends State<InvoicePdfPreviewScreen> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildHtml(widget.pdfBase64));
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(title: Text('فاتورة ${widget.invoiceNumber}')),
      body: WebViewWidget(controller: _webViewController),
    );
  }

  String _buildHtml(String base64) {
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: #f5f5f5;
      }
      embed {
        width: 100%;
        height: 100%;
        border: none;
      }
    </style>
  </head>
  <body>
    <embed src="data:application/pdf;base64,$base64" type="application/pdf" />
  </body>
</html>
''';
  }
}
