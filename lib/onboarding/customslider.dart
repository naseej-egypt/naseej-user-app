import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/static.dart';

class CustomSliderOnBoarding extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;

  const CustomSliderOnBoarding({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = getOnBoardingList(context);
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: list.length,
      itemBuilder: (context, i) => Column(
        children: [
          Image.asset(
            list[i].image!,
            height: MediaQuery.of(context).size.width / 1.1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 60),
          Text(
            list[i].title!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColor.black,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              list[i].body!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 2,
                color: AppColor.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}