import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:travelee/providers/travel_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/input/schedule_detail_screen.dart';

class TravelDetailScreen extends ConsumerWidget {
  static const routeName = 'travel_detail';
  static const routePath = '/travel_detail';

  const TravelDetailScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  List<DateTime> _getDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    for (DateTime date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }
    return dates;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelInfo = ref.watch(travelInfoProvider);
    final dates = _getDateRange(travelInfo.startDate!, travelInfo.endDate!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $b2bToken.color.primary.resolve(context),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                B2bText.medium(
                  type: B2bTextType.body1,
                  text: '여행 정보',
                  color: $b2bToken.color.labelNomal.resolve(context),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: $b2bToken.color.gray100.resolve(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: $b2bToken.color.primary.resolve(context),
                          ),
                          const SizedBox(width: 8),
                          B2bText.medium(
                            type: B2bTextType.body2,
                            text: travelInfo.destination.join(', '),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: $b2bToken.color.primary.resolve(context),
                          ),
                          const SizedBox(width: 8),
                          B2bText.regular(
                            type: B2bTextType.body2,
                            text: '${_formatDate(travelInfo.startDate)} ~ ${_formatDate(travelInfo.endDate)}',
                            color: $b2bToken.color.gray500.resolve(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: $b2bToken.color.gray200.resolve(context),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push(
                            ScheduleDetailScreen.routePath,
                            extra: [date, index + 1],
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: $b2bToken.color.primary.resolve(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: B2bText.medium(
                                  type: B2bTextType.body2,
                                  text: 'Day ${index + 1}',
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              B2bText.medium(
                                type: B2bTextType.body2,
                                text: _formatDate(date),
                                color: $b2bToken.color.labelNomal.resolve(context),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: $b2bToken.color.gray400.resolve(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                title: '여행 저장하기',
                type: B2bButtonType.primary,
                onTap: () {
                  context.go('/');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 