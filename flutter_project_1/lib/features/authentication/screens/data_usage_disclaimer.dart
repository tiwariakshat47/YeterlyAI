import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/translation/image_selection.dart';
import 'package:flutter_project_1/utils/constants/image_strings.dart';
import 'package:flutter_project_1/utils/helpers/helper_functions.dart';

class DataUsageDisclaimerScreen extends StatelessWidget {
  const DataUsageDisclaimerScreen({super.key});

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
      body: Center(
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
              Text('How We Use Your Data', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16.0),
              Expanded(
                child: Text(
                  'Yeterly AI Sign2Text stores your uploaded images to a secure database, only to be used by Yeterly Software for training and improving our Sign Language recognition models. We will keep your data private!\n\nUsing Yeterly AI Sign2Text will require providing us access to your camera and photo library. By using this application, you are agreeing to provide us with access to uploaded images of your choice, your camera, and photo library.',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ImageSelection();
                          },
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                    ),
                    child: Text("Agree", style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
