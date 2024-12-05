import 'package:flutter/material.dart';
import 'package:flutter_project_1/utils/constants/image_strings.dart';
import 'package:flutter_project_1/utils/helpers/helper_functions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 56.0,
            left: 24.0,
            bottom: 24.0,
            right: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Us', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16.0),
              Text(
                "Yeterly AI Sign2Text provides quick and easy translation of American Sign Language (ASL) letters by utilizing our own custom-made Machine Learning (ML) model.\n\nUsers can either take a photo with the in-app camera or upload a photo from their photo library of the ASL sign to be translated. Our ML model will immediately show a predicted translation.\n\nWe are always open to feedback! After a predicted translation is made, users can submit a survey on prediction accuracy. Users can also choose to upload images for data collection that will be used by Yeterly to improve and train our models. This can be accessed in the Settings menu.",
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32.0),
              Text('Future Work', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16.0),
              Text(
                "We hope to implement a real-time live processing model that can translate a series of signs and full conversations in ASL. We also hope our model can be applied to other sign languages.",
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
