/**
 * Dynamic Popup Component - JavaScript Implementation
 * This component parses markdown with dynamic components and renders them as interactive UI elements.
 */

// Enum for supported dynamic component types
const DynamicComponentType = {
  radioButton: 'radioButton',
  checkbox: 'checkbox',
  textArea: 'textArea',
  textField: 'textField',
  dropdown: 'dropdown'
};

// Enum for content types in parsed markdown
const ContentType = {
  markdown: 'markdown',
  component: 'component'
};

// Class for conditional logic between components
class ConditionalLogic {
  constructor(dependsOn, condition = 'equals', value, disableWhenHidden = true, requiredWhenVisible = null, requiredWhenValue = null) {
    this.dependsOn = dependsOn; // ID of the component this depends on
    this.condition = condition; // Condition type (equals, notEquals, contains, etc.)
    this.value = value; // Value to compare against for visibility
    this.disableWhenHidden = disableWhenHidden; // Whether to disable validation when hidden
    this.requiredWhenVisible = requiredWhenVisible; // Whether the component should be required when visible (null means use component's default)
    this.requiredWhenValue = requiredWhenValue; // The value of the dependsOn field that makes this component required (null means not conditional)
  }
  
  // Check if the visibility condition is met
  isVisibilityMet(dependentValue) {
    // If value is null, this means no visibility condition was set, so return true (always visible)
    if (this.value === null || this.value === undefined) return true;
    
    if (dependentValue === null || dependentValue === undefined) return false;
    
    switch (this.condition) {
      case 'equals':
        return dependentValue.toString().toLowerCase() === this.value.toString().toLowerCase();
      case 'notEquals':
        return dependentValue.toString().toLowerCase() !== this.value.toString().toLowerCase();
      case 'contains':
        if (Array.isArray(dependentValue)) {
          return dependentValue.some(item => item.toString().toLowerCase() === this.value.toString().toLowerCase());
        } else {
          return dependentValue.toString().includes(this.value.toString());
        }
      case 'notContains':
        if (Array.isArray(dependentValue)) {
          return !dependentValue.some(item => item.toString().toLowerCase() === this.value.toString().toLowerCase());
        } else {
          return !dependentValue.toString().includes(this.value.toString());
        }
      default:
        // Default to equals condition
        return dependentValue.toString().toLowerCase() === this.value.toString().toLowerCase();
    }
  }
  
  // Check if the required condition is met
  isRequiredMet(dependentValue) {
    // If requiredWhenValue is null, this means no required condition was set
    if (this.requiredWhenValue === null || this.requiredWhenValue === undefined) return false;
    
    if (dependentValue === null || dependentValue === undefined) return false;
    
    // Check if the dependent value matches the requiredWhenValue
    switch (this.condition) {
      case 'equals':
        return dependentValue.toString().toLowerCase() === this.requiredWhenValue.toString().toLowerCase();
      case 'notEquals':
        return dependentValue.toString().toLowerCase() !== this.requiredWhenValue.toString().toLowerCase();
      case 'contains':
        if (Array.isArray(dependentValue)) {
          return dependentValue.some(item => item.toString().toLowerCase() === this.requiredWhenValue.toString().toLowerCase());
        } else {
          return dependentValue.toString().includes(this.requiredWhenValue.toString());
        }
      case 'notContains':
        if (Array.isArray(dependentValue)) {
          return !dependentValue.some(item => item.toString().toLowerCase() === this.requiredWhenValue.toString().toLowerCase());
        } else {
          return !dependentValue.toString().includes(this.requiredWhenValue.toString());
        }
      default:
        // Default to equals condition
        return dependentValue.toString().toLowerCase() === this.requiredWhenValue.toString().toLowerCase();
    }
  }
}

// Main DynamicPopup class
class DynamicPopup {
  constructor(config, onCompleted, onDismissed) {
    this.config = config;
    this.onCompleted = onCompleted;
    this.onDismissed = onDismissed || (() => {});
    this.responses = {};
    this.componentErrors = {};
    this.isSubmitting = false;
    this.hasValidationErrors = false;
    this.firstInvalidComponentId = null;
    this.dialogClosed = false;
    
    // Parse the markdown content
    this.parsedContent = this.parseMarkdown(config.markdownContent);
    
    // Initialize responses
    this.initializeResponses();
  }
  
  // Parse markdown content with extraction of dynamic components
  parseMarkdown(markdownContent) {
    const components = [];
    const contentFlow = [];
    
    // Process the content step by step
    let lastEnd = 0;
    let position = 0;
    
    // Pattern to match components
    const componentPattern = /:::dc\s*<([a-zA-Z]+)([^>]*?)(\/?)>/g;
    
    let match;
    while ((match = componentPattern.exec(markdownContent)) !== null) {
      const fullMatch = match[0];
      const tagType = match[1].toLowerCase();
      const attributes = match[2] || '';
      const isSelfClosing = match[3] === '/';
      
      // Add markdown content before this component
      if (match.index > lastEnd) {
        const markdownChunk = markdownContent.substring(lastEnd, match.index);
        if (markdownChunk.trim()) {
          contentFlow.push({ type: ContentType.markdown, markdownContent: markdownChunk });
        }
      }
      
      try {
        let options = null;
        let componentEndPos = match.index + fullMatch.length;
        
        // If not self-closing, look for closing tag and extract inner content
        if (!isSelfClosing) {
          // Find the matching closing tag
          const remainder = markdownContent.substring(componentEndPos);
          const closeRegex = new RegExp(`<\\/${tagType}>\\s*dc:::`);
          const closeMatch = closeRegex.exec(remainder);
          
          if (closeMatch) {
            const innerContent = remainder.substring(0, closeMatch.index);
            
            // Extract options with IDs if present
            const optionRegex = /<option(?:\s+id="([^"]*)")?>([^<]+)<\/option>/g;
            let optionMatch;
            const optionsList = [];
            
            while ((optionMatch = optionRegex.exec(innerContent)) !== null) {
              optionsList.push({
                id: optionMatch[1] || null,
                text: optionMatch[2]
              });
            }
            
            if (optionsList.length > 0) {
              options = optionsList;
            }
            
            // Update position to after the closing tag
            componentEndPos += closeMatch.index + closeMatch[0].length;
          }
        } else {
          // For self-closing components, check for dc::: suffix
          const suffixPattern = /\s*dc:::/;
          const suffixMatch = suffixPattern.exec(markdownContent.substring(componentEndPos));
          if (suffixMatch) {
            componentEndPos += suffixMatch[0].length;
          }
        }
        
        const component = this.createComponentFromTag(tagType, attributes, options);
        position = componentEndPos;
        
        components.push(component);
        contentFlow.push({ type: ContentType.component, component: component });
        lastEnd = position;
        
        // Update regex lastIndex to continue from the correct position
        componentPattern.lastIndex = position;
      } catch (e) {
        console.error('Error parsing component:', e);
        // Move past this component
        position = match.index + fullMatch.length;
        lastEnd = position;
      }
    }
    
    // Add remaining content
    if (lastEnd < markdownContent.length) {
      const remainingMarkdown = markdownContent.substring(lastEnd);
      if (remainingMarkdown.trim()) {
        contentFlow.push({ type: ContentType.markdown, markdownContent: remainingMarkdown });
      }
    }
    
    return {
      contentFlow: contentFlow,
      components: components
    };
  }
  
  // Create component from HTML-like tag
  createComponentFromTag(tagType, attributes, options) {
    // Parse attributes
    const attributeMap = {};
    const attrRegex = /([a-zA-Z0-9_-]+)(?:="([^"]*)")?/g;
    let attrMatch;
    
    while ((attrMatch = attrRegex.exec(attributes)) !== null) {
      const name = attrMatch[1];
      // Check for quoted values, unquoted values, or use default 'true' for boolean attributes
      const value = attrMatch[2] !== undefined ? attrMatch[2] : 'true';
      attributeMap[name] = value;
    }
    
    // Check for boolean attributes
    const required = attributeMap.hasOwnProperty('required');
    
    const id = attributeMap.id || `component_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    const label = attributeMap.label || 'Field';
    const placeholder = attributeMap.placeholder || null;
    const defaultValue = attributeMap.default || null;
    
    // Parse conditional logic if present
    let conditionalLogic = null;
    if (attributeMap.hasOwnProperty('depends-on')) {
      // Parse visibility condition (when-value)
      let visibilityValue = null;
      if (attributeMap.hasOwnProperty('when-value')) {
        visibilityValue = attributeMap['when-value'];
      }
      
      // Parse required-when-value attribute (this is the value that makes the field required)
      let requiredWhenValue = null;
      if (attributeMap.hasOwnProperty('required-when-value')) {
        requiredWhenValue = attributeMap['required-when-value'];
      }
      
      // Parse required-when-visible attribute (this is a boolean flag)
      let requiredWhenVisible = null;
      if (attributeMap.hasOwnProperty('required-when-visible')) {
        requiredWhenVisible = attributeMap['required-when-visible'].toLowerCase() === 'true';
      }
      
      // Create conditional logic
      conditionalLogic = new ConditionalLogic(
        attributeMap['depends-on'],
        attributeMap.condition || 'equals',
        visibilityValue, // Use visibility value for visibility checks
        attributeMap['disable-when-hidden'] !== 'false',
        requiredWhenVisible, // Parse the boolean value
        requiredWhenValue // The value that makes the field required
      );
    }
    
    let type;
    switch (tagType.toLowerCase()) {
      case 'radiobutton':
        type = DynamicComponentType.radioButton;
        break;
      case 'checkbox':
        type = DynamicComponentType.checkbox;
        break;
      case 'textarea':
        type = DynamicComponentType.textArea;
        break;
      case 'textfield':
        type = DynamicComponentType.textField;
        break;
      case 'dropdown':
        type = DynamicComponentType.dropdown;
        break;
      default:
        throw new Error(`Unsupported component type: ${tagType}`);
    }
    
    // Extract just the text values for backward compatibility
    const optionTexts = options ? options.map(o => o.text) : null;
    
    return {
      id: id,
      type: type,
      label: label,
      isRequired: required,
      options: optionTexts,
      optionData: options,
      placeholder: placeholder,
      defaultValue: defaultValue,
      maxLines: type === DynamicComponentType.textArea ? 4 : 1,
      minLines: type === DynamicComponentType.textArea ? 2 : 1,
      conditionalLogic: conditionalLogic
    };
  }
  
  // Initialize responses with default values
  initializeResponses() {
    for (const component of this.parsedContent.components) {
      this.responses[component.id] = this.getDefaultValue(component);
      this.componentErrors[component.id] = false;
    }
  }
  
  // Get default value for a component
  getDefaultValue(component) {
    switch (component.type) {
      case DynamicComponentType.radioButton:
        return null;
      case DynamicComponentType.checkbox:
        return [];
      case DynamicComponentType.textArea:
      case DynamicComponentType.textField:
        return '';
      case DynamicComponentType.dropdown:
        return null;
      default:
        return null;
    }
  }
  
  // Handle component change
  handleComponentChange(componentId, value) {
    this.responses[componentId] = value;
    this.componentErrors[componentId] = false;
    this.hasValidationErrors = false;
    this.firstInvalidComponentId = null;
    
    // Update UI
    this.updateErrorState(componentId, false);
    
    // Update conditional visibility for dependent components
    this.updateConditionalVisibility();
    
    // Also update required status for dependent components
    this.updateConditionalRequired();
  }
  
  // Check if a component is visible based on conditional logic
  isComponentVisible(component) {
    if (!component.conditionalLogic) return true;
    
    // Get the value of the component this depends on
    const dependentValue = this.responses[component.conditionalLogic.dependsOn];
    
    // Check if the visibility condition is met
    return component.conditionalLogic.isVisibilityMet(dependentValue);
  }
  
  // Check if a component is required based on conditional logic
  isComponentRequired(component) {
    // If component has conditional logic
    if (component.conditionalLogic) {
      // First check if there's a requiredWhenValue condition
      if (component.conditionalLogic.requiredWhenValue !== null && 
          component.conditionalLogic.requiredWhenValue !== undefined) {
        // Get the value of the component this depends on
        const dependentValue = this.responses[component.conditionalLogic.dependsOn];
        
        // Check if the required condition is met
        if (dependentValue !== undefined && dependentValue !== null && 
            component.conditionalLogic.isRequiredMet(dependentValue)) {
          return true; // The field is required when the condition is met
        }
        
        // If the condition is not met, return false (not required)
        return false;
      }
      
      // If there's a requiredWhenVisible condition, check visibility first
      if (component.conditionalLogic.requiredWhenVisible !== null && 
          component.conditionalLogic.requiredWhenVisible !== undefined) {
        // Check if the component is visible
        const isVisible = this.isComponentVisible(component);
        if (isVisible) {
          return component.conditionalLogic.requiredWhenVisible;
        } else {
          return false; // Not required when not visible
        }
      }
    }
    
    // If no conditional required logic is defined, use the component's default required status
    // But only if the component is visible
    if (this.isComponentVisible(component)) {
      return component.isRequired;
    }
    
    return false; // Not required when not visible
  }

  // Update conditional visibility for all components
  updateConditionalVisibility() {
    // Get all component elements
    const componentElements = document.querySelectorAll('[data-component-id]');
    
    componentElements.forEach(element => {
      const componentId = element.dataset.componentId;
      const component = this.parsedContent.components.find(c => c.id === componentId);
      
      if (component && component.conditionalLogic) {
        const isVisible = this.isComponentVisible(component);
        element.style.display = isVisible ? 'block' : 'none';
      }
    });
  }
  
  // Update conditional required status for all components
  updateConditionalRequired() {
    // Get all component elements
    const componentElements = document.querySelectorAll('[data-component-id]');
    
    componentElements.forEach(element => {
      const componentId = element.dataset.componentId;
      const component = this.parsedContent.components.find(c => c.id === componentId);
      
      if (component) {
        // Update the required asterisk dynamically
        this.updateRequiredAsterisk(component);
      }
    });
  }
  
  // Update the required asterisk for a component
  updateRequiredAsterisk(component) {
    const element = document.getElementById(`component-${component.id}`);
    if (element) {
      const label = element.querySelector('.component-label');
      if (label) {
        const isRequired = this.isComponentRequired(component);
        const asterisk = label.querySelector('.required-asterisk');
        
        // Update label text to include or exclude asterisk
        const labelText = component.label;
        if (isRequired && !asterisk) {
          // Add asterisk if required and not present
          label.innerHTML = `${labelText} <span class="required-asterisk">*</span>`;
        } else if (!isRequired && asterisk) {
          // Remove asterisk if not required but present
          label.innerHTML = labelText;
        } else if (isRequired && asterisk) {
          // Already has asterisk and should keep it
          label.innerHTML = `${labelText} <span class="required-asterisk">*</span>`;
        } else {
          // Not required and no asterisk
          label.innerHTML = labelText;
        }
      }
    }
  }

  // Validate form
  validateForm() {
    let isValid = true;
    const newErrors = {};
    let firstInvalidId = null;
    
    for (const component of this.parsedContent.components) {
      // Only validate visible components
      if (this.isComponentVisible(component)) {
        const value = this.responses[component.id];
        const isRequired = this.isComponentRequired(component);
        // Temporarily set the component's required status for validation
        const tempComponent = { ...component, isRequired: isRequired };
        const isComponentValid = this.validateComponent(tempComponent, value);
        newErrors[component.id] = !isComponentValid;
        
        if (!isComponentValid && firstInvalidId === null) {
          firstInvalidId = component.id;
        }
        
        if (!isComponentValid) {
          isValid = false;
        }
      }
    }
    
    Object.assign(this.componentErrors, newErrors);
    this.hasValidationErrors = !isValid;
    this.firstInvalidComponentId = firstInvalidId;
    
    // Update UI with validation errors
    for (const [id, hasError] of Object.entries(newErrors)) {
      this.updateErrorState(id, hasError);
    }
    
    return isValid;
  }
  
  // Prepare value for API submission
  prepareValueForApi(component, value) {
    // For most components, we can send the value as-is
    // For checkboxes, we might want to join the list into a comma-separated string
    if (component.type === DynamicComponentType.checkbox && Array.isArray(value)) {
      return value.join(',');
    }
    
    return value;
  }
  
  // Handle form submission
  async handleSubmit() {
    if (this.isSubmitting) return;
    
    // Validate form
    if (!this.validateForm()) {
      // Scroll to first invalid component
      if (this.firstInvalidComponentId) {
        const element = document.getElementById(`component-${this.firstInvalidComponentId}`);
        if (element) {
          element.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }
      return;
    }
    
    this.isSubmitting = true;
    
    try {
      // Prepare response data
      const responseData = {
        popupId: this.config.id,
        responses: {},
        timestamp: new Date(),
        wasCompleted: true
      };
      
      // Add responses for visible components only
      for (const component of this.parsedContent.components) {
        // Include all components in the response, not just visible ones
        // This ensures we capture the state of all components
        const value = this.responses[component.id];
        const preparedValue = this.prepareValueForApi(component, value);
        responseData.responses[component.id] = preparedValue;
      }
      
      // Call onCompleted callback
      await this.onCompleted(responseData);
      
      // Close dialog
      this.closeDialog();
    } catch (error) {
      console.error('Error submitting form:', error);
      // Show error message
      this.showSubmissionError('An error occurred while submitting the form. Please try again.');
    } finally {
      this.isSubmitting = false;
    }
  }

  // Show submission error
  showSubmissionError(message) {
    const errorElement = document.getElementById('submission-error');
    if (errorElement) {
      errorElement.textContent = message;
      errorElement.style.display = 'block';
      
      // Hide error after 5 seconds
      setTimeout(() => {
        errorElement.style.display = 'none';
      }, 5000);
    }
  }
  
  // Close dialog
  closeDialog() {
    const dialog = document.getElementById('dynamic-popup-dialog');
    if (dialog) {
      dialog.remove();
      this.dialogClosed = true;
      this.onDismissed();
    }
  }
  
  // Update error state for a component
  updateErrorState(componentId, hasError) {
    const element = document.getElementById(`component-${componentId}`);
    if (element) {
      if (hasError) {
        element.classList.add('has-error');
      } else {
        element.classList.remove('has-error');
      }
    }
  }
  
  // Render the popup
  render() {
    // Create dialog element
    const dialog = document.createElement('div');
    dialog.id = 'dynamic-popup-dialog';
    dialog.className = 'dynamic-popup-dialog';
    
    // Create overlay
    const overlay = document.createElement('div');
    overlay.className = 'dynamic-popup-overlay';
    if (!this.config.isBlocking) {
      overlay.addEventListener('click', () => this.handleDismiss());
    }
    
    // Create content container
    const contentContainer = document.createElement('div');
    contentContainer.className = 'dynamic-popup-content';
    
    // Create header
    const header = document.createElement('div');
    header.className = 'dynamic-popup-header';
    header.innerHTML = `
      <h2>${this.config.title}</h2>
      ${!this.config.isBlocking ? '<button class="close-button" id="close-popup">&times;</button>' : ''}
    `;
    
    // Create body
    const body = document.createElement('div');
    body.className = 'dynamic-popup-body';
    
    // Parse and render content
    this.renderContent(body);
    
    // Create footer
    const footer = document.createElement('div');
    footer.className = 'dynamic-popup-footer';
    
    // Add submission error element
    const errorElement = document.createElement('div');
    errorElement.id = 'submission-error';
    errorElement.className = 'submission-error';
    errorElement.style.display = 'none';
    footer.appendChild(errorElement);
    
    // Add action buttons
    const submitButton = document.createElement('button');
    submitButton.className = 'submit-button';
    submitButton.textContent = 'Submit';
    submitButton.addEventListener('click', () => this.handleSubmit());
    
    footer.appendChild(submitButton);
    
    if (!this.config.isBlocking) {
      const cancelButton = document.createElement('button');
      cancelButton.className = 'cancel-button';
      cancelButton.textContent = 'Cancel';
      cancelButton.addEventListener('click', () => this.handleDismiss());
      footer.appendChild(cancelButton);
    }
    
    // Assemble the dialog
    contentContainer.appendChild(header);
    contentContainer.appendChild(body);
    contentContainer.appendChild(footer);
    dialog.appendChild(overlay);
    dialog.appendChild(contentContainer);
    
    // Add to document
    document.body.appendChild(dialog);
    
    // Add event listeners
    const closeBtn = document.getElementById('close-popup');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => this.handleDismiss());
    }
    
    // Add styles
    this.addStyles();
  }
  
  // Handle dismiss
  handleDismiss() {
    if (this.config.isBlocking) return;
    
    this.closeDialog();
  }
  
  // Render content
  renderContent(container) {
    for (const element of this.parsedContent.contentFlow) {
      if (element.type === ContentType.markdown) {
        this.renderMarkdown(container, element.markdownContent);
      } else if (element.type === ContentType.component) {
        this.renderComponent(container, element.component);
      }
    }
  }
  
  // Render markdown content
  renderMarkdown(container, markdownContent) {
    const div = document.createElement('div');
    div.className = 'markdown-content';
    div.innerHTML = this.markdownToHtml(markdownContent);
    container.appendChild(div);
  }
  
  // Convert markdown to HTML
  markdownToHtml(markdown) {
    let html = markdown.trim();
    
    if (!html) return '';
    
    // Headers
    html = html.replace(/^### (.*$)/gm, '<h3>$1</h3>');
    html = html.replace(/^## (.*$)/gm, '<h2>$1</h2>');
    html = html.replace(/^# (.*$)/gm, '<h1>$1</h1>');
    
    // Bold
    html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    // Italic
    html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
    
    // Links
    html = html.replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2">$1</a>');
    
    // Line breaks
    html = html.replace(/\n\n/g, '</p><p>');
    html = html.replace(/\n/g, '<br>');
    
    // Wrap in paragraphs
    if (!html.startsWith('<h') && !html.startsWith('<p>')) {
      html = '<p>' + html + '</p>';
    }
    
    return html;
  }
  
  // Render a component
  renderComponent(container, component) {
    const componentDiv = document.createElement('div');
    componentDiv.id = `component-${component.id}`;
    componentDiv.className = 'dynamic-component';
    componentDiv.dataset.componentId = component.id;
    
    // Check if component should be visible
    const isVisible = this.isComponentVisible(component);
    if (!isVisible) {
      componentDiv.style.display = 'none';
    }
    
    // Render based on component type
    switch (component.type) {
      case DynamicComponentType.textField:
        this.renderTextField(componentDiv, component);
        break;
      case DynamicComponentType.textArea:
        this.renderTextArea(componentDiv, component);
        break;
      case DynamicComponentType.radioButton:
        this.renderRadioButton(componentDiv, component);
        break;
      case DynamicComponentType.checkbox:
        this.renderCheckbox(componentDiv, component);
        break;
      case DynamicComponentType.dropdown:
        this.renderDropdown(componentDiv, component);
        break;
    }
    
    container.appendChild(componentDiv);
  }
  
  // Render text field
  renderTextField(container, component) {
    const isRequired = this.isComponentRequired(component);
    const label = document.createElement('label');
    label.className = 'component-label';
    label.innerHTML = `${component.label}${isRequired ? ' <span class="required-asterisk">*</span>' : ''}`;
    
    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'component-input';
    input.placeholder = component.placeholder || '';
    input.value = this.responses[component.id] || '';
    input.addEventListener('input', (e) => {
      this.handleComponentChange(component.id, e.target.value);
    });
    
    container.appendChild(label);
    container.appendChild(input);
  }
  
  // Render text area
  renderTextArea(container, component) {
    const isRequired = this.isComponentRequired(component);
    const label = document.createElement('label');
    label.className = 'component-label';
    label.innerHTML = `${component.label}${isRequired ? ' <span class="required-asterisk">*</span>' : ''}`;
    
    const textarea = document.createElement('textarea');
    textarea.className = 'component-textarea';
    textarea.placeholder = component.placeholder || '';
    textarea.value = this.responses[component.id] || '';
    textarea.rows = component.minLines || 2;
    textarea.addEventListener('input', (e) => {
      this.handleComponentChange(component.id, e.target.value);
    });
    
    container.appendChild(label);
    container.appendChild(textarea);
  }
  
  // Render radio button
  renderRadioButton(container, component) {
    const isRequired = this.isComponentRequired(component);
    const label = document.createElement('label');
    label.className = 'component-label';
    label.innerHTML = `${component.label}${isRequired ? ' <span class="required-asterisk">*</span>' : ''}`;
    
    container.appendChild(label);
    
    const optionsContainer = document.createElement('div');
    optionsContainer.className = 'radio-options';
    
    const options = component.optionData || (component.options ? component.options.map(text => ({ id: null, text })) : []);
    
    options.forEach((option, index) => {
      const optionId = option.id || `option-${component.id}-${index}`;
      const optionValue = option.id || option.text;
      
      const optionDiv = document.createElement('div');
      optionDiv.className = 'radio-option';
      
      const input = document.createElement('input');
      input.type = 'radio';
      input.id = `radio-${component.id}-${optionId}`;
      input.name = `radio-${component.id}`;
      input.value = optionValue;
      input.className = 'radio-input';
      
      if (this.responses[component.id] === optionValue) {
        input.checked = true;
      }
      
      input.addEventListener('change', (e) => {
        if (e.target.checked) {
          this.handleComponentChange(component.id, e.target.value);
        }
      });
      
      const optionLabel = document.createElement('label');
      optionLabel.htmlFor = `radio-${component.id}-${optionId}`;
      optionLabel.className = 'radio-label';
      optionLabel.textContent = option.text;
      
      optionDiv.appendChild(input);
      optionDiv.appendChild(optionLabel);
      optionsContainer.appendChild(optionDiv);
    });
    
    container.appendChild(optionsContainer);
  }
  
  // Render checkbox
  renderCheckbox(container, component) {
    const isRequired = this.isComponentRequired(component);
    const label = document.createElement('label');
    label.className = 'component-label';
    label.innerHTML = `${component.label}${isRequired ? ' <span class="required-asterisk">*</span>' : ''}`;
    
    container.appendChild(label);
    
    const optionsContainer = document.createElement('div');
    optionsContainer.className = 'checkbox-options';
    
    const options = component.optionData || (component.options ? component.options.map(text => ({ id: null, text })) : []);
    const currentValues = this.responses[component.id] || [];
    
    options.forEach((option, index) => {
      const optionId = option.id || `option-${component.id}-${index}`;
      const optionValue = option.id || option.text;
      
      const optionDiv = document.createElement('div');
      optionDiv.className = 'checkbox-option';
      
      const input = document.createElement('input');
      input.type = 'checkbox';
      input.id = `checkbox-${component.id}-${optionId}`;
      input.value = optionValue;
      input.className = 'checkbox-input';
      
      if (currentValues.includes(optionValue)) {
        input.checked = true;
      }
      
      input.addEventListener('change', (e) => {
        let newValues = [...currentValues];
        if (e.target.checked) {
          newValues.push(e.target.value);
        } else {
          newValues = newValues.filter(v => v !== e.target.value);
        }
        this.handleComponentChange(component.id, newValues);
      });
      
      const optionLabel = document.createElement('label');
      optionLabel.htmlFor = `checkbox-${component.id}-${optionId}`;
      optionLabel.className = 'checkbox-label';
      optionLabel.textContent = option.text;
      
      optionDiv.appendChild(input);
      optionDiv.appendChild(optionLabel);
      optionsContainer.appendChild(optionDiv);
    });
    
    container.appendChild(optionsContainer);
  }
  
  // Render dropdown
  renderDropdown(container, component) {
    const isRequired = this.isComponentRequired(component);
    const label = document.createElement('label');
    label.className = 'component-label';
    label.innerHTML = `${component.label}${isRequired ? ' <span class="required-asterisk">*</span>' : ''}`;
    
    const select = document.createElement('select');
    select.className = 'component-select';
    
    // Add default empty option if not required
    if (!isRequired) {
      const defaultOption = document.createElement('option');
      defaultOption.value = '';
      defaultOption.textContent = 'Select an option';
      select.appendChild(defaultOption);
    }
    
    const options = component.optionData || (component.options ? component.options.map(text => ({ id: null, text })) : []);
    
    options.forEach((option, index) => {
      const optionValue = option.id || option.text;
      
      const optionElement = document.createElement('option');
      optionElement.value = optionValue;
      optionElement.textContent = option.text;
      
      if (this.responses[component.id] === optionValue) {
        optionElement.selected = true;
      }
      
      select.appendChild(optionElement);
    });
    
    select.addEventListener('change', (e) => {
      this.handleComponentChange(component.id, e.target.value);
    });
    
    container.appendChild(label);
    container.appendChild(select);
  }
  
  // Validate a component
  validateComponent(component, value) {
    // If not required, it's always valid
    if (!component.isRequired) return true;

    // Check based on component type
    switch (component.type) {
      case DynamicComponentType.radioButton:
        return value !== null && value.toString().trim() !== '';
      case DynamicComponentType.checkbox:
        // For checkbox, value should be a list
        return Array.isArray(value) && value.length > 0;
      case DynamicComponentType.textArea:
      case DynamicComponentType.textField:
        return value !== null && value.toString().trim() !== '';
      case DynamicComponentType.dropdown:
        return value !== null && value.toString().trim() !== '';
      default:
        return true;
    }
  }

  // Add CSS styles
  addStyles() {
    // Check if styles already exist
    if (document.getElementById('dynamic-popup-styles')) return;
    
    const style = document.createElement('style');
    style.id = 'dynamic-popup-styles';
    style.textContent = `
      .dynamic-popup-dialog {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1000;
        display: flex;
        justify-content: center;
        align-items: center;
      }
      
      .dynamic-popup-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 1001;
      }
      
      .dynamic-popup-content {
        position: relative;
        background-color: white;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        max-width: 600px;
        width: 90%;
        max-height: 90vh;
        overflow-y: auto;
        z-index: 1002;
        animation: popupFadeIn 0.3s ease-out;
      }
      
      @keyframes popupFadeIn {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
      }
      
      .dynamic-popup-header {
        padding: 20px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .dynamic-popup-header h2 {
        margin: 0;
        color: #333;
        font-size: 1.5rem;
      }
      
      .close-button {
        background: none;
        border: none;
        font-size: 2rem;
        cursor: pointer;
        color: #999;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: background-color 0.2s;
      }
      
      .close-button:hover {
        background-color: #f0f0f0;
        color: #666;
      }
      
      .dynamic-popup-body {
        padding: 20px;
      }
      
      .dynamic-component {
        margin-bottom: 20px;
        padding: 15px;
        border: 1px solid #eee;
        border-radius: 4px;
        background-color: #fafafa;
      }
      
      .dynamic-component.has-error {
        border-color: #f44336;
        background-color: #ffebee;
      }
      
      .component-label {
        display: block;
        margin-bottom: 8px;
        font-weight: bold;
        color: #333;
      }
      
      .required-asterisk {
        color: #f44336;
      }
      
      .component-input, .component-textarea, .component-select {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 1rem;
        box-sizing: border-box;
      }
      
      .component-input:focus, .component-textarea:focus, .component-select:focus {
        outline: none;
        border-color: #1976d2;
        box-shadow: 0 0 0 2px rgba(25, 118, 210, 0.2);
      }
      
      .component-textarea {
        min-height: 80px;
        resize: vertical;
      }
      
      .radio-options, .checkbox-options {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
      
      .radio-option, .checkbox-option {
        display: flex;
        align-items: center;
        gap: 8px;
      }
      
      .radio-input, .checkbox-input {
        margin: 0;
      }
      
      .radio-label, .checkbox-label {
        margin: 0;
        color: #555;
        cursor: pointer;
      }
      
      .dynamic-popup-footer {
        padding: 20px;
        border-top: 1px solid #eee;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        background-color: #f9f9f9;
      }
      
      .submit-button, .cancel-button {
        padding: 12px 24px;
        border: none;
        border-radius: 4px;
        font-size: 1rem;
        cursor: pointer;
        transition: background-color 0.2s;
      }
      
      .submit-button {
        background-color: #1976d2;
        color: white;
      }
      
      .submit-button:hover {
        background-color: #1565c0;
      }
      
      .cancel-button {
        background-color: #757575;
        color: white;
      }
      
      .cancel-button:hover {
        background-color: #616161;
      }
      
      .submission-error {
        color: #f44336;
        background-color: #ffebee;
        padding: 10px;
        border-radius: 4px;
        margin-bottom: 15px;
        border: 1px solid #ffcdd2;
      }
    `;
    
    document.head.appendChild(style);
  }
}
