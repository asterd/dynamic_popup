import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dynamic_popup/dynamic_popup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dynamic Popup Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dynamic Popup Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize the DynamicPopupService
  final DynamicPopupService _popupService = Get.put(DynamicPopupService());

  @override
  void initState() {
    super.initState();
    // Initialize the popup service
    _popupService.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Dynamic Popup Package Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'This example demonstrates all the features of the dynamic_popup package.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Test Page Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const DynamicPopupTestPage());
                  },
                  child: const Text('Open Test Page'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Non-blocking Popup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showNonBlockingPopup,
                  child: const Text('Show Non-blocking Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Blocking Popup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showBlockingPopup,
                  child: const Text('Show Blocking Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Complex Popup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showComplexPopup,
                  child: const Text('Show Complex Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Reset States Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetAllStates,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Reset All Popup States'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNonBlockingPopup() {
    final config = PopupConfig(
      id: 'example_non_blocking',
      title: 'Information',
      markdownContent: '''
## Welcome to Dynamic Popup!

This is a non-blocking popup that allows users to close without completing.

[CHECKBOX:optional:features:Which features are you interested in?:Feature A,Feature B,Feature C]

[TEXTAREA:optional:notes:Any questions or comments?:Feel free to share your thoughts...]
      ''',
      isBlocking: false,
      showOnce: false, // For testing, allow multiple shows
    );

    Get.dialog(
      DynamicPopupWidget(
        config: config,
        onCompleted: (response) {
          Get.snackbar(
            'Completed',
            'Response: ${response.responses}',
            backgroundColor: Colors.green.shade100,
          );
        },
        onDismissed: () {
          Get.snackbar(
            'Dismissed',
            'Popup was dismissed',
            backgroundColor: Colors.grey.shade100,
          );
        },
      ),
    );
  }

  void _showBlockingPopup() {
    final config = PopupConfig(
      id: 'example_blocking',
      title: 'Required Action',
      markdownContent: '''
## Terms of Service Update

**Important:** You must accept our updated terms to continue using the app.

[RADIOBUTTON:required:terms_accept:Do you accept the updated terms?:I Accept,I Decline]

[TEXTFIELD:required:signature:Please type your full name as digital signature:Your full name]
      ''',
      isBlocking: true,
      showOnce: false,
    );

    Get.dialog(
      DynamicPopupWidget(
        config: config,
        onCompleted: (response) {
          Get.snackbar(
            'Terms Updated',
            'Thank you for accepting the terms',
            backgroundColor: Colors.green.shade100,
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showComplexPopup() {
    final config = PopupConfig(
      id: 'example_complex',
      title: 'Complete User Survey',
      markdownContent: '''
# User Satisfaction Survey

Help us improve the app by completing this quick survey.

## Personal Information
[TEXTFIELD:required:name:Full Name:Enter your full name]

[DROPDOWN:required:age_group:Age Group:18-25,26-35,36-45,46-55,55+]

## App Usage
[RADIOBUTTON:required:usage_frequency:How often do you use the app?:Daily,Weekly,Monthly,Rarely]

[CHECKBOX:required:used_features:Which features have you used?:Feature A,Feature B,Feature C,Feature D,Feature E]

## Feedback
[TEXTAREA:required:suggestions:What improvements would you suggest?:Please provide detailed feedback...]

[RADIOBUTTON:required:recommend:Would you recommend this app to others?:Definitely,Probably,Not Sure,Probably Not,Definitely Not]

[CHECKBOX:optional:contact_methods:How can we contact you for follow-up?:Email,Phone,In-app notifications]

**Thank you for your time!**
      ''',
      isBlocking: false,
      showOnce: false,
    );

    Get.dialog(
      DynamicPopupWidget(
        config: config,
        onCompleted: (response) {
          Get.snackbar(
            'Survey Completed',
            'Thank you for completing the survey!',
            backgroundColor: Colors.green.shade100,
          );
        },
        onDismissed: () {
          Get.snackbar(
            'Survey Dismissed',
            'Survey was dismissed',
            backgroundColor: Colors.grey.shade100,
          );
        },
      ),
    );
  }

  void _resetAllStates() {
    _popupService.resetAllPopupStates();
    Get.snackbar(
      'Reset',
      'All popup states have been reset',
      backgroundColor: Colors.orange.shade100,
    );
  }
}