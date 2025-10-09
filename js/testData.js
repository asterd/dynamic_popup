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

// Conditional logic popup configuration - Visibility Example
const conditionalVisibilityConfig = {
  id: 'conditional_visibility',
  title: 'Conditional Visibility Example',
  markdownContent: `
# Conditional Visibility Example

This example demonstrates how fields can be shown or hidden based on other field values.

:::dc<radiobutton id="public_role" required label="Do you or your family members currently hold a position in Public Administration or hold functions within Public Institutions?">
  <option id="SI">YES</option>
  <option id="NO">NO</option>
</radiobutton>dc:::

## Conditional Fields (Visible when "YES" is selected above)

The following fields are visible only if you select "YES" in the question above:

:::dc<textfield id="role_details" label="Degree of kinship/affinity:" placeholder="" depends-on="public_role" when-value="SI" required />dc:::

:::dc<dropdown id="relationship_type" label="Type of relationship:" depends-on="public_role" when-value="SI" required>
  <option id="family">Degree of kinship/affinity</option>
  <option id="public_admin">Public Administration and/or Public Institution</option>
</dropdown>dc:::

:::dc<textfield id="institution_name" label="Public Administration and/or Public Institution:" placeholder="" depends-on="public_role" when-value="SI" />dc:::
  `,
  isBlocking: true,
  showOnce: false
};

// Conditional logic popup configuration - Required Example
const conditionalRequiredConfig = {
  id: 'conditional_required',
  title: 'Conditional Required Example',
  markdownContent: `
# Conditional Required Example

This example demonstrates how fields can become required based on other field values.

:::dc<radiobutton id="additional_info_needed" required label="Do you have additional information to provide?">
  <option id="SI">YES</option>
  <option id="NO">NO</option>
</radiobutton>dc:::

## Conditional Required Field

The following field is always visible, but becomes required only if you select "YES" in the question above:

:::dc<textfield id="additional_info" label="Additional Information:" placeholder="Provide further details" depends-on="additional_info_needed" required-when-value="SI" />dc:::
  `,
  isBlocking: true,
  showOnce: false
};

// Complete conditional logic example
const completeConditionalLogicConfig = {
  id: 'complete_conditional_logic',
  title: 'Complete Conditional Logic Example',
  markdownContent: `
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

:::dc<textfield id="additional_info" label="Informazioni aggiuntive:" placeholder="Fornisci ulteriori dettagli" depends-on="additional_info_needed" required-when-value="SI" />dc:::
  `,
  isBlocking: true,
  showOnce: false
};

// Example of how to use the configurations
function showPopupWithConfig(config) {
  const popup = new DynamicPopup(
    config,
    (response) => {
      console.log('Popup completed with response:', response);
      // Handle the response here (e.g., send to server)
      alert('Form submitted successfully! Check the console for details.');
      return Promise.resolve();
    },
    () => {
      console.log('Popup was dismissed');
      // Handle dismissal here
      alert('Popup was dismissed');
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
  blockingSurvey: blockingSurveyConfig,
  conditionalVisibility: conditionalVisibilityConfig,
  conditionalRequired: conditionalRequiredConfig,
  completeConditionalLogic: completeConditionalLogicConfig
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
  showBlockingSurvey: () => showPopupWithConfig(blockingSurveyConfig),
  showConditionalVisibility: () => showPopupWithConfig(conditionalVisibilityConfig),
  showConditionalRequired: () => showPopupWithConfig(conditionalRequiredConfig),
  showCompleteConditionalLogic: () => showPopupWithConfig(completeConditionalLogicConfig)
};