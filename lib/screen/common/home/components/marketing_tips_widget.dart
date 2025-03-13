import 'dart:async';
import 'package:flutter/material.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MarketingTipsWidget extends StatefulWidget {
  final Function? onLocaleChanged;

  const MarketingTipsWidget({Key? key, this.onLocaleChanged}) : super(key: key);

  @override
  _MarketingTipsWidgetState createState() => _MarketingTipsWidgetState();
}

class _MarketingTipsWidgetState extends State<MarketingTipsWidget> {
  final PageController _pageController = PageController();
  Timer? _timer;
  List<String> _tips = [];
  int _currentIndex = 0;

  void _loadTips() {
    if (mounted) {
      setState(() {
        _tips = List.generate(
            5,
            (index) => AppLocalizations.of(context)!
                .translate('marketingTip${index + 1}'));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTips();
    });

    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (_currentIndex < _tips.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (mounted && _pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload tips when dependencies change (like locale)
    _loadTips();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _tips.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(10),
                // Added constraints to ensure the container has enough height
                constraints: BoxConstraints(
                  minHeight: 150, // Adjust this value as needed
                ),
                child: Center(
                  child: Text(
                    _tips.isNotEmpty && index < _tips.length
                        ? _tips[index]
                        : "",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
        SmoothPageIndicator(
          controller: _pageController,
          count: _tips.length > 0 ? _tips.length : 5,
          effect: WormEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.green,
            dotColor: Colors.grey,
            spacing: 8,
          ),
        ),
      ],
    );
  }
}
