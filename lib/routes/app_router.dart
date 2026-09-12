import 'package:classpay/providers/auth_state.dart';
import 'package:classpay/providers/session_manager.dart';
import 'package:classpay/routes/auth_guard.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/screens/admin/admin_classes_screen.dart';
import 'package:classpay/screens/admin/admin_dashboard_screen.dart';
import 'package:classpay/screens/admin/admin_organizations_screen.dart';
import 'package:classpay/screens/admin/admin_payment_screens.dart';
import 'package:classpay/screens/admin/class_detail_screen.dart';
import 'package:classpay/screens/admin/class_form_screen.dart';
import 'package:classpay/screens/admin/class_schedule_screen.dart';
import 'package:classpay/screens/admin/organization_admins_screen.dart';
import 'package:classpay/screens/admin/organization_detail_screen.dart';
import 'package:classpay/screens/admin/organization_form_screen.dart';
import 'package:classpay/screens/auth/change_password_screen.dart';
import 'package:classpay/screens/auth/login_screen.dart';
import 'package:classpay/screens/auth/set_password_screen.dart';
import 'package:classpay/screens/auth/session_loading_screen.dart';
import 'package:classpay/screens/auth/profile_screen.dart';
import 'package:classpay/screens/participant/payment_screens.dart';
import 'package:classpay/screens/notifications/notification_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:classpay/screens/sponsor/sponsor_home_screen.dart';
import 'package:classpay/screens/student/student_home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: sessionManager,
    redirect: (context, routeState) {
      final authState = sessionManager.state;
      final location = routeState.matchedLocation;
      if (authState.status == AuthStatus.initializing) {
        return location == '/splash' ? null : '/splash';
      }
      if (!authState.isAuthenticated) {
        return location == '/login' ? null : '/login';
      }
      final home = AuthGuard.homeForUser(authState.user!);
      if (location == '/login' || location == '/splash') return home;
      return AuthGuard.canAccess(location, authState) ? null : home;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SessionLoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/set-password',
        builder: (context, state) => const SetPasswordScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/:id',
        builder: (context, state) => NotificationDetailScreen(
          notificationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: '/admin/reports/payment-summary',
        builder: (context, state) => const PaymentSummaryReportScreen(),
      ),
      GoRoute(
        path: '/admin/reports/outstanding',
        builder: (context, state) => const OutstandingReportScreen(),
      ),
      GoRoute(
        path: '/admin/reports/overdue',
        builder: (context, state) => const OverdueReportScreen(),
      ),
      GoRoute(
        path: '/admin/organizations',
        builder: (context, state) => const AdminOrganizationsScreen(),
      ),
      GoRoute(
        path: '/admin/organizations/new',
        builder: (context, state) => const OrganizationFormScreen(),
      ),
      GoRoute(
        path: '/admin/organizations/:id',
        builder: (context, state) => OrganizationDetailScreen(
          organizationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/organizations/:id/edit',
        builder: (context, state) => OrganizationFormScreen(
          organizationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/organizations/:id/admins',
        builder: (context, state) => OrganizationAdminsScreen(
          organizationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/organizations/:organizationId/classes',
        builder: (context, state) => AdminClassesScreen(
          organizationId: int.parse(state.pathParameters['organizationId']!),
        ),
      ),
      GoRoute(
        path: '/admin/organizations/:organizationId/classes/new',
        builder: (context, state) => ClassFormScreen(
          organizationId: int.parse(state.pathParameters['organizationId']!),
        ),
      ),
      GoRoute(
        path: '/admin/organizations/:organizationId/classes/:classId/edit',
        builder: (context, state) => ClassFormScreen(
          organizationId: int.parse(state.pathParameters['organizationId']!),
          classId: int.parse(state.pathParameters['classId']!),
        ),
      ),
      GoRoute(
        path: '/admin/classes/:classId',
        builder: (context, state) => ClassDetailScreen(
          classId: int.parse(state.pathParameters['classId']!),
        ),
      ),
      GoRoute(
        path: '/admin/classes/:classId/schedules',
        builder: (context, state) => ClassScheduleScreen(
          classId: int.parse(state.pathParameters['classId']!),
        ),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: '/student/payment-schedules',
        builder: (context, state) =>
            const PaymentSchedulesScreen(role: ParticipantRole.student),
      ),
      GoRoute(
        path: '/sponsor',
        builder: (context, state) => const SponsorHomeScreen(),
      ),
      GoRoute(
        path: '/sponsor/payment-schedules',
        builder: (context, state) =>
            const PaymentSchedulesScreen(role: ParticipantRole.sponsor),
      ),
    ],
  );
});
