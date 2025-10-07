// Test data for DynamicPopup component

// Simple text field popup configuration
const simpleTextFieldConfig = {
  id: 'simple_text_field',
  title: 'Simple Text Field',
  markdownContent: `
# Simple Text Field

This is a simple text field example.

:::dc<textfield id="name" label="Your Name" placeholder="Enter your name" />dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Required text field popup configuration
const requiredTextFieldConfig = {
  id: 'required_text_field',
  title: 'Required Text Field',
  markdownContent: `
# Required Text Field

This field is required and must be filled.

:::dc<textfield id="email" required label="Email" placeholder="Enter your email" />dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Radio button popup configuration
const radioButtonConfig = {
  id: 'radio_button',
  title: 'Radio Button Example',
  markdownContent: `
# Radio Button Example

Please select your satisfaction level.

:::dc<radiobutton id="satisfaction" required label="Satisfaction">
  <option id="very_satisfied">Very Satisfied</option>
  <option id="satisfied">Satisfied</option>
  <option id="neutral">Neutral</option>
  <option id="dissatisfied">Dissatisfied</option>
</radiobutton>dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Checkbox popup configuration
const checkboxConfig = {
  id: 'checkbox',
  title: 'Checkbox Example',
  markdownContent: `
# Checkbox Example

Select your interests.

:::dc<checkbox id="interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
  <option id="music">Music</option>
  <option id="travel">Travel</option>
</checkbox>dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Dropdown popup configuration
const dropdownConfig = {
  id: 'dropdown',
  title: 'Dropdown Example',
  markdownContent: `
# Dropdown Example

Please select your country.

:::dc<dropdown id="country" required label="Country">
  <option id="us">United States</option>
  <option id="ca">Canada</option>
  <option id="uk">United Kingdom</option>
  <option id="au">Australia</option>
</dropdown>dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Text area popup configuration
const textAreaConfig = {
  id: 'text_area',
  title: 'Text Area Example',
  markdownContent: `
# Text Area Example

Please share your feedback.

:::dc<textarea id="feedback" label="Feedback" placeholder="Share your thoughts..." />dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Complete survey popup configuration
const completeSurveyConfig = {
  id: 'complete_survey',
  title: 'Customer Survey',
  markdownContent: `
# Customer Survey

Thank you for taking our survey. Your feedback is important to us.

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

:::dc<textarea id="comments" label="Additional Comments" placeholder="Any other thoughts?" />dc:::
  `,
  isBlocking: false,
  showOnce: true
};

// Blocking survey popup configuration
const blockingSurveyConfig = {
  id: 'blocking_survey',
  title: 'Mandatory Survey',
  markdownContent: `
# Mandatory Survey

This is a mandatory survey that must be completed.

:::dc<textfield id="name" required label="Full Name" placeholder="Enter your name" />dc:::

:::dc<radiobutton id="satisfaction" required label="How satisfied are you?">
  <option id="very_satisfied">Very Satisfied</option>
  <option id="satisfied">Satisfied</option>
  <option id="neutral">Neutral</option>
  <option id="dissatisfied">Dissatisfied</option>
</radiobutton>dc:::
  `,
  isBlocking: true,
  showOnce: true
};

// Example of how to use the configurations
function showPopupWithConfig(config) {
  const popup = new DynamicPopup(
    config,
    (response) => {
      console.log('Popup completed with response:', response);
      // Handle the response here (e.g., send to server)
      return Promise.resolve();
    },
    () => {
      console.log('Popup was dismissed');
      // Handle dismissal here
    }
  );
  
  popup.render();
}

// Export configurations for use in other files
window.popupConfigs = {
  simpleTextField: simpleTextFieldConfig,
  requiredTextField: requiredTextFieldConfig,
  radioButton: radioButtonConfig,
  checkbox: checkboxConfig,
  dropdown: dropdownConfig,
  textArea: textAreaConfig,
  completeSurvey: completeSurveyConfig,
  blockingSurvey: blockingSurveyConfig
};

// Example usage functions
window.examples = {
  showSimpleTextField: () => showPopupWithConfig(simpleTextFieldConfig),
  showRequiredTextField: () => showPopupWithConfig(requiredTextFieldConfig),
  showRadioButton: () => showPopupWithConfig(radioButtonConfig),
  showCheckbox: () => showPopupWithConfig(checkboxConfig),
  showDropdown: () => showPopupWithConfig(dropdownConfig),
  showTextArea: () => showPopupWithConfig(textAreaConfig),
  showCompleteSurvey: () => showPopupWithConfig(completeSurveyConfig),
  showBlockingSurvey: () => showPopupWithConfig(blockingSurveyConfig)
};