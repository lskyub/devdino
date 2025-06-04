import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:flutter/material.dart';
import 'package:design_systems/dino/dino.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          child,
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      DinoText.custom(
                        text: message!,
                        fontSize: 16,
                        color: $dinoToken.color.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
