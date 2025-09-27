import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dynamic_popup/dynamic_popup.dart';
import 'mock_popup_repository.dart';
import 'api_integration_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  // Initialize the DynamicPopupService with a mock repository
  final DynamicPopupService _popupService = DynamicPopupService(
    repository: MockDynamicPopupRepository(),
  );

  @override
  void initState() {
    super.initState();
    // Initialize the popup service
    _popupService.init();
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
                'This example demonstrates the features of the dynamic_popup package.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Test Page Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DynamicPopupTestPage(),
                      ),
                    );
                  },
                  child: const Text('Open Test Page'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Non-blocking Popup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showNonBlockingPopup(context),
                  child: const Text('Show Non-blocking Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Blocking Popup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showBlockingPopup(context),
                  child: const Text('Show Blocking Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Check for popup on home screen (mock)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkForPopup(context, 'home_screen'),
                  child: const Text('Check for Home Screen Popup (Mock)'),
                ),
              ),
              const SizedBox(height: 12),
              
              // API Integration Example Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApiIntegrationExample(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('API Integration Example'),
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

  void _showNonBlockingPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
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

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          onCompleted: (response) {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            // Log the response JSON to console
            print('Popup response JSON: ${jsonEncode(response.toJson())}');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Response: ${response.responses}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onDismissed: () {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Popup was dismissed'),
                backgroundColor: Colors.grey,
                behavior: SnackBarBehavior.floating,
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

    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          onCompleted: (response) {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            // Log the response JSON to console
            print('Popup response JSON: ${jsonEncode(response.toJson())}');
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for accepting the terms'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  void _checkForPopup(BuildContext context, String screenName) async {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final wasShown = await _popupService.checkAndShowPopup(
      screenName: screenName,
      context: currentContext,
    );

    // Check if the context is still mounted before showing snackbar
    if (!currentContext.mounted) return;
    
    if (!wasShown) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('No popup to show for screen: $screenName (mock)'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetAllStates() {
    _popupService.resetAllPopupStates();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All popup states have been reset'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}