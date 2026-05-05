import 'package:flutter/foundation.dart';
import 'package:golf_society/design_system/design_system.dart';

class BoxyArtErrorHandler extends StatefulWidget {
  final Widget child;

  const BoxyArtErrorHandler({super.key, required this.child});

  @override
  State<BoxyArtErrorHandler> createState() => _BoxyArtErrorHandlerState();
}

class _BoxyArtErrorHandlerState extends State<BoxyArtErrorHandler> {
  bool _hasError = false;
  String _errorDetails = '';

  @override
  void initState() {
    super.initState();
    // Catch build errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _buildErrorUI(details.exceptionAsString());
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) debugPrint('Caught Global Async Error: $error');
      setState(() {
        _hasError = true;
        _errorDetails = error.toString();
      });
      return true;
    };
  }

  Widget _buildErrorUI(String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: BoxyArtEmptyCard(
            title: 'Oops! Something went wrong',
            message: 'The application encountered an unexpected error. Our team has been notified.',
            icon: Icons.error_outline_rounded,
            actionLabel: 'RELOAD APP',
            onAction: () {
              setState(() {
                _hasError = false;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorUI(_errorDetails);
    }
    return widget.child;
  }
}
