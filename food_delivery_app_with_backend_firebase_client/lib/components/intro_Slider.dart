import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late Timer _timer;

  final List<Map<String, String>> slides = const [
    {
      "text": "Discover a variety of delicious cuisines",
      "image": "assets/sammy-line-searching.gif"
    },
    {
      "text": "Seamlessly add items to your cart and place orders",
      "image": "assets/sammy-line-shopping.gif"
    },
    {
      "text": "Enjoy prompt and reliable delivery service",
      "image": "assets/sammy-line-delivery.gif"
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < slides.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10), // Less padding
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      // Text on the left
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            slide["text"]!,
                            key: ValueKey(slide["text"]),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14, // Smaller font
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 0), // Reduced spacing

                      // Image on the right
                      SizedBox(
                        width: 120, // Slightly smaller image
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: Image.asset(
                            slide["image"]!,
                            key: ValueKey(slide["image"]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Smooth page indicator
          SmoothPageIndicator(
            controller: _controller,
            count: slides.length,
            effect: WormEffect(
              dotColor: Colors.grey.shade300,
              activeDotColor: Theme.of(context).primaryColor,
              dotHeight: 10,
              dotWidth: 10,
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
