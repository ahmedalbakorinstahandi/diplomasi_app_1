import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoicePdfPreviewScreen extends StatefulWidget {
  final String invoiceNumber;
  final String pdfUrl;

  const InvoicePdfPreviewScreen({
    super.key,
    required this.invoiceNumber,
    required this.pdfUrl,
  });

  @override
  State<InvoicePdfPreviewScreen> createState() =>
      _InvoicePdfPreviewScreenState();
}

class _InvoicePdfPreviewScreenState extends State<InvoicePdfPreviewScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final viewerUrl = Uri.parse(
      'https://docs.google.com/gview?embedded=1&url=${Uri.encodeComponent(widget.pdfUrl)}',
    );

    // final viewerUrl = Uri.parse(widget.pdfUrl);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _errorText = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorText = 'تعذر عرض الفاتورة. تحقق من الرابط أو الشبكة.';
            });
          },
        ),
      )
      ..loadRequest(viewerUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(title: Text('فاتورة ${widget.invoiceNumber}')),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorText != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_errorText!, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
