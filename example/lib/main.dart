import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dynamic_popup/dynamic_popup.dart';
import 'mock_popup_repository.dart';
import 'api_integration_example.dart';
import 'examples_screen.dart';

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
              
              // Simple Optional Popup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showSimpleOptionalPopup(context),
                  child: const Text('Simple Optional Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Simple Required Popup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showSimpleRequiredPopup(context),
                  child: const Text('Simple Required Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Complex Optional Popup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showComplexOptionalPopup(context),
                  child: const Text('Complex Optional Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Complex Required Popup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showComplexRequiredPopup(context),
                  child: const Text('Complex Required Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Conditional Logic Popup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showConditionalLogicPopup(context),
                  child: const Text('Conditional Logic Popup'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Popup from API (mock)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showApiPopup(context),
                  child: const Text('Popup from API (Mock)'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Examples/README Screen
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExamplesScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('View Examples & Documentation'),
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

  void _showSimpleOptionalPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final markdownContent = '''
## Information

This is a simple optional popup with one field.

:::dc<textfield id="simple_optional_name" label="Your Name" placeholder="Enter your name" />dc:::''';
    
    final config = PopupConfig(
      id: 'example_simple_optional',
      title: 'Simple Optional Popup',
      markdownContent: markdownContent,
      isBlocking: false,
      showOnce: false, // For testing, allow multiple shows
    );

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          customActions: [
            TextButton(
              onPressed: () {
                // Show the markdown content in a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Markdown Content'),
                      content: SingleChildScrollView(
                        child: Text(markdownContent),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('View Markdown'),
            ),
          ],
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

  void _showSimpleRequiredPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    const markdownContent = '''
## Required Information

This is a simple required popup with one field.

:::dc<textfield id="simple_required_name" required label="Your Name" placeholder="Enter your name" />dc:::''';
    
    final config = PopupConfig(
      id: 'example_simple_required',
      title: 'Simple Required Popup',
      markdownContent: markdownContent,
      isBlocking: true,
      showOnce: false, // For testing, allow multiple shows
    );

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          customActions: [
            TextButton(
              onPressed: () {
                // Show the markdown content in a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Markdown Content'),
                      content: const SingleChildScrollView(
                        child: Text(markdownContent),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('View Markdown'),
            ),
          ],
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

  void _showComplexOptionalPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final markdownContent = '''
# Survey

This is a complex optional popup with multiple fields.

:::dc<textfield id="complex_optional_name" label="Your Name" placeholder="Enter your name" />dc:::

:::dc<dropdown id="complex_optional_age" label="Age Group">
  <option id="18-25">18-25</option>
  <option id="26-35">26-35</option>
  <option id="36-45">36-45</option>
  <option id="46+">46+</option>
</dropdown>dc:::

:::dc<checkbox id="complex_optional_interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
  <option id="music">Music</option>
  <option id="travel">Travel</option>
</checkbox>dc:::

:::dc<textarea id="complex_optional_feedback" label="Feedback" placeholder="Share your thoughts..." />dc:::''';
    
    final config = PopupConfig(
      id: 'example_complex_optional',
      title: 'Complex Optional Popup',
      markdownContent: markdownContent,
      isBlocking: false,
      showOnce: false, // For testing, allow multiple shows
    );

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          customActions: [
            TextButton(
              onPressed: () {
                // Show the markdown content in a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Markdown Content'),
                      content: SingleChildScrollView(
                        child: Text(markdownContent),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('View Markdown'),
            ),
          ],
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

  void _showComplexRequiredPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final markdownContent = '''
# Required Survey

This is a complex required popup with multiple fields.

:::dc<textfield id="complex_required_name" required label="Your Name" placeholder="Enter your name" />dc:::

:::dc<dropdown id="complex_required_age" required label="Age Group">
  <option id="18-25">18-25</option>
  <option id="26-35">26-35</option>
  <option id="36-45">36-45</option>
  <option id="46+">46+</option>
</dropdown>dc:::

:::dc<radiobutton id="complex_required_satisfaction" required label="Satisfaction">
  <option id="very_satisfied">Very Satisfied</option>
  <option id="satisfied">Satisfied</option>
  <option id="neutral">Neutral</option>
  <option id="dissatisfied">Dissatisfied</option>
  <option id="very_dissatisfied">Very Dissatisfied</option>
</radiobutton>dc:::

:::dc<checkbox id="complex_required_interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
  <option id="music">Music</option>
  <option id="travel">Travel</option>
</checkbox>dc:::

:::dc<textarea id="complex_required_feedback" required label="Feedback" placeholder="Share your thoughts..." />dc:::''';
    
    final config = PopupConfig(
      id: 'example_complex_required',
      title: 'Complex Required Popup',
      markdownContent: markdownContent,
      isBlocking: true,
      showOnce: false, // For testing, allow multiple shows
    );

    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          customActions: [
            TextButton(
              onPressed: () {
                // Show the markdown content in a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Markdown Content'),
                      content: SingleChildScrollView(
                        child: Text(markdownContent),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('View Markdown'),
            ),
          ],
          onCompleted: (response) {
            // Check if the context is still mounted before showing snackbar
            if (!context.mounted) return;
            
            // Log the response JSON to console
            print('Popup response JSON: ${jsonEncode(response.toJson())}');
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for completing the survey'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  void _showApiPopup(BuildContext context) async {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    // First, try to get a popup from the mock API
    final apiResponse = await _popupService.repository.checkForPopup(
      screenName: 'product_screen',
    );
    
    if (apiResponse?.hasPopup == true && apiResponse?.popup != null) {
      final popup = apiResponse!.popup!;
      
      // Check if the context is still mounted before showing the dialog
      if (!currentContext.mounted) return;
      
      await showDialog(
        context: currentContext,
        barrierDismissible: !popup.isBlocking,
        builder: (BuildContext context) {
          return DynamicPopupWidget(
            config: popup,
            customActions: [
              TextButton(
                onPressed: () {
                  // Show the markdown content in a dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Markdown Content'),
                        content: SingleChildScrollView(
                          child: Text(popup.markdownContent),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('View Markdown'),
              ),
            ],
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
    } else {
      // Show a fallback popup if no API popup is available
      final markdownContent = '''
# API Mock Popup

This popup simulates content from an API.

:::dc<radiobutton id="api_mock_consent" required label="Do you consent?">
  <option id="yes">Yes</option>
  <option id="no">No</option>
</radiobutton>dc:::

:::dc<textfield id="api_mock_email" required label="Email" placeholder="Enter your email" />dc:::''';
      
      final fallbackConfig = PopupConfig(
        id: 'fallback_api_popup',
        title: 'API Mock Popup',
        markdownContent: markdownContent,
        isBlocking: false,
        showOnce: false,
      );

      // Check if the context is still mounted before showing the dialog
      if (!currentContext.mounted) return;
      
      await showDialog(
        context: currentContext,
        builder: (BuildContext context) {
          return DynamicPopupWidget(
            config: fallbackConfig,
            customActions: [
              TextButton(
                onPressed: () {
                  // Show the markdown content in a dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Markdown Content'),
                        content: SingleChildScrollView(
                          child: Text(markdownContent),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('View Markdown'),
              ),
            ],
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

  void _showConditionalLogicPopup(BuildContext context) {
    // Store the context in a local variable to ensure it's still valid
    final currentContext = context;
    
    final markdownContent = '''
# PROCEDURA PER LA GESTIONE DEGLI EVENTI "FRIENDS & FAMILY"

Nel quadro del modello di Modello di Organizzazione, Gestione e Controllo adottato dalla nostra Società ai sensi del D.lgs. 231/2001, pubblichiamo questa procedura.

## Informazioni Personali

Lei o i suoi familiari ha / hanno attualmente un incarico nella Pubblica Amministrazione o ricopre / ricoprono attualmente funzioni all'interno di Istituzioni Pubbliche?

:::dc<radiobutton id="public_role" required label="Ruolo pubblico:">
  <option id="SI">SI</option>
  <option id="NO">NO</option>
</radiobutton>dc:::

## Esempio 1: Campo con visibilità condizionale

I seguenti campi sono visibili solo se si seleziona "SI" nella domanda sopra:

:::dc<textfield id="role_details" label="Grado di parentela/affinità:" placeholder="" depends-on="public_role" when-value="SI" required />dc:::

:::dc<dropdown id="relationship_type" label="Tipologia di relazione:" depends-on="public_role" when-value="SI" required>
  <option id="family">Grado di parentela/affinità</option>
  <option id="public_admin">Pubblica Amministrazione e/o Istituzione Pubblica</option>
</dropdown>dc:::

:::dc<textfield id="institution_name" label="Pubblica Amministrazione e/o Istituzione Pubblica:" placeholder="" depends-on="public_role" when-value="SI" />dc:::

## Esempio 2: Campo con obbligatorietà condizionale

Il seguente campo è sempre visibile, ma diventa obbligatorio solo se si seleziona "SI" nella domanda qui sotto:

:::dc<radiobutton id="additional_info_needed" required label="Hai informazioni aggiuntive da fornire?">
  <option id="SI">SI</option>
  <option id="NO">NO</option>
</radiobutton>dc:::

:::dc<textfield id="additional_info" label="Informazioni aggiuntive:" placeholder="Fornisci ulteriori dettagli" depends-on="additional_info_needed" required-when-value="SI" />dc:::''';
    
    final config = PopupConfig(
      id: 'conditional_logic_example',
      title: 'Procedura Friends & Family',
      markdownContent: markdownContent,
      isBlocking: true,
      showOnce: false, // For testing, allow multiple shows
    );

    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return DynamicPopupWidget(
          config: config,
          customActions: [
            TextButton(
              onPressed: () {
                // Show the markdown content in a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Markdown Content'),
                      content: SingleChildScrollView(
                        child: Text(markdownContent),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('View Markdown'),
            ),
          ],
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
}