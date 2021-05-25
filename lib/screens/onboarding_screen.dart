import 'package:beauty_fyi/models/onboarding_model.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey _pageViewKey = GlobalKey();
  final PageController _pageController = PageController();
  final List<OnboardingModel> _data = OnboardingModel().getData;
  int _currentIndex = 0;
  createCircle({int? index}) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 100),
        margin: EdgeInsets.only(right: 4),
        height: 5,
        width: _currentIndex == index ? 15 : 5, // current indicator is wider
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView.builder(
          key: _pageViewKey,
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          itemCount: _data.length,
          itemBuilder: (BuildContext context, index) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: _data[index].backgroundColor,
              child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 60, horizontal: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                _data[index].title!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 55.0,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                _data[index].subTitle!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                              SizedBox(
                                height: 250,
                              ),
                              Text(
                                _data[index].description!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ],
                          ),
                          Container(
                              margin: const EdgeInsets.symmetric(vertical: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_data.length,
                                    (index) => createCircle(index: index)),
                              ))
                        ],
                      ))),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/dashboard', (route) => false),
                    child: Text(
                      "Skip",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print(_currentIndex);
                      _currentIndex != 2
                          ? _currentIndex++
                          : Navigator.pushNamedAndRemoveUntil(
                              context, '/dashboard', (route) => false);
                      _pageController.animateToPage(_currentIndex,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCirc);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentIndex == 2 ? "Continue" : "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.arrow_right,
                          color: Colors.white,
                          size: 26,
                        )
                      ],
                    ),
                  ),
                ],
              )),
        )
      ],
    ));
  }
}
