import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mix/mix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelee/core/config/supabase_config.dart';
import 'package:travelee/data/services/travel_sync_service.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'package:travelee/presentation/screens/home/first_screen.dart';
import 'package:travelee/presentation/screens/settings/legal_document_screen.dart';
import 'package:travelee/providers/loading_state_provider.dart';
import 'package:travelee/providers/travel_state_provider.dart';

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

  Future<void> signOut() async {
    /// 로그아웃
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              ref.read(loadingStateProvider.notifier).startLoading(
                    message: '로그아웃 중...',
                  );
              await Supabase.instance.client.auth.signOut();
              await GoogleSignIn().signOut();

              /// 로컬 데이터 삭제
              ref.read(travelsProvider.notifier).clear();
              Navigator.pop(context);
              if (!mounted) return;
              context.go(FirstScreen.routePath);
              ref.read(loadingStateProvider.notifier).stopLoading();
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    /// 확인 팝업 추가
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('회원탈퇴 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              ref.read(loadingStateProvider.notifier).startLoading(
                    message: '회원탈퇴 중...',
                  );
              final travelSyncService =
                  TravelSyncService(SupabaseConfig.client);
              await travelSyncService.deleteUser();
              await GoogleSignIn().signOut();
              ref.read(travelsProvider.notifier).clear();
              if (!mounted) return;
              context.go(FirstScreen.routePath);
              ref.read(loadingStateProvider.notifier).stopLoading();
            },
            child: const Text('탈퇴'),
          ),
        ],
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
            title: AppLocalizations.of(context)!.syncData,
            onTap: () {
              ref.read(loadingStateProvider.notifier).startLoading(
                    message: '데이터 백업 중...',
                  );
              /// 데이터 백업
              final travelSyncService =
                  TravelSyncService(SupabaseConfig.client);
              travelSyncService.saveTravels(ref.read(travelsProvider));
              ref.read(loadingStateProvider.notifier).stopLoading();
            },
          ),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.privacyPolicy,
            onTap: () {
              context.push(
                LegalDocumentScreen.routePath,
                extra: {
                  'title': AppLocalizations.of(context)!.privacyPolicy,
                  'type': 'privacy',
                },
              );
            },
          ),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.termsOfService,
            onTap: () {
              context.push(
                LegalDocumentScreen.routePath,
                extra: {
                  'title': AppLocalizations.of(context)!.termsOfService,
                  'type': 'terms',
                },
              );
            },
          ),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.version,
            trailing: DinoText.custom(
              fontSize: DinoTextSizeToken.text100,
              text: _appVersion,
              color: $dinoToken.color.blingGray500,
            ),
          ),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.logout,
            onTap: () {
              /// 로그아웃
              /// 로컬 데이터 삭제
              /// 처음 화면으로 이동
              signOut();
            },
          ),
          _buildSettingItem(
            title: AppLocalizations.of(context)!.withdraw,
            color: $dinoToken.color.brandBlingRed500,
            onTap: () {
              /// 회원탈퇴
              /// 로컬 데이터 삭제
              /// 서버 데이터 삭제
              /// 처음 화면으로 이동
              deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    String icon = '',
    required String title,
    ColorToken? color,
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
          color: color ?? $dinoToken.color.blingGray900,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
