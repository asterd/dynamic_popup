import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dynamic_popup/dynamic_popup.dart';

/// Custom API service that handles all popup-related API calls
/// This is an example of how you can implement your own API integration
class CustomApiService {
  static const String _baseUrl = 'https://your-api-domain.com/api';

  /// Fetch popup configuration from your custom API
  static Future<PopupConfig?> fetchPopupForScreen(String screenName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/popups/screen/$screenName'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return PopupConfig.fromJson(jsonResponse);
      } else {
        print('Failed to fetch popup: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching popup: $e');
      return null;
    }
  }

  /// Submit popup response to your custom API
  static Future<bool> submitPopupResponse(PopupResponse response) async {
    try {
      final httpResponse = await http.post(
        Uri.parse('$_baseUrl/popups/response'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(response.toJson()),
      );

      return httpResponse.statusCode == 200;
    } catch (e) {
      print('Error submitting popup response: $e');
      return false;
    }
  }
}

/// Simple implementation of DynamicPopupRepository
/// This shows the minimal implementation required
class SimplePopupRepository extends BaseDynamicPopupRepository {
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // In a real implementation, you would call your API here
    // For this example, we'll simulate a response
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Example response - in a real app, this would come from your API
    if (screenName == 'home') {
      final popup = PopupConfig(
        id: 'welcome_popup',
        title: 'Welcome!',
        markdownContent: '''
## Welcome to our app!

[RADIOBUTTON:required:enjoying:Are you enjoying the app?:Yes,No,Neutral]

[TEXTAREA:optional:feedback:Feedback:Any suggestions?]
        ''',
        isBlocking: false,
        showOnce: true,
      );
      
      return PopupApiResponse(hasPopup: true, popup: popup);
    }
    
    return PopupApiResponse(hasPopup: false);
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // In a real implementation, you would call your API here
    // For this example, we'll just simulate a successful response
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    
    print('Submitted response for popup ${popupResponse.popupId}');
    print('Response data: ${popupResponse.responses}');
    
    // Return true to indicate success
    return true;
  }
}

/// Advanced implementation with optional methods
class AdvancedPopupRepository extends BaseDynamicPopupRepository {
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // Call your custom API service
    // return await CustomApiService.checkForPopup(screenName: screenName, userId: userId);
    
    // For demo purposes, simulate a response
    await Future.delayed(Duration(milliseconds: 500));
    
    // Example response
    final popup = PopupConfig(
      id: 'advanced_popup',
      title: 'Advanced Example',
      markdownContent: '''
## Advanced Popup

This popup demonstrates the advanced features.

[TEXTFIELD:required:name:Name:Enter your name]

[CHECKBOX:required:consent:Do you consent?:I agree to the terms]
      ''',
      isBlocking: true,
      showOnce: true,
    );
    
    return PopupApiResponse(hasPopup: true, popup: popup);
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // Call your custom API service
    // return await CustomApiService.submitPopupResponse(popupResponse);
    
    // For demo purposes, simulate a response
    await Future.delayed(Duration(milliseconds: 300));
    print('Advanced: Submitted response for popup ${popupResponse.popupId}');
    return true;
  }
  
  // Optional method - only implement if you need it
  @override
  Future<bool> markPopupAsShown({
    required String popupId,
    String? userId,
  }) async {
    // Implement your tracking logic here
    print('Advanced: Popup $popupId marked as shown');
    return true;
  }
  
  // Optional method - only implement if you need it
  @override
  Future<bool> markPopupAsDismissed({
    required String popupId,
    String? userId,
  }) async {
    // Implement your tracking logic here
    print('Advanced: Popup $popupId marked as dismissed');
    return true;
  }
}

/// Example widget showing how to use the dynamic popup with custom API integration
class ApiIntegrationExample extends StatefulWidget {
  @override
  _ApiIntegrationExampleState createState() => _ApiIntegrationExampleState();
}

class _ApiIntegrationExampleState extends State<ApiIntegrationExample> {
  // Example with simple repository
  final DynamicPopupService _simpleService = DynamicPopupService(
    repository: SimplePopupRepository(),
  );
  
  // Example with advanced repository
  final DynamicPopupService _advancedService = DynamicPopupService(
    repository: AdvancedPopupRepository(),
  );

  @override
  void initState() {
    super.initState();
    // Initialize the popup services
    _simpleService.init();
    _advancedService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Integration Example'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Custom API Integration Examples',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'These examples show different ways to integrate the dynamic popup package '
              'with your own custom API implementation.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showSimplePopup(context),
              child: Text('Simple Implementation'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAdvancedPopup(context),
              child: Text('Advanced Implementation'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showDirectPopup(context),
              child: Text('Direct API Usage'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetMockData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Reset Mock Data'),
            ),
          ],
        ),
      ),
    );
  }

  /// Example of simple implementation
  void _showSimplePopup(BuildContext context) async {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final wasShown = await _simpleService.checkAndShowPopup(
      screenName: 'home',
      context: currentContext,
    );

    // Check if the context is still mounted before showing snackbar
    if (!currentContext.mounted) return;
    
    if (!wasShown) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('No popup to show (simple implementation)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Example of advanced implementation
  void _showAdvancedPopup(BuildContext context) async {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final wasShown = await _advancedService.checkAndShowPopup(
      screenName: 'advanced',
      context: currentContext,
    );

    // Check if the context is still mounted before showing snackbar
    if (!currentContext.mounted) return;
    
    if (!wasShown) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('No popup to show (advanced implementation)'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  /// Example of direct API usage without service
  void _showDirectPopup(BuildContext context) async {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    // Directly fetch popup from your API
    final popupConfig = await CustomApiService.fetchPopupForScreen('direct_example');

    // Check if the context is still mounted before showing the dialog
    if (!currentContext.mounted) return;

    if (popupConfig != null) {
      // Show the popup using Flutter's showDialog
      await showDialog(
        context: currentContext,
        barrierDismissible: !popupConfig.isBlocking,
        builder: (BuildContext context) {
          return DynamicPopupWidget(
            config: popupConfig,
            onCompleted: (response) async {
              // Handle completion by submitting to your API
              final success = await CustomApiService.submitPopupResponse(response);
              
              // Check if the context is still mounted before showing snackbar
              if (!context.mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Response submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit response'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            onDismissed: () {
              // Check if the context is still mounted before showing snackbar
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Popup was dismissed'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
          );
        },
      );
    } else {
      // Check if the context is still mounted before showing the dialog
      if (!currentContext.mounted) return;
      
      // Show a fallback popup or handle the error
      final fallbackConfig = PopupConfig(
        id: 'fallback',
        title: 'Information',
        markdownContent: '''
## Welcome!

This is a fallback popup shown when the API is not available.

[TEXTFIELD:optional:name:Your Name:Enter your name]
        ''',
        isBlocking: false,
        showOnce: false,
      );

      await showDialog(
        context: currentContext,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DynamicPopupWidget(
            config: fallbackConfig,
            onCompleted: (response) {
              // Check if the context is still mounted before showing snackbar
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fallback response: ${response.responses}'),
                  backgroundColor: Colors.blue,
                ),
              );
              Navigator.of(context).pop();
            },
            onDismissed: () {
              // Check if the context is still mounted before showing snackbar
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fallback popup dismissed'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
          );
        },
      );
    }
  }

  /// Reset mock data for testing
  void _resetMockData() {
    // In a real app, you might want to reset your mock data or API state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mock data reset'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}