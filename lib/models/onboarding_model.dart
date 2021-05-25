import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class OnboardingModel {
  final String? title;
  final String? subTitle;
  final String? description;
  final String? localImage;
  final Color? backgroundColor;
  OnboardingModel(
      {this.title,
      this.subTitle,
      this.description,
      this.localImage,
      this.backgroundColor});

  List<OnboardingModel> get getData {
    return [
      OnboardingModel(
          title: "Capture",
          subTitle: "your art",
          description:
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          backgroundColor: colorStyles['blue']),
      OnboardingModel(
          title: "Organise",
          subTitle: "your content",
          description:
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          backgroundColor: colorStyles['dark_purple']),
      OnboardingModel(
          title: "Share",
          subTitle: "your work",
          description:
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          backgroundColor: colorStyles['green'])
    ];
  }
}
