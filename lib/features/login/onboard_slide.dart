import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "https://picsum.photos/id/1011/600/400",
      "title": "Discover New Styles",
      "desc":
          "Explore the latest fashion trends and discover outfits that suit your unique personality.",
    },
    {
      "image": "https://picsum.photos/id/1018/600/400",
      "title": "Share Your Closet",
      "desc":
          "Upload and share your wardrobe with friends or discover what others are wearing.",
    },
    {
      "image": "https://picsum.photos/id/1015/600/400",
      "title": "Start Your Journey",
      "desc":
          "Join our community and take your first step into the world of Closet Share.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SizedBox(
                    height: 550,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              page["image"]!,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              page["desc"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // indicator + nút
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFF00073E),
                    dotColor: Colors.grey,
                    dotHeight: 20,
                    dotWidth: 20,
                    spacing: 10,
                    expansionFactor: 3,
                  ),
                ),
                const SizedBox(height: 24),

                // hiện nút Start Now ở slide cuối
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00073E),
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Start Now",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
