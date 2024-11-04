import 'package:get/get.dart';
import 'package:hostelfinder/Login_page.dart';
import 'package:hostelfinder/allhostelcardscreen.dart';
import 'package:hostelfinder/booking/bookingscreen.dart';
import 'package:hostelfinder/dashboard_screen.dart';
import 'package:hostelfinder/form_screen.dart';
import 'package:hostelfinder/home_screen.dart';
import 'package:hostelfinder/password_screen.dart';
import 'package:hostelfinder/profilescreen.dart';
import 'package:hostelfinder/register_screen.dart';
import 'package:hostelfinder/splash_screen.dart';
import 'package:hostelfinder/userdatascreen.dart';

class Routescreen {
  static const String splash = '/';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String password = '/password';
  static const String form = '/form';
  static const String dashboard = '/dashboard';
  static const String hosteldetailscreen = '/hosteldetailscreen';
  static const String allHostelscardscreen = '/allhostelscardscreen';
  static const String userdatascreen = '/userdatascreen';
  static const String bookingscreen = '/bookingscreen';
  static const String rulesscreen = '/rulesscreen';
  static const String edithosteldialog = '/edithosteldialog';

  static List<GetPage> pages = [
    GetPage(name: splash, page: () => const Splashscreen()),
    GetPage(name: home, page: () => const Homescreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: login, page: () => const Loginpage()),
    GetPage(name: password, page: () => const PasswordScreen()),
    GetPage(name: form, page: () => const Formscreen()),
    GetPage(name: dashboard, page: () => DashboardScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    //GetPage(name: hosteldetailscreen, page: () => HostelDetailScreen()),

    GetPage(
        name: bookingscreen,
        page: () => const BookingScreen(
              hostelId: home,
              hostelName: home, roomNumbers: [], hostelIds: '',
            )),
    GetPage(name: userdatascreen, page: () => const UserDataScreen()),

    //GetPage(name: hosteldetailscreen, page: () => HostelDetailScreen()),
    GetPage(
        name: allHostelscardscreen,
        page: () => const AllHostelscardscreen(
              hostels: [],
            )),
  ];
}
