import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalDocumentScreen extends ConsumerStatefulWidget {
  static const routeName = 'legal_document';
  static const routePath = '/legal_document';

  final String title;
  final String type; // 'privacy' or 'terms'

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  ConsumerState<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends ConsumerState<LegalDocumentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initWebView();
      _initialized = true;
    }
  }

  Future<void> _initWebView() async {
    final locale = AppLocalizations.of(context)?.localeName ?? 'en';
    final isKorean = locale == 'ko';
    
    final String assetPath;
    if (widget.type == 'privacy') {
      assetPath = isKorean ? 'assets/privacyPolicy_k.html' : 'assets/privacyPolicy_e.html';
    } else {
      assetPath = isKorean ? 'assets/termsOfService_k.html' : 'assets/termsOfService_e.html';
    }

    final String htmlContent = await rootBundle.loadString(assetPath);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadHtmlString(htmlContent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Align(
          alignment: Alignment.centerLeft,
          child: DinoText.custom(
            fontSize: 17,
            text: widget.title,
            color: $dinoToken.color.blingGray900,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: SvgPicture.asset(
            'assets/icons/topappbar_back.svg',
            colorFilter: ColorFilter.mode(
              $dinoToken.color.blingGray900.resolve(context),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (!_isLoading) WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 