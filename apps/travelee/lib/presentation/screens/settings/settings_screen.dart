import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mix/mix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelee/core/config/supabase_config.dart';
import 'package:travelee/data/datasources/remote/travel_sync_service.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'package:travelee/presentation/screens/home/first_screen.dart';
import 'package:travelee/presentation/screens/settings/legal_document_screen.dart';
import 'package:travelee/presentation/providers/loading_state_provider.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart';
import 'package:travelee/presentation/widgets/ad_banner_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = 'settings';
  static const routePath = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  String? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadLastBackupTime();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupTimeString = prefs.getString('lastBackupTime');
    if (lastBackupTimeString != null) {
      final lastBackupDateTime = DateTime.parse(lastBackupTimeString);
      final now = DateTime.now();
      final difference = now.difference(lastBackupDateTime);
      
      String displayTime;
      if (difference.inMinutes < 1) {
        displayTime = AppLocalizations.of(context)!.justNow;
      } else if (difference.inHours < 1) {
        displayTime = AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
      } else if (difference.inDays < 1) {
        displayTime = AppLocalizations.of(context)!.hoursAgo(difference.inHours);
      } else {
        displayTime = AppLocalizations.of(context)!.daysAgo(difference.inDays);
      }
      
      setState(() {
        _lastBackupTime = displayTime;
      });
    } else {
      setState(() {
        _lastBackupTime = null;
      });
    }
  }

  Future<void> signOut() async {
    /// 로그아웃
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.logout),
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
        title: Text(AppLocalizations.of(context)!.withdraw),
        content: Text(AppLocalizations.of(context)!.withdrawConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.withdraw),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSettingItem(
                    title: AppLocalizations.of(context)!.myAccount,
                    trailing: DinoText.custom(
                      fontSize: DinoTextSizeToken.text100,
                      text: user?.email ?? '',
                      color: $dinoToken.color.blingGray500,
                    ),
                    onTap: () {},
                  ),
                  Divider(
                    color: $dinoToken.color.blingGray75.resolve(context),
                    thickness: 8,
                  ),
                  _buildSettingItem(
                    title: AppLocalizations.of(context)!.syncData,
                    trailing: DinoText.custom(
                      fontSize: DinoTextSizeToken.text100,
                      text: _lastBackupTime ?? AppLocalizations.of(context)!.backupRequired,
                      color: $dinoToken.color.blingGray500,
                    ),
                    onTap: () async {
                      // 데이터 백업 30분 이상 지났으면 백업
                      final prefs = await SharedPreferences.getInstance();
                      final lastBackupTimeString =
                          prefs.getString('lastBackupTime');
                      bool shouldBackup = false;

                      if (lastBackupTimeString == null) {
                        shouldBackup = true;
                      } else {
                        final lastBackupTime =
                            DateTime.parse(lastBackupTimeString);
                        final now = DateTime.now();
                        final difference = now.difference(lastBackupTime);
                        if (difference.inMinutes >= 30) {
                          shouldBackup = true;
                        }
                      }

                      if (shouldBackup) {
                        ref.read(loadingStateProvider.notifier).startLoading(
                              message: '데이터 백업 중...',
                            );

                        try {
                          /// 데이터 백업
                          final travelSyncService =
                              TravelSyncService(SupabaseConfig.client);
                          await travelSyncService
                              .saveTravels(ref.read(travelsProvider));

                          /// 백업 시간 저장
                          await prefs.setString('lastBackupTime',
                              DateTime.now().toIso8601String());

                          /// UI 업데이트
                          await _loadLastBackupTime();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('데이터 백업이 완료되었습니다.')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('백업 실패: $e')),
                            );
                          }
                        } finally {
                          ref.read(loadingStateProvider.notifier).stopLoading();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('30분 후에 다시 백업할 수 있습니다.')),
                        );
                      }
                    },
                  ),
                  _buildSettingItem(
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    trailing: SvgPicture.asset(
                      'assets/icons/ar_right.svg',
                      colorFilter: ColorFilter.mode(
                        $dinoToken.color.blingGray500.resolve(context),
                        BlendMode.srcIn,
                      ),
                    ),
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
                    trailing: SvgPicture.asset(
                      'assets/icons/ar_right.svg',
                      colorFilter: ColorFilter.mode(
                        $dinoToken.color.blingGray500.resolve(context),
                        BlendMode.srcIn,
                      ),
                    ),
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
                      color: $dinoToken.color.brandBlingBlue800,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: $dinoToken.color.blingGray75.resolve(context),
              thickness: 1,
            ),
            Row(
              children: [
                Flexible(
                  child: DinoButton.custom(
                    type: DinoButtonType.empty,
                    size: DinoButtonSize.full,
                    textSize: 16,
                    verticalPadding: 31,
                    backgroundColor: $dinoToken.color.white,
                    fontWeight: FontWeight.w600,
                    textColor: $dinoToken.color.blingGray500,
                    title: AppLocalizations.of(context)!.withdraw,
                    onTap: () {
                      /// 회원탈퇴
                      /// 로컬 데이터 삭제
                      /// 서버 데이터 삭제
                      /// 처음 화면으로 이동
                      deleteAccount();
                    },
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: $dinoToken.color.blingGray200.resolve(context),
                ),
                Flexible(
                  child: DinoButton.custom(
                    type: DinoButtonType.empty,
                    size: DinoButtonSize.full,
                    textSize: 16,
                    verticalPadding: 31,
                    backgroundColor: $dinoToken.color.white,
                    fontWeight: FontWeight.w600,
                    textColor: $dinoToken.color.blingGray500,
                    title: AppLocalizations.of(context)!.logout,
                    onTap: () {
                      /// 로그아웃
                      /// 로컬 데이터 삭제
                      /// 처음 화면으로 이동
                      signOut();
                    },
                  ),
                ),
              ],
            ),
            const AdBannerWidget(),
          ],
        ),
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
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
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
