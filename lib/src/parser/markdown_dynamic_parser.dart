import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

// Parser for markdown with placeholders for dynamic components
class MarkdownDynamicParser {
  // Updated pattern to support new syntax with improved initiator
  // This pattern now supports multiline syntax with spaces and newlines
  static const String _componentPattern = r':::dc\s*<([a-zA-Z]+)([^>]*?)(\/?)>'; // Match opening tag with optional whitespace
  static const String _optionPattern = r'<option(?:\s+id="([^"]*)")?>([^<]+)<\/option>';
  
  /// Parse markdown content with extraction of dynamic components
  static ParsedMarkdownContent parse(String markdownContent) {
    final components = <DynamicComponent>[];
    final contentFlow = <ContentElement>[];
    
    // Process the content step by step
    int lastEnd = 0;
    int position = 0;
    
    while (position < markdownContent.length) {
      // Look for new syntax components with improved initiator
      final newMatch = RegExp(_componentPattern, multiLine: true).firstMatch(markdownContent.substring(position));
      
      if (newMatch != null) {
        final candidate = ComponentCandidate(
          position: position + newMatch.start,
          endPosition: position + newMatch.end,
          match: newMatch,
          isNewSyntax: true,
        );
        
        // Add markdown content before this component
        if (candidate.position > lastEnd) {
          final markdownChunk = markdownContent.substring(lastEnd, candidate.position);
          if (markdownChunk.trim().isNotEmpty) {
            contentFlow.add(ContentElement.markdown(markdownChunk));
          }
        }
        
        try {
          DynamicComponent component;
          
          // New syntax: :::dc<componentType attribute1="value1" attribute2="value2" /> or with content
          final fullMatch = candidate.match.group(0)!;
          final tagType = candidate.match.group(1)!.toLowerCase();
          final attributes = candidate.match.group(2) ?? '';
          final isSelfClosing = candidate.match.group(3) == '/';
          
          List<OptionData>? options;
          int componentEndPos = candidate.endPosition;
          
          // If not self-closing, look for closing tag and extract inner content
          if (!isSelfClosing) {
            // Find the matching closing tag with dc::: suffix (allowing for whitespace)
            final searchStart = candidate.endPosition;
            final remainder = markdownContent.substring(searchStart);
            final closeRegex = RegExp('<\\/$tagType>\\s*dc:::', multiLine: true);
            final closeMatch = closeRegex.firstMatch(remainder);
            
            if (closeMatch != null) {
              final innerContent = remainder.substring(0, closeMatch.start);
              // Extract options with IDs if present
              final optionRegex = RegExp(_optionPattern);
              final optionMatches = optionRegex.allMatches(innerContent);
              if (optionMatches.isNotEmpty) {
                options = optionMatches.map((m) {
                  final id = m.group(1); // Option ID
                  final text = m.group(2); // Option text
                  return OptionData(id: id, text: text!);
                }).toList();
              }
              
              // Update position to after the closing tag (including dc::: and whitespace)
              componentEndPos = searchStart + closeMatch.end;
            } else {
              // No closing tag found, treat as self-closing
              componentEndPos = candidate.endPosition;
            }
          } else {
            // For self-closing components, we need to account for the dc::: suffix with possible whitespace
            // Check if the component ends with dc::: allowing for whitespace
            final fullComponentPattern = RegExp('${RegExp.escape(fullMatch)}\\s*dc:::', multiLine: true);
            final fullMatchResult = fullComponentPattern.firstMatch(markdownContent.substring(position));
            if (fullMatchResult != null) {
              componentEndPos = position + fullMatchResult.end;
            }
          }
          
          component = DynamicComponent.fromHtmlTag(tagType, attributes, options);
          position = componentEndPos;
          
          components.add(component);
          contentFlow.add(ContentElement.component(component));
          lastEnd = position;
        } catch (e) {
          // Log error but continue parsing
          // Move past this component
          position = candidate.endPosition;
          lastEnd = position;
        }
      } else {
        // No more components, add remaining content and break
        if (lastEnd < markdownContent.length) {
          final remainingMarkdown = markdownContent.substring(lastEnd);
          if (remainingMarkdown.trim().isNotEmpty) {
            contentFlow.add(ContentElement.markdown(remainingMarkdown));
          }
        }
        break;
      }
    }
    
    return ParsedMarkdownContent(
      contentFlow: contentFlow,
      components: components,
    );
  }
  
  /// Convert basic markdown to HTML
  static String markdownToHtml(String markdown) {
    String html = markdown.trim();
    
    // If empty, return empty
    if (html.isEmpty) return '';
    
    // Headers - more precise matching
    html = html.replaceAllMapped(RegExp(r'^\s*### (.+)$', multiLine: true), 
        (match) => '<h3>${match.group(1)?.trim()}</h3>');
    html = html.replaceAllMapped(RegExp(r'^\s*## (.+)$', multiLine: true), 
        (match) => '<h2>${match.group(1)?.trim()}</h2>');
    html = html.replaceAllMapped(RegExp(r'^\s*# (.+)$', multiLine: true), 
        (match) => '<h1>${match.group(1)?.trim()}</h1>');
    
    // Bold
    html = html.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), 
        (match) => '<strong>${match.group(1)}</strong>');
    
    // Italic
    html = html.replaceAllMapped(RegExp(r'\*(.+?)\*'), 
        (match) => '<em>${match.group(1)}</em>');
    
    // Links
    html = html.replaceAllMapped(RegExp(r'\[(.+?)\]\((.+?)\)'), 
        (match) => '<a href="${match.group(2)}">${match.group(1)}</a>');
    
    // Line breaks - improved
    html = html.replaceAll('\n\n', '</p><p>');
    html = html.replaceAll('\n', '<br>');
    
    // Wrap in paragraphs only if not already a header
    if (!html.startsWith('<h') && !html.startsWith('<p>')) {
      html = '<p>$html</p>';
    }
    
    return html;
  }
  
  /// Extract all placeholders from markdown text
  static List<String> extractPlaceholders(String markdownContent) {
    final newRegex = RegExp(_componentPattern, caseSensitive: false, multiLine: true);
    return newRegex.allMatches(markdownContent).map((m) => m.group(0)!).toList();
  }
  
  /// Validate if a placeholder has the correct format
  static bool isValidPlaceholder(String placeholder) {
    try {
      // Try new syntax - now supporting multiline with whitespace
      final regex = RegExp(r':::dc\s*<.*?>\s*dc:::', dotAll: true);
      if (regex.hasMatch(placeholder)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Generate HTML preview for testing
  static String generatePreviewHtml(String markdownContent) {
    final parsed = parse(markdownContent);
    final htmlParts = <String>[];
    
    // Build HTML following the content flow
    for (final element in parsed.contentFlow) {
      switch (element.type) {
        case ContentType.markdown:
          if (element.markdownContent != null && element.markdownContent!.trim().isNotEmpty) {
            htmlParts.add(markdownToHtml(element.markdownContent!));
          }
          break;
          
        case ContentType.component:
          if (element.component != null) {
            htmlParts.add(_generateComponentPreviewHtml(element.component!));
          }
          break;
      }
    }
    
    final combinedHtml = htmlParts.join('\n');
    
    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .component { border: 1px solid #ccc; padding: 10px; margin: 10px 0; border-radius: 5px; }
    .component-label { font-weight: bold; color: #333; }
    .component-type { color: #666; font-size: 0.9em; }
    .component-required { color: red; }
  </style>
</head>
<body>
  $combinedHtml
</body>
</html>
''';
  }
  
  /// Generate HTML preview for a component
  static String _generateComponentPreviewHtml(DynamicComponent component) {
    final requiredMark = component.isRequired ? '<span class="component-required"> *</span>' : '';
    final optionsHtml = component.optionData != null 
        ? component.optionData!.map((o) => '<li>${o.text}${o.id != null ? ' (ID: ${o.id})' : ''}</li>').join('')
        : component.options != null 
            ? component.options!.map((o) => '<li>$o</li>').join('')
            : '';
    
    return '''
<div class="component">
  <div class="component-label">${component.label}$requiredMark</div>
  <div class="component-type">${component.type.name} (ID: ${component.id})</div>
  ${optionsHtml.isNotEmpty ? '<ul>$optionsHtml</ul>' : ''}
  ${component.placeholder != null ? '<div>Placeholder: ${component.placeholder}</div>' : ''}
</div>
''';
  }
}