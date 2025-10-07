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
    const attrRegex = /(\w+)="([^"]*)"/g;
    let attrMatch;
    
    while ((attrMatch = attrRegex.exec(attributes)) !== null) {
      attributeMap[attrMatch[1]] = attrMatch[2];
    }
    
    // Check for boolean attributes
    const required = attributes.includes('required');
    
    const id = attributeMap.id || `component_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    const label = attributeMap.label || 'Field';
    const placeholder = attributeMap.placeholder || null;
    const defaultValue = attributeMap.default || null;
    
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
      minLines: type === DynamicComponentType.textArea ? 2 : 1
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
  }
  
  // Validate form
  validateForm() {
    let isValid = true;
    const newErrors = {};
    let firstInvalidId = null;
    
    for (const component of this.parsedContent.components) {
      const value = this.responses[component.id];
      const isComponentValid = this.validateComponent(component, value);
      newErrors[component.id] = !isComponentValid;
      
      if (!isComponentValid && firstInvalidId === null) {
        firstInvalidId = component.id;
      }
      
      if (!isComponentValid) {
        isValid = false;
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
    if (this.isSubmitting || this.dialogClosed) return;
    
    if (!this.validateForm()) {
      this.showValidationError();
      // Scroll to the first invalid component
      setTimeout(() => {
        this.scrollToFirstInvalidComponent();
      }, 100);
      return;
    }
    
    this.isSubmitting = true;
    this.hasValidationErrors = false;
    this.firstInvalidComponentId = null;
    
    // Update UI to show submitting state
    this.updateSubmitButtonState(true);
    
    try {
      // Prepare data for API
      const apiResponses = {};
      for (const component of this.parsedContent.components) {
        const value = this.responses[component.id];
        apiResponses[component.id] = this.prepareValueForApi(component, value);
      }
      
      const response = {
        popupId: this.config.id,
        responses: apiResponses,
        timestamp: new Date(),
        wasCompleted: true
      };
      
      // Call the onCompleted callback
      await this.onCompleted(response);
      
      // Close the dialog
      if (!this.dialogClosed) {
        this.dialogClosed = true;
        this.closeDialog();
      }
    } catch (e) {
      this.showSubmissionError();
      this.isSubmitting = false;
      this.updateSubmitButtonState(false);
    }
  }
  
  // Handle dialog dismissal
  handleDismiss() {
    if (!this.config.isBlocking && !this.dialogClosed) {
      this.dialogClosed = true;
      this.onDismissed();
      this.closeDialog();
    }
  }
  
  // Show validation error
  showValidationError() {
    this.showMessage('Please fill in all required fields to continue', 'error');
  }
  
  // Show submission error
  showSubmissionError() {
    this.showMessage('An error occurred while submitting. Please try again.', 'error');
  }
  
  // Show message (generic)
  showMessage(message, type = 'info') {
    // Create or update message element
    let messageEl = document.getElementById('dynamic-popup-message');
    if (!messageEl) {
      messageEl = document.createElement('div');
      messageEl.id = 'dynamic-popup-message';
      messageEl.className = 'popup-message';
      document.body.appendChild(messageEl);
    }
    
    messageEl.textContent = message;
    messageEl.className = `popup-message ${type}`;
    
    // Show message
    messageEl.style.display = 'block';
    
    // Hide after 3 seconds
    setTimeout(() => {
      messageEl.style.display = 'none';
    }, 3000);
  }
  
  // Scroll to first invalid component
  scrollToFirstInvalidComponent() {
    if (this.firstInvalidComponentId) {
      const element = document.getElementById(`component-${this.firstInvalidComponentId}`);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth', block: 'center' });
        // Add temporary highlight
        element.classList.add('highlight-error');
        setTimeout(() => {
          element.classList.remove('highlight-error');
        }, 2000);
      }
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
  
  // Update submit button state
  updateSubmitButtonState(isSubmitting) {
    const submitBtn = document.getElementById('popup-submit-btn');
    if (submitBtn) {
      if (isSubmitting) {
        submitBtn.innerHTML = '<span class="spinner"></span>';
        submitBtn.disabled = true;
      } else {
        submitBtn.textContent = this.config.isBlocking ? 'Submit' : 'Continue';
        submitBtn.disabled = false;
      }
    }
  }
  
  // Close the dialog
  closeDialog() {
    const dialog = document.getElementById('dynamic-popup-dialog');
    if (dialog) {
      dialog.style.opacity = '0';
      dialog.style.transform = 'scale(0.9)';
      setTimeout(() => {
        dialog.remove();
      }, 300);
    }
  }
  
  // Convert basic markdown to HTML
  markdownToHtml(markdown) {
    let html = markdown.trim();
    
    // If empty, return empty
    if (!html) return '';
    
    // Headers - more precise matching
    html = html.replace(/^\s*### (.+)$/gm, '<h3>$1</h3>');
    html = html.replace(/^\s*## (.+)$/gm, '<h2>$1</h2>');
    html = html.replace(/^\s*# (.+)$/gm, '<h1>$1</h1>');
    
    // Bold
    html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    
    // Italic
    html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');
    
    // Links
    html = html.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2">$1</a>');
    
    // Line breaks - improved
    html = html.replace(/\n\n/g, '</p><p>');
    html = html.replace(/\n/g, '<br>');
    
    // Wrap in paragraphs only if not already a header
    if (!html.startsWith('<h') && !html.startsWith('<p>')) {
      html = `<p>${html}</p>`;
    }
    
    return html;
  }
  
  // Create component element
  createComponentElement(component) {
    const container = document.createElement('div');
    container.id = `component-${component.id}`;
    container.className = 'popup-component';
    
    const label = document.createElement('label');
    label.className = 'component-label';
    label.textContent = component.label;
    
    if (component.isRequired) {
      const requiredMark = document.createElement('span');
      requiredMark.className = 'required-mark';
      requiredMark.textContent = ' *';
      label.appendChild(requiredMark);
    }
    
    container.appendChild(label);
    
    let inputElement;
    
    switch (component.type) {
      case DynamicComponentType.textField:
        inputElement = this.createTextField(component);
        break;
      case DynamicComponentType.textArea:
        inputElement = this.createTextArea(component);
        break;
      case DynamicComponentType.radioButton:
        inputElement = this.createRadioButton(component);
        break;
      case DynamicComponentType.checkbox:
        inputElement = this.createCheckbox(component);
        break;
      case DynamicComponentType.dropdown:
        inputElement = this.createDropdown(component);
        break;
      default:
        inputElement = document.createElement('div');
        inputElement.textContent = 'Unsupported component type';
    }
    
    container.appendChild(inputElement);
    
    return container;
  }
  
  // Create text field
  createTextField(component) {
    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'text-input';
    input.placeholder = component.placeholder || '';
    input.value = this.responses[component.id] || '';
    
    if (component.maxLength) {
      input.maxLength = component.maxLength;
    }
    
    input.addEventListener('input', (e) => {
      this.handleComponentChange(component.id, e.target.value);
    });
    
    return input;
  }
  
  // Create text area
  createTextArea(component) {
    const textarea = document.createElement('textarea');
    textarea.className = 'text-area';
    textarea.placeholder = component.placeholder || '';
    textarea.value = this.responses[component.id] || '';
    
    if (component.minLines) {
      textarea.rows = component.minLines;
    }
    
    if (component.maxLines) {
      textarea.setAttribute('data-max-lines', component.maxLines);
    }
    
    textarea.addEventListener('input', (e) => {
      this.handleComponentChange(component.id, e.target.value);
    });
    
    return textarea;
  }
  
  // Create radio button
  createRadioButton(component) {
    const container = document.createElement('div');
    container.className = 'radio-container';
    
    const options = component.optionData || component.options?.map(text => ({ id: null, text })) || [];
    
    options.forEach((option, index) => {
      const optionId = option.id || `option-${component.id}-${index}`;
      
      const optionContainer = document.createElement('div');
      optionContainer.className = 'radio-option';
      
      const input = document.createElement('input');
      input.type = 'radio';
      input.id = `radio-${component.id}-${optionId}`;
      input.name = `radio-${component.id}`;
      input.value = optionId;
      
      if (this.responses[component.id] === optionId) {
        input.checked = true;
      }
      
      input.addEventListener('change', (e) => {
        if (e.target.checked) {
          this.handleComponentChange(component.id, optionId);
        }
      });
      
      const label = document.createElement('label');
      label.htmlFor = `radio-${component.id}-${optionId}`;
      label.textContent = option.text;
      
      optionContainer.appendChild(input);
      optionContainer.appendChild(label);
      container.appendChild(optionContainer);
    });
    
    return container;
  }
  
  // Create checkbox
  createCheckbox(component) {
    const container = document.createElement('div');
    container.className = 'checkbox-container';
    
    const options = component.optionData || component.options?.map(text => ({ id: null, text })) || [];
    
    options.forEach((option, index) => {
      const optionId = option.id || `option-${component.id}-${index}`;
      
      const optionContainer = document.createElement('div');
      optionContainer.className = 'checkbox-option';
      
      const input = document.createElement('input');
      input.type = 'checkbox';
      input.id = `checkbox-${component.id}-${optionId}`;
      input.value = optionId;
      
      if (this.responses[component.id].includes(optionId)) {
        input.checked = true;
      }
      
      input.addEventListener('change', (e) => {
        const currentValues = [...this.responses[component.id]];
        const valueIndex = currentValues.indexOf(optionId);
        
        if (e.target.checked) {
          if (valueIndex === -1) {
            currentValues.push(optionId);
          }
        } else {
          if (valueIndex !== -1) {
            currentValues.splice(valueIndex, 1);
          }
        }
        
        this.handleComponentChange(component.id, currentValues);
      });
      
      const label = document.createElement('label');
      label.htmlFor = `checkbox-${component.id}-${optionId}`;
      label.textContent = option.text;
      
      optionContainer.appendChild(input);
      optionContainer.appendChild(label);
      container.appendChild(optionContainer);
    });
    
    return container;
  }
  
  // Create dropdown
  createDropdown(component) {
    const select = document.createElement('select');
    select.className = 'dropdown';
    
    // Add default empty option
    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.textContent = 'Select an option';
    select.appendChild(defaultOption);
    
    const options = component.optionData || component.options?.map(text => ({ id: null, text })) || [];
    
    options.forEach((option, index) => {
      const optionId = option.id || `option-${component.id}-${index}`;
      
      const optionElement = document.createElement('option');
      optionElement.value = optionId;
      optionElement.textContent = option.text;
      
      if (this.responses[component.id] === optionId) {
        optionElement.selected = true;
      }
      
      select.appendChild(optionElement);
    });
    
    select.addEventListener('change', (e) => {
      this.handleComponentChange(component.id, e.target.value);
    });
    
    return select;
  }
  
  // Render the popup dialog
  render() {
    // Create dialog container
    const dialog = document.createElement('div');
    dialog.id = 'dynamic-popup-dialog';
    dialog.className = 'popup-dialog';
    
    // Create dialog content
    const dialogContent = document.createElement('div');
    dialogContent.className = 'popup-content';
    
    // Create header
    const header = document.createElement('div');
    header.className = 'popup-header';
    if (this.hasValidationErrors) {
      header.classList.add('has-validation-errors');
    }
    
    const title = document.createElement('h2');
    title.className = 'popup-title';
    title.textContent = this.config.title;
    
    const closeBtn = document.createElement('button');
    closeBtn.className = 'popup-close-btn';
    closeBtn.innerHTML = '&times;';
    closeBtn.addEventListener('click', () => this.handleDismiss());
    
    header.appendChild(title);
    header.appendChild(closeBtn);
    
    // Create content container
    const contentContainer = document.createElement('div');
    contentContainer.className = 'popup-content-container';
    
    // Process content flow
    this.parsedContent.contentFlow.forEach((element) => {
      if (element.type === ContentType.markdown) {
        const markdownDiv = document.createElement('div');
        markdownDiv.className = 'markdown-content';
        markdownDiv.innerHTML = this.markdownToHtml(element.markdownContent);
        contentContainer.appendChild(markdownDiv);
      } else if (element.type === ContentType.component) {
        const componentElement = this.createComponentElement(element.component);
        contentContainer.appendChild(componentElement);
      }
    });
    
    // Create actions container
    const actionsContainer = document.createElement('div');
    actionsContainer.className = 'popup-actions';
    
    // Add cancel button if not blocking
    if (!this.config.isBlocking) {
      const cancelBtn = document.createElement('button');
      cancelBtn.className = 'popup-cancel-btn';
      cancelBtn.textContent = 'Cancel';
      cancelBtn.addEventListener('click', () => this.handleDismiss());
      actionsContainer.appendChild(cancelBtn);
    }
    
    // Add submit button
    const submitBtn = document.createElement('button');
    submitBtn.id = 'popup-submit-btn';
    submitBtn.className = 'popup-submit-btn';
    submitBtn.textContent = this.config.isBlocking ? 'Submit' : 'Continue';
    submitBtn.addEventListener('click', () => this.handleSubmit());
    actionsContainer.appendChild(submitBtn);
    
    // Assemble dialog
    dialogContent.appendChild(header);
    dialogContent.appendChild(contentContainer);
    dialogContent.appendChild(actionsContainer);
    dialog.appendChild(dialogContent);
    
    // Add to document
    document.body.appendChild(dialog);
    
    // Add CSS styles
    this.addStyles();
    
    // Show dialog with animation
    setTimeout(() => {
      dialog.style.opacity = '1';
      dialog.style.transform = 'scale(1)';
    }, 10);
  }
  
  // Add CSS styles
  addStyles() {
    // Check if styles already exist
    if (document.getElementById('dynamic-popup-styles')) {
      return;
    }
    
    const style = document.createElement('style');
    style.id = 'dynamic-popup-styles';
    style.textContent = `
      .popup-dialog {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 10000;
        opacity: 0;
        transform: scale(0.9);
        transition: opacity 0.3s ease, transform 0.3s ease;
      }
      
      .popup-content {
        background-color: white;
        border-radius: 16px;
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        max-width: 500px;
        width: 90%;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
      }
      
      .popup-header {
        padding: 16px;
        background-color: #1976d2;
        color: white;
        border-radius: 16px 16px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .popup-header.has-validation-errors {
        border-top: 3px solid #d32f2f;
        border-left: 3px solid #d32f2f;
        border-right: 3px solid #d32f2f;
      }
      
      .popup-title {
        margin: 0;
        font-size: 20px;
        font-weight: bold;
      }
      
      .popup-close-btn {
        background: none;
        border: none;
        color: white;
        font-size: 24px;
        cursor: pointer;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .popup-content-container {
        padding: 16px;
        overflow-y: auto;
        flex: 1;
      }
      
      .markdown-content {
        margin-bottom: 16px;
      }
      
      .markdown-content h1 {
        font-size: 24px;
        font-weight: bold;
        margin: 16px 0 8px 0;
      }
      
      .markdown-content h2 {
        font-size: 20px;
        font-weight: bold;
        margin: 14px 0 7px 0;
      }
      
      .markdown-content h3 {
        font-size: 18px;
        font-weight: bold;
        margin: 12px 0 6px 0;
      }
      
      .markdown-content p {
        margin: 0 0 12px 0;
      }
      
      .popup-component {
        margin-bottom: 16px;
      }
      
      .component-label {
        display: block;
        margin-bottom: 8px;
        font-weight: bold;
        color: #333;
      }
      
      .required-mark {
        color: red;
      }
      
      .text-input, .text-area, .dropdown {
        width: 100%;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 4px;
        font-family: inherit;
        font-size: 14px;
        box-sizing: border-box;
      }
      
      .text-input:focus, .text-area:focus, .dropdown:focus {
        outline: none;
        border-color: #1976d2;
        box-shadow: 0 0 0 2px rgba(25, 118, 210, 0.2);
      }
      
      .text-area {
        min-height: 80px;
        resize: vertical;
      }
      
      .radio-container, .checkbox-container {
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 10px;
      }
      
      .radio-option, .checkbox-option {
        margin-bottom: 8px;
        display: flex;
        align-items: center;
      }
      
      .radio-option:last-child, .checkbox-option:last-child {
        margin-bottom: 0;
      }
      
      .radio-option input, .checkbox-option input {
        margin-right: 8px;
      }
      
      .popup-actions {
        padding: 16px;
        background-color: #f9f9f9;
        border-radius: 0 0 16px 16px;
        border-top: 1px solid #ddd;
        display: flex;
        justify-content: flex-end;
        gap: 8px;
      }
      
      .popup-cancel-btn, .popup-submit-btn {
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
      }
      
      .popup-cancel-btn {
        background-color: #f5f5f5;
        color: #333;
      }
      
      .popup-cancel-btn:hover {
        background-color: #e0e0e0;
      }
      
      .popup-submit-btn {
        background-color: #1976d2;
        color: white;
      }
      
      .popup-submit-btn:hover:not(:disabled) {
        background-color: #1565c0;
      }
      
      .popup-submit-btn:disabled {
        background-color: #bbdefb;
        cursor: not-allowed;
      }
      
      .popup-component.has-error .component-label {
        color: #d32f2f;
      }
      
      .popup-component.has-error .text-input,
      .popup-component.has-error .text-area,
      .popup-component.has-error .dropdown,
      .popup-component.has-error .radio-container,
      .popup-component.has-error .checkbox-container {
        border-color: #d32f2f;
      }
      
      .popup-component.highlight-error {
        animation: highlightError 2s;
      }
      
      @keyframes highlightError {
        0% { background-color: #ffcdd2; }
        100% { background-color: transparent; }
      }
      
      .spinner {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-radius: 50%;
        border-top-color: white;
        animation: spin 1s ease-in-out infinite;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
      
      .popup-message {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        border-radius: 4px;
        color: white;
        font-weight: 500;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        z-index: 10001;
        display: none;
      }
      
      .popup-message.info {
        background-color: #1976d2;
      }
      
      .popup-message.error {
        background-color: #d32f2f;
      }
    `;
    
    document.head.appendChild(style);
  }
}