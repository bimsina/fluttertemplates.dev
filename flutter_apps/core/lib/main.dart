import 'package:core/animation/hero_list_view.dart';
import 'package:flutter/material.dart';

import 'core/button_demo.dart';
import 'core/loading_demo.dart';
import 'core/toast_demo.dart';
import 'forms/sign_in/sign_in_page1.dart';
import 'forms/sign_in/sign_in_page2.dart';
import 'must_haves/content_feed/news_feed_1.dart';
import 'must_haves/content_feed/news_feed_2.dart';
import 'must_haves/dropdowns/auto_complete_dropdown.dart';
import 'must_haves/dropdowns/simple_drop_down.dart';
import 'must_haves/onboarding_page/concentric_animation_onboarding.dart';
import 'must_haves/onboarding_page/onboarding_page_1.dart';
import 'must_haves/profile_page/profile_page_1.dart';
import 'must_haves/settings_page/settings_page_1.dart';
import 'must_haves/settings_page/settings_page_2.dart';
import 'navigation/bottom_nav/google_bottom_bar.dart';
import 'navigation/bottom_nav/material3_bottom.dart';
import 'navigation/bottom_nav/persistent_bottom.dart';
import 'navigation/bottom_nav/simple_bottom.dart';
import 'navigation/nav_bar/responsive_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Map<String, String> queryParams;

  @override
  void initState() {
    super.initState();
    queryParams = Uri.base.queryParameters;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Parameters Demo',
      theme: queryParams["theme"] == "dark"
          ? ThemeData.dark()
          : ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
      home: Builder(
        builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              switch (queryParams["path"]) {
                case "/animation/hero_list_view":
                  return HeroListView();
                case "/core/buttons":
                  return const ButtonDemo();
                case "/core/loading":
                  return const LoadingDemo();
                case "/core/toast_demo":
                  return const ToastDemo();

                case "/navigation/bottom_nav/google_bottom_bar":
                  return const GoogleBottomBar();
                case "/navigation/bottom_nav/material3_bottom":
                  return const Material3BottomNav();
                case "/navigation/bottom_nav/simple_bottom":
                  return const SimpleBottomNavigation();
                case "/navigation/bottom_nav/persistent_bottom":
                  return PersistentBottomNavPage();
                case "/navigation/nav_bar/responsive_nav_bar":
                  return ResponsiveNavBarPage();

                case "/forms/sign_in/sign_in_page1":
                  return const SignInPage1();
                case "/forms/sign_in/sign_in_page2":
                  return const SignInPage2();

                case "/must_haves/onboarding_page/concentric_animation_onboarding":
                  return const ConcentricAnimationOnboarding();
                case "/must_haves/onboarding_page/onboarding_page_1":
                  return const OnboardingPage1();
                case "/must_haves/content_feed/news_feed_1":
                  return const NewsFeedPage1();
                case "/must_haves/content_feed/news_feed_2":
                  return const NewsFeedPage2();
                case "/must_haves/dropdowns/auto_complete_dropdown":
                  return const AutocompleteDropDown();
                case "/must_haves/dropdowns/simple_dropdown":
                  return const SimpleDropDown();
                case "/must_haves/settings_page/settings_page_1":
                  return const SettingsPage1();
                case "/must_haves/settings_page/settings_page_2":
                  return const SettingsPage2();
                case "/must_haves/profile_page/profile_page_1":
                  return const ProfilePage1();

                default:
                  return Scaffold(body: Center(child: Text("No page found")));
              }
            },
          );
        },
      ),
    );
  }
}
