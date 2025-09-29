import 'package:flutter/material.dart';

class ExamplesScreen extends StatelessWidget {
  const ExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples & Documentation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dynamic Popup Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'This screen shows examples of the markdown syntax and code usage for the dynamic_popup package.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            // Simple Text Field Example
            const Text(
              '1. Simple Text Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                ':::dc<textfield id="name" label="Your Name" placeholder="Enter your name" />dc:::',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            
            // Required Text Field Example
            const Text(
              '2. Required Text Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                ':::dc<textfield id="email" required label="Email" placeholder="Enter your email" />dc:::',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            
            // Radio Button Example
            const Text(
              '3. Radio Button with Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                ''':::dc<radiobutton id="satisfaction" required label="Satisfaction">
  <option id="very_satisfied">Very Satisfied</option>
  <option id="satisfied">Satisfied</option>
  <option id="neutral">Neutral</option>
  <option id="dissatisfied">Dissatisfied</option>
</radiobutton>dc:::''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            
            // Checkbox Example
            const Text(
              '4. Checkbox with Multiple Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                ''':::dc<checkbox id="interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
  <option id="music">Music</option>
  <option id="travel">Travel</option>
</checkbox>dc:::''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            
            // Dropdown Example
            const Text(
              '5. Dropdown with Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                ''':::dc<dropdown id="country" required label="Country">
  <option id="us">United States</option>
  <option id="ca">Canada</option>
  <option id="uk">United Kingdom</option>
  <option id="au">Australia</option>
</dropdown>dc:::''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            
            // Text Area Example
            const Text(
              '6. Text Area',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                ':::dc<textarea id="feedback" label="Feedback" placeholder="Share your thoughts..." />dc:::',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Complete Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                '''# Survey

This is a sample survey popup.

:::dc<textfield id="name" required label="Full Name" placeholder="Enter your name" />dc:::

:::dc<dropdown id="age" required label="Age Group">
  <option id="18-25">18-25</option>
  <option id="26-35">26-35</option>
  <option id="36-45">36-45</option>
  <option id="46+">46+</option>
</dropdown>dc:::

:::dc<radiobutton id="satisfaction" required label="How satisfied are you?">
  <option id="very_satisfied">Very Satisfied</option>
  <option id="satisfied">Satisfied</option>
  <option id="neutral">Neutral</option>
  <option id="dissatisfied">Dissatisfied</option>
</radiobutton>dc:::

:::dc<checkbox id="interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
  <option id="music">Music</option>
  <option id="travel">Travel</option>
</checkbox>dc:::

:::dc<textarea id="comments" label="Additional Comments" placeholder="Any other thoughts?" />dc:::''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Code Usage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'final config = PopupConfig(\n'
                '  id: \'survey_popup\',\n'
                '  title: \'Customer Survey\',\n'
                '  markdownContent: \'\'\'\n'
                '# Survey\n\n'
                ':::dc<textfield id="name" required label="Full Name" placeholder="Enter your name" />dc:::\n\n'
                ':::dc<radiobutton id="satisfaction" required label="Satisfaction">\n'
                '  <option id="satisfied">Satisfied</option>\n'
                '  <option id="neutral">Neutral</option>\n'
                '  <option id="dissatisfied">Dissatisfied</option>\n'
                '</radiobutton>dc:::\n'
                '  \'\'\',\n'
                '  isBlocking: false,\n'
                '  showOnce: true,\n'
                ');\n\n'
                'showDialog(\n'
                '  context: context,\n'
                '  builder: (BuildContext context) {\n'
                '    return DynamicPopupWidget(\n'
                '      config: config,\n'
                '      onCompleted: (response) {\n'
                '        print(\'Response: \${response.responses}\');\n'
                '      },\n'
                '      onDismissed: () {\n'
                '        print(\'Popup was dismissed\');\n'
                '      },\n'
                '    );\n'
                '  },\n'
                ');',
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}