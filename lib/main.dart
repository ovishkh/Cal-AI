import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/app_controller.dart';
import 'controllers/navigation_controller.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/planner.dart';
import 'screens/profile.dart';
import 'screens/about.dart';
import 'screens/calorie_ai.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'services/gemini_api.dart';
import 'utils/app_theme.dart';
import 'models/recipe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controllers
    final authController = Get.put(AuthController());
    Get.put(AppController());
    Get.put(NavigationController());

    return Obx(() {
      return GetMaterialApp(
        title: 'Cal AI',
        theme: AppTheme.themeData,
        initialRoute: authController.isLoggedIn ? '/home' : '/login',
        getPages: [
          GetPage(name: '/', page: () => const SplashScreen()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/signup', page: () => const SignupScreen()),
          GetPage(
            name: '/home',
            page:
                () =>
                    authController.isLoggedIn
                        ? const MainNavigationScreen(initialIndex: 0)
                        : const LoginRedirect(),
          ),
          GetPage(
            name: '/planner',
            page:
                () =>
                    authController.isLoggedIn
                        ? const MainNavigationScreen(initialIndex: 1)
                        : const LoginRedirect(),
          ),
          GetPage(
            name: '/calorie_ai',
            page:
                () =>
                    authController.isLoggedIn
                        ? const MainNavigationScreen(initialIndex: 0)
                        : const LoginRedirect(),
          ),
          GetPage(
            name: '/recipes',
            page:
                () =>
                    authController.isLoggedIn
                        ? const MainNavigationScreen(initialIndex: 2)
                        : const LoginRedirect(),
          ),
          GetPage(
            name: '/profile',
            page:
                () =>
                    authController.isLoggedIn
                        ? const MainNavigationScreen(initialIndex: 3)
                        : const LoginRedirect(),
          ),
          GetPage(
            name: '/about',
            page:
                () =>
                    authController.isLoggedIn
                        ? const AboutScreen()
                        : const LoginRedirect(),
          ),
        ],
        debugShowCheckedModeBanner: false,
      );
    });
  }
}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _selectedIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });

    // Listen to NavigationController changes
    final navService = Get.find<NavigationController>();
    ever(navService.currentIndex.obs, (int index) {
      if (_selectedIndex != index) {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(_selectedIndex);
        });
      }
    });
  }

  static const List<Widget> _screens = [
    CalorieAIScreen(),
    PlannerScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    Get.find<NavigationController>().changeTab(index);

    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          color: AppTheme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.cardColor,
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.white38,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.monitor_weight, color: Colors.grey.shade400),
                    Container(
                      width: 44,
                      height: 3,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color:
                            _selectedIndex == 0
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                activeIcon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.monitor_weight,
                      size: 28,
                      color: AppTheme.primaryColor,
                    ),
                    Container(
                      width: 44,
                      height: 3,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                label: 'CalorieAI',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                activeIcon: Icon(Icons.calendar_month, size: 28),
                label: 'Planner',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                activeIcon: Icon(Icons.restaurant_menu, size: 28),
                label: 'Recipes',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.person, color: Colors.grey.shade400),
                    Container(
                      width: 44,
                      height: 3,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color:
                            _selectedIndex == 3
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                activeIcon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 28,
                      color: AppTheme.primaryColor,
                    ),
                    Container(
                      width: 44,
                      height: 3,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                label: 'Profile',
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// AuthRedirect widget for unauthenticated access attempts
class LoginRedirect extends StatefulWidget {
  const LoginRedirect({super.key});

  @override
  State<LoginRedirect> createState() => _LoginRedirectState();
}

class _LoginRedirectState extends State<LoginRedirect> {
  @override
  void initState() {
    super.initState();
    // Redirect to login after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
