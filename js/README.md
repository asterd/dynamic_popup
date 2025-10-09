# Dynamic Popup JavaScript Implementation

This is a pure JavaScript implementation of the Dynamic Popup component that works in web browsers without any server requirements.

## Features

- Parses markdown with dynamic components using the same syntax as the Flutter version
- Supports all component types: text fields, text areas, radio buttons, checkboxes, and dropdowns
- Form validation with visual error indicators
- Responsive design that works on all device sizes
- Smooth animations and transitions
- No external dependencies
- Works completely client-side
- **Conditional Logic Support**: Show/hide components based on other field values
- **Conditional Required Status**: Make fields required based on other field values
- **Dynamic Required Indicators**: Asterisk indicators update dynamically based on conditional logic

## Component Types

1. **Text Field**: `:::dc<textfield id="name" required label="Your Name" placeholder="Enter your name" />dc:::`
2. **Text Area**: `:::dc<textarea id="feedback" label="Feedback" placeholder="Share your thoughts..." />dc:::`
3. **Radio Button**: 
   ```
   :::dc<radiobutton id="satisfaction" required label="Satisfaction">
     <option id="very_satisfied">Very Satisfied</option>
     <option id="satisfied">Satisfied</option>
     <option id="neutral">Neutral</option>
     <option id="dissatisfied">Dissatisfied</option>
   </radiobutton>dc:::
   ```
4. **Checkbox**:
   ```
   :::dc<checkbox id="interests" label="Interests">
     <option id="tech">Technology</option>
     <option id="sports">Sports</option>
     <option id="music">Music</option>
     <option id="travel">Travel</option>
   </checkbox>dc:::
   ```
5. **Dropdown**:
   ```
   :::dc<dropdown id="country" required label="Country">
     <option id="us">United States</option>
     <option id="ca">Canada</option>
     <option id="uk">United Kingdom</option>
     <option id="au">Australia</option>
   </dropdown>dc:::
   ```

## Conditional Logic

The component supports two types of conditional logic:

### 1. Conditional Visibility
Show or hide components based on the value of another field:

```markdown
:::dc<radiobutton id="public_role" required label="Do you hold a public position?">
  <option id="SI">YES</option>
  <option id="NO">NO</option>
</radiobutton>dc:::

:::dc<textfield id="role_details" label="Role details:" depends-on="public_role" when-value="SI" required />dc:::
```

In this example, the `role_details` text field will only be visible when "YES" is selected in the `public_role` radio button.

### 2. Conditional Required Status
Make fields required based on the value of another field:

```markdown
:::dc<radiobutton id="additional_info_needed" required label="Do you have additional information?">
  <option id="SI">YES</option>
  <option id="NO">NO</option>
</radiobutton>dc:::

:::dc<textfield id="additional_info" label="Additional Information:" depends-on="additional_info_needed" required-when-value="SI" />dc:::
```

In this example, the `additional_info` text field is always visible but becomes required only when "YES" is selected in the `additional_info_needed` radio button.

## Usage

1. Include the JavaScript file in your HTML:
   ```html
   <script src="dynamicPopup.js"></script>
   ```

2. Create a popup configuration:
   ```javascript
   const config = {
     id: 'survey_popup',
     title: 'Customer Survey',
     markdownContent: `
   # Survey
   
   :::dc<textfield id="name" required label="Full Name" placeholder="Enter your name" />dc:::
   
   :::dc<radiobutton id="satisfaction" required label="Satisfaction">
     <option id="satisfied">Satisfied</option>
     <option id="neutral">Neutral</option>
     <option id="dissatisfied">Dissatisfied</option>
   </radiobutton>dc:::
     `,
     isBlocking: false
   };
   ```

3. Create and show the popup:
   ```javascript
   const popup = new DynamicPopup(
     config,
     (response) => {
       console.log('Response:', response);
       // Handle the response
       return Promise.resolve();
     },
     () => {
       console.log('Popup was dismissed');
       // Handle dismissal
     }
   );
   
   popup.render();
   ```

## API

### DynamicPopup Constructor

```javascript
new DynamicPopup(config, onCompleted, onDismissed)
```

- `config`: Configuration object with popup settings
- `onCompleted`: Function called when the popup is submitted
- `onDismissed`: Function called when the popup is dismissed

### Configuration Object

```javascript
{
  id: 'string',              // Unique identifier for the popup
  title: 'string',           // Title displayed in the popup header
  markdownContent: 'string', // Markdown content with dynamic components
  isBlocking: boolean        // Whether the popup can be dismissed (default: false)
}
```

### Response Object

When the popup is submitted, the `onCompleted` callback receives a response object:

```javascript
{
  popupId: 'string',         // ID of the popup
  responses: {},             // Key-value pairs of component responses
  timestamp: Date,           // When the response was submitted
  wasCompleted: boolean      // Whether the popup was completed (default: true)
}
```

## Testing

Open `index.html` in a web browser to see examples of all component types in action.

## Customization

The component uses CSS variables for styling. You can customize the appearance by modifying the styles in the `addStyles()` method of `dynamicPopup.js`.

## Browser Support

This implementation works in all modern browsers that support ES6 JavaScript features.