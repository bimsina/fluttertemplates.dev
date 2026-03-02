import 'package:core/animation/hero_list_view.dart';
import 'package:flutter/material.dart';

import 'chat/group_chat.dart';
import 'chat/simple_chat.dart';
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
import 'animation/animated_counter.dart';
import 'animation/animated_toggle.dart';
import 'animation/page_transitions.dart';
import 'animation/shimmer_loading.dart';
import 'animation/staggered_list.dart';
import 'forms/contact/contact_form.dart';
import 'forms/forgot_password/forgot_password.dart';
import 'forms/multi_step/multi_step_form.dart';
import 'forms/otp/otp_verification.dart';
import 'forms/payment/payment_form.dart';
import 'forms/search/search_form.dart';
import 'forms/sign_up/sign_up_page.dart';
import 'forms/survey/survey_form.dart';
import 'layouts/expandable_list.dart';
import 'layouts/horizontal_gallery.dart';
import 'layouts/masonry_grid.dart';
import 'layouts/reorderable_list.dart';
import 'layouts/sliver_layout.dart';
import 'layouts/split_view.dart';
import 'layouts/tabbed_content.dart';
import 'navigation/nav_bar/navigation_rail.dart';
import 'overlays/bottom_sheets.dart';
import 'overlays/dialogs.dart';
import 'overlays/popup_menu.dart';
import 'overlays/snackbar_variants.dart';
import 'states/empty_no_connection.dart';
import 'states/empty_no_data.dart';
import 'states/error_404.dart';
import 'states/error_500.dart';
import 'states/maintenance_page.dart';
import 'states/splash_screen.dart';
import 'navigation/nav_bar/responsive_nav_bar.dart';
import 'ecommerce/category_browser.dart';
import 'ecommerce/checkout_page.dart';
import 'ecommerce/flash_sale.dart';
import 'ecommerce/order_confirmation.dart';
import 'ecommerce/order_history.dart';
import 'ecommerce/product_detail.dart';
import 'ecommerce/product_grid.dart';
import 'ecommerce/product_list.dart';
import 'ecommerce/product_reviews.dart';
import 'ecommerce/product_search.dart';
import 'ecommerce/shopping_cart.dart';
import 'ecommerce/wishlist_page.dart';
import 'social/activity_feed.dart';
import 'social/comments_thread.dart';
import 'social/dm_list.dart';
import 'social/notifications_feed.dart';
import 'social/photo_feed.dart';
import 'social/poll_card.dart';
import 'social/post_composer.dart';
import 'social/social_profile.dart';
import 'social/stories_bar.dart';
import 'social/user_search.dart';
import 'search/search_results.dart';
import 'search/search_suggestions.dart';
import 'search/voice_search.dart';
import 'finance/wallet_overview.dart';
import 'finance/credit_card.dart';
import 'finance/transaction_history.dart';
import 'finance/send_money.dart';
import 'finance/budget_tracker.dart';
import 'finance/bill_payment.dart';
import 'finance/expense_breakdown.dart';
import 'finance/currency_converter.dart';
import 'food/restaurant_list.dart';
import 'food/restaurant_detail.dart';
import 'food/food_menu.dart';
import 'food/food_cart.dart';
import 'food/recipe_card.dart';
import 'food/delivery_tracking.dart';
import 'food/restaurant_review.dart';
import 'health/fitness_dashboard.dart';
import 'health/workout_list.dart';
import 'health/workout_timer.dart';
import 'health/water_tracker.dart';
import 'health/sleep_tracker.dart';
import 'health/bmi_calculator.dart';
import 'health/meal_planner.dart';
import 'dashboard/admin_dashboard.dart';
import 'dashboard/kpi_cards.dart';
import 'dashboard/data_table.dart';
import 'dashboard/chart_gallery.dart';
import 'dashboard/kanban_board.dart';
import 'dashboard/stats_overview.dart';
import 'travel/destination_cards.dart';
import 'travel/flight_booking.dart';
import 'travel/hotel_listing.dart';
import 'travel/boarding_pass.dart';
import 'travel/trip_itinerary.dart';
import 'travel/travel_blog.dart';
import 'education/course_catalog.dart';
import 'education/lesson_player.dart';
import 'education/quiz_screen.dart';
import 'education/report_card.dart';
import 'education/flashcard.dart';
import 'education/assignment_list.dart';
import 'media/music_player.dart';
import 'media/playlist_view.dart';
import 'media/album_grid.dart';
import 'media/podcast_player.dart';
import 'media/video_player.dart';
import 'media/audio_visualizer.dart';
import 'calendar/month_calendar.dart';
import 'calendar/event_list.dart';
import 'calendar/date_range_picker.dart';
import 'calendar/booking_slots.dart';
import 'notifications/notification_center.dart';
import 'notifications/email_inbox.dart';
import 'notifications/notification_banners.dart';
import 'notifications/notification_settings.dart';
import 'pricing/pricing_cards.dart';
import 'pricing/subscription_page.dart';
import 'pricing/paywall_screen.dart';
import 'pricing/feature_comparison.dart';
import 'info/about_page.dart';
import 'info/contact_page.dart';
import 'info/faq_page.dart';
import 'info/team_page.dart';
import 'gallery/photo_grid.dart';
import 'gallery/image_carousel.dart';
import 'gallery/image_viewer.dart';
import 'gallery/photo_album.dart';
import 'communication/video_call.dart';
import 'communication/voice_call.dart';
import 'communication/audio_message_player.dart';
import 'communication/video_message_player.dart';
import 'communication/conference_call.dart';
import 'communication/call_history.dart';
import 'profile/profile_settings.dart';
import 'profile/account_settings.dart';
import 'profile/edit_profile.dart';
import 'profile/profile_preview.dart';
import 'profile/privacy_settings.dart';
import 'profile/security_settings.dart';
import 'utilities/weather_dashboard.dart';
import 'utilities/unit_converter.dart';
import 'utilities/calculator.dart';
import 'utilities/notes_app.dart';
import 'utilities/stopwatch.dart';
import 'utilities/world_clock.dart';

void main() {
  runApp(const MyApp());
}

final routes = <String, Widget Function()>{
  "/animation/hero_list_view": () => HeroListView(),
  "/core/buttons": () => const ButtonDemo(),
  "/core/loading": () => const LoadingDemo(),
  "/core/toast_demo": () => const ToastDemo(),
  "/navigation/bottom_nav/google_bottom_bar": () => const GoogleBottomBar(),
  "/navigation/bottom_nav/material3_bottom": () => const Material3BottomNav(),
  "/navigation/bottom_nav/simple_bottom": () => const SimpleBottomNavigation(),
  "/navigation/bottom_nav/persistent_bottom": () => PersistentBottomNavPage(),
  "/navigation/nav_bar/responsive_nav_bar": () => ResponsiveNavBarPage(),
  "/navigation/nav_bar/navigation_rail": () => const CustomNavigationRail(),
  "/forms/sign_in/sign_in_page1": () => const SignInPage1(),
  "/forms/sign_in/sign_in_page2": () => const SignInPage2(),
  "/must_haves/onboarding_page/concentric_animation_onboarding": () =>
      const ConcentricAnimationOnboarding(),
  "/must_haves/onboarding_page/onboarding_page_1": () =>
      const OnboardingPage1(),
  "/must_haves/content_feed/news_feed_1": () => const NewsFeedPage1(),
  "/must_haves/content_feed/news_feed_2": () => const NewsFeedPage2(),
  "/must_haves/dropdowns/auto_complete_dropdown": () =>
      const AutocompleteDropDown(),
  "/must_haves/dropdowns/simple_dropdown": () => const SimpleDropDown(),
  "/must_haves/settings_page/settings_page_1": () => const SettingsPage1(),
  "/must_haves/settings_page/settings_page_2": () => const SettingsPage2(),
  "/must_haves/profile_page/profile_page_1": () => const ProfilePage1(),
  "/chat/simple_chat": () => const SimpleChat(),
  "/chat/group_chat": () => const GroupChat(),
  "/layouts/masonry_grid": () => const MasonryGrid(),
  "/layouts/sliver_layout": () => const SliverLayout(),
  "/layouts/expandable_list": () => const ExpandableList(),
  "/layouts/reorderable_list": () => const ReorderableListPage(),
  "/layouts/horizontal_gallery": () => const HorizontalGallery(),
  "/layouts/split_view": () => const SplitView(),
  "/layouts/tabbed_content": () => const TabbedContent(),
  "/states/empty_no_data": () => const EmptyNoData(),
  "/states/empty_no_connection": () => const EmptyNoConnection(),
  "/states/error_404": () => const Error404(),
  "/states/error_500": () => const Error500(),
  "/states/splash_screen": () => const SplashScreen(),
  "/states/maintenance_page": () => const MaintenancePage(),
  "/overlays/bottom_sheets": () => const BottomSheets(),
  "/overlays/dialogs": () => const OverlayDialogs(),
  "/overlays/snackbar_variants": () => const SnackbarVariants(),
  "/overlays/popup_menu": () => const PopupMenuPage(),
  "/animation/animated_counter": () => const AnimatedCounter(),
  "/animation/staggered_list": () => const StaggeredList(),
  "/animation/animated_toggle": () => const AnimatedToggle(),
  "/animation/page_transitions": () => const PageTransitions(),
  "/animation/shimmer_loading": () => const ShimmerLoading(),
  "/forms/sign_up/sign_up_page": () => const SignUpPage(),
  "/forms/multi_step/multi_step_form": () => const MultiStepForm(),
  "/forms/payment/payment_form": () => const PaymentForm(),
  "/forms/contact/contact_form": () => const ContactForm(),
  "/forms/search/search_form": () => const SearchForm(),
  "/forms/forgot_password/forgot_password": () => const ForgotPasswordPage(),
  "/forms/otp/otp_verification": () => const OtpVerification(),
  "/forms/survey/survey_form": () => const SurveyForm(),
  "/ecommerce/product_grid": () => const ProductGrid(),
  "/ecommerce/product_list": () => const ProductList(),
  "/ecommerce/product_detail": () => const ProductDetail(),
  "/ecommerce/shopping_cart": () => const ShoppingCart(),
  "/ecommerce/checkout_page": () => const CheckoutPage(),
  "/ecommerce/order_confirmation": () => const OrderConfirmation(),
  "/ecommerce/order_history": () => const OrderHistory(),
  "/ecommerce/wishlist_page": () => const WishlistPage(),
  "/ecommerce/product_reviews": () => const ProductReviews(),
  "/ecommerce/category_browser": () => const CategoryBrowser(),
  "/ecommerce/flash_sale": () => const FlashSale(),
  "/ecommerce/product_search": () => const ProductSearch(),
  "/social/stories_bar": () => const StoriesBar(),
  "/social/photo_feed": () => const PhotoFeed(),
  "/social/social_profile": () => const SocialProfile(),
  "/social/post_composer": () => const PostComposer(),
  "/social/comments_thread": () => const CommentsThread(),
  "/social/notifications_feed": () => const NotificationsFeed(),
  "/social/dm_list": () => const DmList(),
  "/social/user_search": () => const UserSearch(),
  "/social/activity_feed": () => const ActivityFeed(),
  "/social/poll_card": () => const PollCard(),
  "/search/search_suggestions": () => const SearchSuggestions(),
  "/search/search_results": () => const SearchResults(),
  "/search/voice_search": () => const VoiceSearch(),
  "/finance/wallet_overview": () => const WalletOverview(),
  "/finance/credit_card": () => const CreditCard(),
  "/finance/transaction_history": () => const TransactionHistory(),
  "/finance/send_money": () => const SendMoney(),
  "/finance/budget_tracker": () => const BudgetTracker(),
  "/finance/bill_payment": () => const BillPayment(),
  "/finance/expense_breakdown": () => const ExpenseBreakdown(),
  "/finance/currency_converter": () => const CurrencyConverter(),
  "/food/restaurant_list": () => const RestaurantList(),
  "/food/restaurant_detail": () => const RestaurantDetail(),
  "/food/food_menu": () => const FoodMenu(),
  "/food/food_cart": () => const FoodCart(),
  "/food/recipe_card": () => const RecipeCard(),
  "/food/delivery_tracking": () => const DeliveryTracking(),
  "/food/restaurant_review": () => const RestaurantReview(),
  "/health/fitness_dashboard": () => const FitnessDashboard(),
  "/health/workout_list": () => const WorkoutList(),
  "/health/workout_timer": () => const WorkoutTimer(),
  "/health/water_tracker": () => const WaterTracker(),
  "/health/sleep_tracker": () => const SleepTracker(),
  "/health/bmi_calculator": () => const BmiCalculator(),
  "/health/meal_planner": () => const MealPlanner(),
  "/dashboard/admin_dashboard": () => const AdminDashboard(),
  "/dashboard/kpi_cards": () => const KpiCards(),
  "/dashboard/data_table": () => const DataTableScreen(),
  "/dashboard/chart_gallery": () => const ChartGallery(),
  "/dashboard/kanban_board": () => const KanbanBoard(),
  "/dashboard/stats_overview": () => const StatsOverview(),
  "/travel/destination_cards": () => const DestinationCards(),
  "/travel/flight_booking": () => const FlightBooking(),
  "/travel/hotel_listing": () => const HotelListing(),
  "/travel/boarding_pass": () => const BoardingPass(),
  "/travel/trip_itinerary": () => const TripItinerary(),
  "/travel/travel_blog": () => const TravelBlog(),
  "/education/course_catalog": () => const CourseCatalog(),
  "/education/lesson_player": () => const LessonPlayer(),
  "/education/quiz_screen": () => const QuizScreen(),
  "/education/report_card": () => const ReportCard(),
  "/education/flashcard": () => const Flashcard(),
  "/education/assignment_list": () => const AssignmentList(),
  "/media/music_player": () => const MusicPlayer(),
  "/media/playlist_view": () => const PlaylistView(),
  "/media/album_grid": () => const AlbumGrid(),
  "/media/podcast_player": () => const PodcastPlayer(),
  "/media/video_player": () => const VideoPlayer(),
  "/media/audio_visualizer": () => const AudioVisualizer(),
  "/calendar/month_calendar": () => const MonthCalendar(),
  "/calendar/event_list": () => const EventList(),
  "/calendar/date_range_picker": () => const DateRangePicker(),
  "/calendar/booking_slots": () => const BookingSlots(),
  "/notifications/notification_center": () => const NotificationCenter(),
  "/notifications/email_inbox": () => const EmailInbox(),
  "/notifications/notification_banners": () => const NotificationBanners(),
  "/notifications/notification_settings": () => const NotificationSettings(),
  "/pricing/pricing_cards": () => const PricingCards(),
  "/pricing/subscription_page": () => const SubscriptionPage(),
  "/pricing/paywall_screen": () => const PaywallScreen(),
  "/pricing/feature_comparison": () => const FeatureComparison(),
  "/info/about_page": () => const AboutPage(),
  "/info/contact_page": () => const ContactPage(),
  "/info/faq_page": () => const FaqPage(),
  "/info/team_page": () => const TeamPage(),
  "/gallery/photo_grid": () => const PhotoGrid(),
  "/gallery/image_carousel": () => const ImageCarousel(),
  "/gallery/image_viewer": () => const ImageViewer(),
  "/gallery/photo_album": () => const PhotoAlbum(),
  "/communication/video_call": () => const VideoCallScreen(),
  "/communication/voice_call": () => const VoiceCallScreen(),
  "/communication/audio_message_player": () => const AudioMessagePlayer(),
  "/communication/video_message_player": () => const VideoMessagePlayer(),
  "/communication/conference_call": () => const ConferenceCall(),
  "/communication/call_history": () => const CallHistory(),
  "/profile/profile_settings": () => const ProfileSettings(),
  "/profile/account_settings": () => const AccountSettings(),
  "/profile/edit_profile": () => const EditProfile(),
  "/profile/profile_preview": () => const ProfilePreview(),
  "/profile/privacy_settings": () => const PrivacySettings(),
  "/profile/security_settings": () => const SecuritySettings(),
  "/utilities/weather_dashboard": () => const WeatherDashboard(),
  "/utilities/unit_converter": () => const UnitConverter(),
  "/utilities/calculator": () => const Calculator(),
  "/utilities/notes_app": () => const NotesApp(),
  "/utilities/stopwatch": () => const StopwatchScreen(),
  "/utilities/world_clock": () => const WorldClock(),
};

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
          final builder = routes[queryParams["path"]];
          return builder?.call() ??
              Scaffold(body: Center(child: Text("No page found")));
        },
      ),
    );
  }
}
