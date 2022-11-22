import 'package:bbarena_app_com/deleted_user_screen.dart';
import 'package:bbarena_app_com/screens/Setting_Screen/settings_page.dart';
import 'package:bbarena_app_com/screens/add_post/add_post_users/add_post_video_users.dart';
import 'package:bbarena_app_com/screens/add_post/add_post_users/add_screen_users.dart';
import 'package:bbarena_app_com/screens/add_post/add_post_video.dart';
import 'package:bbarena_app_com/screens/add_post/add_screen.dart';
import 'package:bbarena_app_com/screens/feedback_screen/feeback_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/bookmarks/bookmark_page.dart';
import 'package:bbarena_app_com/screens/homeFire/giveawayFire/giveaway_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/home_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/notifications/notif_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFire/profile_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFireEdit/edit_username.dart';
import 'package:bbarena_app_com/screens/wallet_screens/create_wallet.dart';
import 'package:bbarena_app_com/screens/wallet_screens/import_wallet_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:bbarena_app_com/screens/change_password/change_password_screen.dart';
import 'package:bbarena_app_com/screens/details/details_screen.dart';
import 'package:bbarena_app_com/screens/forgot_password/forgot_password_screen.dart';
import 'package:bbarena_app_com/screens/login_success/login_success_screen.dart';
import 'package:bbarena_app_com/screens/logout_success/logout_success_screen.dart';
import 'package:bbarena_app_com/screens/sign_in/sign_in_screen.dart';
import 'package:bbarena_app_com/screens/splash/splash_screen.dart';
import 'screens/search/search_page.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'package:bbarena_app_com/screens/logout_success/user_deleted_page.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFireEdit/editUser_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  LogOutSuccessScreen.routeName: (context) => const LogOutSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  ChangePasswordScreen.routeName: (context) => const ChangePasswordScreen(),
  DetailsScreen.routeName: (context) => DetailsScreen(
        updateComLen: () {},
      ),
  FeedBackScreen.routeName: (context) => const FeedBackScreen(),
  CreateWallet.routeName: (context) => CreateWallet(
        refreshWallet: () {},
      ),
  NotifScreen.routeName: (context) => const NotifScreen(),
  EditUsername.routename: (context) => const EditUsername(),
  BookmarkPage.routeName: (context) => const BookmarkPage(),
  AddPostScreen.routeName: (context) => const AddPostScreen(),
  AddPostScreenUser.routeName: (context) => const AddPostScreenUser(),
  AddVideoPostScreenUsers.routeName: (context) =>
      const AddVideoPostScreenUsers(),
  AddVideoPostScreen.routeName: (context) => const AddVideoPostScreen(),
  SearchPage.routeName: (context) => const SearchPage(),
  ImportWallet.routeName: (context) => ImportWallet(
        refreshWallet: () {},
        popCreateScreen: () {},
      ),
  GiveScreenFire.routeName: (context) => const GiveScreenFire(),
  HomeScreenFire.routeName: (context) => HomeScreenFire(
        navTo: () {},
      ),
  SettingsPage.routeName: (context) => const SettingsPage(),
  DeletedUserScreen.routeName: (context) => const DeletedUserScreen(),
  ProfileScreenFire.routeName: (context) => const ProfileScreenFire(),
  EditUserScreenFire.routeName: (context) => const EditUserScreenFire(),
  UserDelete.routeName: (context) => const UserDelete(),
};
