import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/first_screen.dart';
import 'package:travelee/screen/input/date_screen.dart';
import 'package:travelee/screen/input/destination_screen.dart';
import 'package:travelee/presentation/screens/travel_detail/travel_detail_screen.dart';
import 'package:travelee/presentation/screens/schedule/schedule_detail_screen.dart';
import 'package:travelee/screen/input/location_search_screen.dart';
import 'package:travelee/screen/saved_travels_screen.dart';
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
          name: DestinationScreen.routeName,
          path: DestinationScreen.routePath,
          builder: (context, state) => const DestinationScreen(),
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
          name: ScheduleDetailScreen.routeName,
          path: ScheduleDetailScreen.routePath,
          builder: (context, state) {
            final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;
            final date = extraData['date'] as DateTime;
            final dayNumber = extraData['dayNumber'] as int;
            
            dev.log('Router - 일정 상세 화면으로 이동: 날짜=${date.toString()}, 일차=$dayNumber');
            
            return ScheduleDetailScreen(
              date: date,
              dayNumber: dayNumber,
            );
          },
        ),
        GoRoute(
          name: LocationSearchScreen.routeName,
          path: LocationSearchScreen.routePath,
          builder: (context, state) {
            final initialLocation = state.extra as String;
            return LocationSearchScreen(
              initialLocation: initialLocation,
            );
          },
        ),
        GoRoute(
          name: SavedTravelsScreen.routeName,
          path: SavedTravelsScreen.routePath,
          builder: (context, state) => const SavedTravelsScreen(),
        ),
      ],
    );
  },
);
