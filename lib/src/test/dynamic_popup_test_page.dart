import 'package:flutter/material.dart';
import 'package:dynamic_popup/dynamic_popup.dart';

/// Mock repository for testing purposes
class TestPopupRepository extends BaseDynamicPopupRepository {
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // For testing, we don't actually check for popups from an API
    return PopupApiResponse(hasPopup: false);
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // For testing, we just pretend the response was submitted successfully
    print('Test: Submitted response for popup ${popupResponse.popupId}');
    return true;
  }
}

/// Test widget for the dynamic popup system
class DynamicPopupTestPage extends StatefulWidget {
  const DynamicPopupTestPage({Key? key}) : super(key: key);

  @override
  State<DynamicPopupTestPage> createState() => _DynamicPopupTestPageState();
}

class _DynamicPopupTestPageState extends State<DynamicPopupTestPage> {
  final DynamicPopupService _popupService = DynamicPopupService(
    repository: TestPopupRepository(),
  );

  @override
  void initState() {
    super.initState();
    // Initialize the service
    _popupService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Popup Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Dynamic Popup System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Test Non-blocking popup
            ElevatedButton(
              onPressed: () => _showNonBlockingPopup(context),
              child: const Text('Show Non-blocking Popup'),
            ),
            const SizedBox(height: 12),
            
            // Test Blocking popup
            ElevatedButton(
              onPressed: () => _showBlockingPopup(context),
              child: const Text('Show Blocking Popup'),
            ),
            const SizedBox(height: 12),
            
            // Test Complex popup with all components
            ElevatedButton(
              onPressed: () => _showComplexPopup(context),
              child: const Text('Show Complex Popup'),
            ),
            const SizedBox(height: 12),
            
            // Reset all popup states
            ElevatedButton(
              onPressed: _resetAllStates,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reset All Popup States'),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Example Markdown Syntax:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''# Privacy Policy Update

We have updated our privacy policy. Please review and confirm your preferences.

[RADIOBUTTON:required:privacy_accept:Do you accept the new privacy policy?:Yes,No]

[CHECKBOX:required:data_usage:What data can we use?:Analytics,Marketing,Performance,Crash Reports]

[TEXTAREA:optional:feedback:Any feedback or comments?:Please share your thoughts...]

[TEXTFIELD:required:email:Confirm your email address:Enter your email]

[DROPDOWN:required:notification_pref:Notification preferences:All,Important Only,None]''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNonBlockingPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final config = PopupConfig(
      id: 'test_non_blocking',
      title: 'Information',
      markdownContent: '''
## Welcome to the new feature!

We've added some new functionality that we think you'll love.

[CHECKBOX:optional:features:Which features are you interested in?:Feature A,Feature B,Feature C]

[TEXTAREA:optional:notes:Any questions or comments?:Feel free to share your thoughts...]
      ''',
      isBlocking: false,
      showOnce: false, // For testing, allow multiple shows
    );

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          onCompleted: (response) {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Response: ${response.responses}'),
                backgroundColor: Colors.green.shade100,
              ),
            );
          },
          onDismissed: () {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Popup was dismissed'),
                backgroundColor: Colors.grey.shade100,
              ),
            );
          },
        );
      },
    );
  }

  void _showBlockingPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final config = PopupConfig(
      id: 'test_blocking',
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

    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          onCompleted: (response) {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thank you for accepting the terms'),
                backgroundColor: Colors.green.shade100,
              ),
            );
          },
        );
      },
    );
  }

  void _showComplexPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final config = PopupConfig(
      id: 'test_complex',
      title: 'Complete User Survey',
      markdownContent: '''
# User Satisfaction Survey

Help us improve the app by completing this quick survey.

## Personal Information
[TEXTFIELD:required:name:Full Name:Enter your full name]

[DROPDOWN:required:age_group:Age Group:18-25,26-35,36-45,46-55,55+]

## App Usage
[RADIOBUTTON:required:usage_frequency:How often do you use the app?:Daily,Weekly,Monthly,Rarely]

[CHECKBOX:required:used_features:Which features have you used?:Restaurant,Special Sales,PCM,Snack Bar,Reports]

## Feedback
[TEXTAREA:required:suggestions:What improvements would you suggest?:Please provide detailed feedback...]

[RADIOBUTTON:required:recommend:Would you recommend this app to others?:Definitely,Probably,Not Sure,Probably Not,Definitely Not]

[CHECKBOX:optional:contact_methods:How can we contact you for follow-up?:Email,Phone,In-app notifications]

**Thank you for your time!**
      ''',
      isBlocking: false,
      showOnce: false,
    );

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          onCompleted: (response) {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thank you for completing the survey!'),
                backgroundColor: Colors.green.shade100,
              ),
            );
          },
          onDismissed: () {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Survey was dismissed'),
                backgroundColor: Colors.grey.shade100,
              ),
            );
          },
        );
      },
    );
  }

  void _resetAllStates() {
    _popupService.resetAllPopupStates();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All popup states have been reset'),
        backgroundColor: Colors.orange.shade100,
      ),
    );
  }
}