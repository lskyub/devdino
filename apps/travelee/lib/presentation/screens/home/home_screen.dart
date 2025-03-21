import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart'
    as travel_providers;
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'package:travelee/core/utils/travel_dialog_manager.dart';
import 'package:travelee/presentation/widgets/ad_banner_widget.dart';
import 'dart:developer' as dev;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 50,
        ),
        child: Column(
          children: [
            const AdBannerWidget(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                state: B2bButtonState.base,
                title: '새 여행 만들기',
                type: B2bButtonType.primary,
                onTap: () {
                  // ... existing code ...
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 