import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

// Enum for content types in the flow
enum ContentType {
  markdown,
  component,
}

// Content element in the flow
class ContentElement {
  final ContentType type;
  final String? markdownContent;
  final DynamicComponent? component;
  
  ContentElement.markdown(this.markdownContent) 
      : type = ContentType.markdown, component = null;
  
  ContentElement.component(this.component) 
      : type = ContentType.component, markdownContent = null;
}

// Model for parsed markdown content
class ParsedMarkdownContent {
  final List<ContentElement> contentFlow; // Ordered flow of content
  final List<DynamicComponent> components; // List of components for reference

  ParsedMarkdownContent({
    required this.contentFlow,
    required this.components,
  });
  
  // Backward compatibility
  String get htmlContent => contentFlow
      .where((e) => e.type == ContentType.markdown)
      .map((e) => e.markdownContent ?? '')
      .join('\n');
      
  List<int> get componentPositions => [];
}

// Parser for markdown with placeholders for dynamic components
class MarkdownDynamicParser {
  static const String _componentPlaceholderPattern = r'\[([A-Z]+)(?::([^:\]]+))*\]';
  
  /// Parse markdown content with extraction of dynamic components
  static ParsedMarkdownContent parse(String markdownContent) {
    final components = <DynamicComponent>[];
    final contentFlow = <ContentElement>[];
    
    // RegExp to find component placeholders
    final regex = RegExp(_componentPlaceholderPattern, caseSensitive: false);
    
    int lastEnd = 0;
    
    for (final match in regex.allMatches(markdownContent)) {
      final placeholder = match.group(0)!;
      
      // Add markdown content before this placeholder
      if (match.start > lastEnd) {
        final markdownChunk = markdownContent.substring(lastEnd, match.start);
        if (markdownChunk.trim().isNotEmpty) {
          contentFlow.add(ContentElement.markdown(markdownChunk));
        }
      }
      
      try {
        // Create dynamic component from placeholder
        final component = DynamicComponent.fromPlaceholder(placeholder);
        components.add(component);
        contentFlow.add(ContentElement.component(component));
      } catch (e) {
        // Log error but continue parsing
        print('Error parsing placeholder "$placeholder": $e');
        // Add placeholder as text if it can't be parsed
        contentFlow.add(ContentElement.markdown(placeholder));
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining markdown content
    if (lastEnd < markdownContent.length) {
      final remainingMarkdown = markdownContent.substring(lastEnd);
      if (remainingMarkdown.trim().isNotEmpty) {
        contentFlow.add(ContentElement.markdown(remainingMarkdown));
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
    final regex = RegExp(_componentPlaceholderPattern, caseSensitive: false);
    return regex.allMatches(markdownContent)
        .map((match) => match.group(0)!)
        .toList();
  }
  
  /// Validate if a placeholder has the correct format
  static bool isValidPlaceholder(String placeholder) {
    try {
      DynamicComponent.fromPlaceholder(placeholder);
      return true;
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
      <meta charset="utf-8">
      <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .component-preview { 
          border: 2px dashed #ccc; 
          padding: 10px; 
          margin: 10px 0; 
          background-color: #f9f9f9;
        }
        .required { color: red; }
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
    final requiredMarker = component.isRequired ? '<span class="required"> *</span>' : '';
    final optionsText = component.options != null ? 
        '<br><small>Options: ${component.options!.join(', ')}</small>' : '';
    final placeholderText = component.placeholder != null ? 
        '<br><small>Placeholder: ${component.placeholder}</small>' : '';
        
    return '''
    <div class="component-preview">
      <strong>${component.type.toString().split('.').last} Component</strong>
      <br>
      <strong>ID:</strong> ${component.id}
      <br>
      <strong>Label:</strong> ${component.label}$requiredMarker
      $optionsText
      $placeholderText
    </div>
    ''';
  }
}
