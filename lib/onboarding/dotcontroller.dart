import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';


class CustomDotControllerOnBoarding extends StatelessWidget {
  final int currentPage;

  const CustomDotControllerOnBoarding({
    Key? key,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          3,
              (index) => AnimatedContainer(
            margin: const EdgeInsetsDirectional.only(end: 5),
            duration: const Duration(milliseconds: 900),
            width: currentPage == index ? 20 : 5,
            height: 6,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}