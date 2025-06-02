import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travelee/gen/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = 'settings';
  static const routePath = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
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
            text: AppLocalizations.of(context)!.settings,
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
      body: ListView(
        children: [
          _buildSettingItem(
            icon: 'assets/icons/remove_ads.svg',
            title: AppLocalizations.of(context)!.removeAds,
            onTap: () {
              // TODO: 광고 제거 인앱 결제 구현
            },
          ),
          _buildSettingItem(
            icon: 'assets/icons/info.svg',
            title: AppLocalizations.of(context)!.version,
            trailing: DinoText.custom(
              fontSize: DinoTextSizeToken.text100,
              text: _appVersion,
              color: $dinoToken.color.blingGray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      // leading: SvgPicture.asset(
      //   icon,
      //   width: 24,
      //   height: 24,
      //   colorFilter: ColorFilter.mode(
      //     $dinoToken.color.blingGray900.resolve(context),
      //     BlendMode.srcIn,
      //   ),
      // ),
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: DinoText.custom(
          fontSize: 16,
          text: title,
          color: $dinoToken.color.blingGray900,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
