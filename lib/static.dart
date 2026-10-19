import 'package:flutter/material.dart';
import 'package:naseej/core/constant/imgaeasset.dart';
import 'package:naseej/onboarding/onboardingmodel.dart';
import 'package:naseej/l10n/app_localizations.dart';

List<OnBoardingModel> getOnBoardingList(BuildContext context) {
  final l = AppLocalizations.of(context)!;
  return [
    OnBoardingModel(
      title: l.onboardingTitle1,
      body: l.onboardingBody1,
      image: AppImageAsset.onBoardingImageOne,
    ),
    OnBoardingModel(
      title: l.onboardingTitle2,
      body: l.onboardingBody2,
      image: AppImageAsset.onBoardingImageTwo,
    ),
    OnBoardingModel(
      title: l.onboardingTitle3,
      body: l.onboardingBody3,
      image: AppImageAsset.onBoardingImageThree,
    ),
  ];
}