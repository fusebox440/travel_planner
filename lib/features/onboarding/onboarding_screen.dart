import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travel_planner/core/services/onboarding_service.dart';
import 'package:travel_planner/widgets/ui_components.dart';

class OnboardingPageModel {
  final String lottieAsset;
  final String title;
  final String description;

  OnboardingPageModel({
    required this.lottieAsset,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      lottieAsset: 'assets/lottie/onboard_1.json',
      title: 'Plan Your Perfect Trip',
      description: 'Effortlessly organize your itinerary, from flights to activities, all in one place.',
    ),
    OnboardingPageModel(
      lottieAsset: 'assets/lottie/onboard_2.json',
      title: 'Discover New Places',
      description: 'Find hidden gems and popular attractions with our interactive map and location suggestions.',
    ),
    OnboardingPageModel(
      lottieAsset: 'assets/lottie/onboard_3.json',
      title: 'Travel Smarter',
      description: 'Set reminders, track expenses, and enjoy a stress-free journey. Let\'s get started!',
    ),
  ];

  void _onOnboardingComplete() {
    OnboardingService().setOnboardingComplete();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: GhostButton(
                text: 'Skip',
                onPressed: _onOnboardingComplete,
              ),
            ),
            // PageView for the carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(page.lottieAsset, height: 300),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page Indicator and Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: theme.colorScheme.primary,
                    ),
                  ),
                  _currentPage == _pages.length - 1
                      ? PrimaryButton(
                    text: 'Get Started',
                    onPressed: _onOnboardingComplete,
                  )
                      : PrimaryButton(
                    text: 'Next',
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}