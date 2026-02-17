import 'package:expiry_wise_app/features/inventory/presentation/screens/add_new_item/add_new_item_screen.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/inventory_status/all_status_screen.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/barcode_scan_screen.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/all_items/all_items_screen.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/home_screen.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/item_detail/item_detail_screen.dart';
import 'package:expiry_wise_app/features/Member/presentation/screens/member_screen.dart';
import 'package:expiry_wise_app/features/quick_list/presentation/screens/quick_list_screen.dart';
import 'package:expiry_wise_app/routes/presentation/screens/navigation_screen.dart';
import 'package:expiry_wise_app/features/OnBoarding/presentation/screens/on_boarding_screen.dart';
import 'package:expiry_wise_app/features/Profile/presentation/screens/profile_screen.dart';
import 'package:expiry_wise_app/features/Space/presentation/screens/all_spaces_screens.dart';
import 'package:expiry_wise_app/features/Space/presentation/screens/join_space_screen.dart';
import 'package:expiry_wise_app/features/auth/presentation/pages/login_screen.dart';
import 'package:expiry_wise_app/routes/presentation/screens/screen_redirect.dart';
import 'package:go_router/go_router.dart';

import '../features/Member/presentation/screens/invite_member_screen.dart';
import '../features/expenses/presentation/screens/edit_expense.dart';
import '../features/voice_command/presentation/screens/bottom_sheet_voice_command.dart';

class MYRoute {
  static GoRouter appRouter = GoRouter(
    initialLocation: "/screenRedirect",
    routes: <GoRoute>[
      GoRoute(
        name: 'memberScreen',
        path: '/memberScreen',
        builder: (context, state) => const MemberScreen(),
      ),
      GoRoute(
        name: 'micScreen',
        path: '/micScreen',
        builder: (context, state) => const BottomSheetMic(),
      ),
      GoRoute(
        name: 'pantryStatusScreen',
        path: '/pantryStatusScreen',
        builder: (context, state) => const PantryStatusScreen(),
      ),
      GoRoute(
        name: 'inviteMemberScreen',
        path: '/inviteMemberScreen',
        builder: (context, state) => const InviteMemberScreen(),
      ),
      GoRoute(
        name: 'screenRedirect',
        path: '/screenRedirect',
        builder: (context, state) => const ScreenRedirect(),
      ),
      GoRoute(
        name: 'navigationScreen',
        path: '/navigationScreen',
        builder: (context, state) => const NavigationScreen(),
      ),
      GoRoute(
        name: 'homeScreen',
        path: '/homeScreen',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: 'spaceScreen',
        path: '/spaceScreen',
        builder: (context, state) => const AllSpacesScreens(),
      ),
      GoRoute(
        name: 'barcodeScanScreen',
        path: '/barcodeScanScreen',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return  BarcodeScanScreen(id);
        },
      ),
      GoRoute(
        name: 'addNewItemScreen',
        path: '/addNewItemScreen/id',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddNewItem(id);
        },
      ),
      GoRoute(
        name: 'onBoardingScreen',
        path: '/onBoardingScreen',
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        name: 'logInScreen',
        path: '/logInScreen',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        name: 'profileScreen',
        path: '/profileScreen',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        name: 'allItemsScreen',
        path: '/allItemsScreen',
        builder: (context, state) => const AllItemsScreen(),
      ),
      GoRoute(
        name: 'addNewExpense',
        path: '/addNewExpense',
        builder: (context, state){
          final expense = state.uri.queryParameters['id'];

          return AddNewExpense(expense);
        },
      ),
      GoRoute(
        name: 'quickListScreen',
        path: '/quickListScreen',
        builder: (context, state){

          return const QuickListScreen();
        },
      ),

      GoRoute(
        path: '/joinSpaceScreen',
        name: 'joinSpaceScreen',
        builder: (_, __) => const JoinSpaceScreen(),
      ),

      GoRoute(
        name: 'itemDetailScreen',
        path: '/itemDetailScreen/:id',
        builder: (context, state) {
          final item = state.pathParameters['id'];
          return ItemDetailScreen(item!);
        },
      ),

      // GoRoute(path: '/signUpScreen',builder: (context,state)=> const SignUpScreen()),
    ],
  );
  static const String homeScreenRoute = 'homeScreen';
  static const String addNewItemScreen = 'addNewItemScreen';
  static const String addNewExpense = 'addNewExpense';
  static const String onBoardingScreen = 'onBoardingScreen';
  static const String logInScreen = 'logInScreen';
  static const String profileScreen = 'profileScreen';
  static const String allItemsScreen = 'allItemsScreen';
  static const String itemDetailScreen = 'itemDetailScreen';
  static const String memberScreen = 'memberScreen';
  static const String spaceScreen = 'spaceScreen';
  static const String barcodeScanScreen = 'barcodeScanScreen';
  static const String pantryStatusScreen = 'pantryStatusScreen';
  static const String joinSpaceScreen = 'joinSpaceScreen';
  static const String inviteMemberScreen = 'inviteMemberScreen';
  static const String quickListScreen = 'quickListScreen';
  static const String screenRedirect = 'screenRedirect';
  static String get navigationScreen => 'navigationScreen';
  static String get micScreen => 'micScreen';
}
