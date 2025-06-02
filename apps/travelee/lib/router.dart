import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/presentation/screens/home/first_screen.dart';
import 'package:travelee/presentation/screens/travel_detail/date_screen.dart';
import 'package:travelee/presentation/screens/travel_detail/travel_detail_screen.dart';
import 'package:travelee/presentation/screens/travel_detail/schedule_input_screen.dart';
import 'package:travelee/presentation/screens/travel_detail/location_search_screen.dart';
import 'package:travelee/presentation/screens/home/saved_travels_screen.dart';
import 'package:travelee/presentation/screens/auth/signup_screen.dart';
import 'package:travelee/presentation/screens/settings/settings_screen.dart';
import 'dart:developer' as dev;

GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();
final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: FirstScreen.routePath,
      debugLogDiagnostics: true,
      navigatorKey: mainNavigatorKey,
      observers: [],
      routes: [
        GoRoute(
          name: FirstScreen.routeName,
          path: FirstScreen.routePath,
          builder: (context, state) => const FirstScreen(),
        ),
        GoRoute(
          name: DateScreen.routeName,
          path: DateScreen.routePath,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const DateScreen(),
          ),
        ),
        GoRoute(
          name: TravelDetailScreen.routeName,
          path: TravelDetailScreen.routePath,
          builder: (context, state) {
            final travelId = state.pathParameters['id'] ?? '';
            dev.log('Router - 여행 상세 화면으로 이동: ID=$travelId');

            if (travelId.isEmpty) {
              dev.log('Router - 오류: 여행 ID가 비어 있음');
              return const Center(child: Text('여행 ID가 필요합니다'));
            }

            return const TravelDetailScreen();
          },
        ),
        GoRoute(
          name: LocationSearchScreen.routeName,
          path: LocationSearchScreen.routePath,
          builder: (context, state) {
            final Map<String, dynamic> extraData =
                state.extra as Map<String, dynamic>;
            final location = extraData['location'] as String;
            final latitude = extraData['latitude'] as double;
            final longitude = extraData['longitude'] as double;

            final countryCode = extraData['countryCode'] as String;
            return LocationSearchScreen(
              initialLocation: location,
              initialLatitude: latitude,
              initialLongitude: longitude,
              countryCode: countryCode,
            );
          },
        ),
        GoRoute(
          name: SavedTravelsScreen.routeName,
          path: SavedTravelsScreen.routePath,
          builder: (context, state) => const SavedTravelsScreen(),
        ),
        GoRoute(
          path: SignUpScreen.routePath,
          name: SignUpScreen.routeName,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: ScheduleInputScreen.routePath,
          name: ScheduleInputScreen.routeName,
          builder: (context, state) {
            final Map<String, dynamic> extraData =
                state.extra as Map<String, dynamic>;
            final initialTime = extraData['initialTime'] as TimeOfDay;
            final initialLocation = extraData['initialLocation'] as String;
            final initialMemo = extraData['initialMemo'] as String;
            final date = extraData['date'] as DateTime;
            final dayNumber = extraData['dayNumber'] as int;
            final initialLatitude = extraData['initialLatitude'] as double;
            final initialLongitude = extraData['initialLongitude'] as double;
            final scheduleId = extraData['scheduleId'] as String?;

            return ScheduleInputScreen(
              initialTime: initialTime,
              initialLocation: initialLocation,
              initialMemo: initialMemo,
              date: date,
              dayNumber: dayNumber,
              initialLatitude: initialLatitude,
              initialLongitude: initialLongitude,
              scheduleId: scheduleId,
            );
          },
        ),
        GoRoute(
          name: SettingsScreen.routeName,
          path: SettingsScreen.routePath,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  },
);
