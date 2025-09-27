import 'package:dynamic_popup/dynamic_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DynamicPopupWidget extends StatefulWidget {
  final PopupConfig config;
  final Function(PopupResponse response) onCompleted;
  final Function()? onDismissed;
  final bool canDismiss;

  DynamicPopupWidget({
    Key? key,
    required this.config,
    required this.onCompleted,
    this.onDismissed,
    bool? canDismiss,
  }) : canDismiss = canDismiss ?? !config.isBlocking, super(key: key);

  @override
  State<DynamicPopupWidget> createState() => _DynamicPopupWidgetState();
}

class _DynamicPopupWidgetState extends State<DynamicPopupWidget>
    with TickerProviderStateMixin {
  late ParsedMarkdownContent _parsedContent;
  final Map<String, dynamic> _responses = {};
  final Map<String, bool> _componentErrors = {};
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _parsedContent = MarkdownDynamicParser.parse(widget.config.markdownContent);
    _initializeResponses();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  void _initializeResponses() {
    for (final component in _parsedContent.components) {
      _responses[component.id] = DynamicComponentFactory.getDefaultValue(component);
      _componentErrors[component.id] = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleComponentChange(String componentId, dynamic value) {
    setState(() {
      _responses[componentId] = value;
      _componentErrors[componentId] = false; // Clear error when user interacts
    });
  }

  bool _validateForm() {
    bool isValid = true;
    final newErrors = <String, bool>{};

    for (final component in _parsedContent.components) {
      final value = _responses[component.id];
      final isComponentValid = DynamicComponentFactory.validateComponent(component, value);
      newErrors[component.id] = !isComponentValid;
      
      if (!isComponentValid) {
        isValid = false;
      }
    }

    setState(() {
      _componentErrors.addAll(newErrors);
    });

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (!_validateForm()) {
      _showValidationError();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare data for API
      final apiResponses = <String, dynamic>{};
      for (final component in _parsedContent.components) {
        final value = _responses[component.id];
        apiResponses[component.id] = DynamicComponentFactory.prepareValueForApi(component, value);
      }

      final response = PopupResponse(
        popupId: widget.config.id,
        responses: apiResponses,
        timestamp: DateTime.now(),
        wasCompleted: true,
      );

      widget.onCompleted(response);
      _animationController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      _showSubmissionError();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleDismiss() {
    if (!widget.canDismiss) return;
    
    _animationController.reverse().then((_) {
      if (mounted) {
        // Call the onDismissed callback, but don't pop the navigator here
        // The service will handle the dialog dismissal
        widget.onDismissed?.call();
      }
    });
  }

  void _showValidationError() {
    // Using Flutter's ScaffoldMessenger instead of Get.snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please fill in all required fields to continue'),
        backgroundColor: Colors.orange.shade100,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSubmissionError() {
    // Using Flutter's ScaffoldMessenger instead of Get.snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('An error occurred while submitting. Please try again.'),
        backgroundColor: Colors.red.shade100,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canDismiss,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && widget.canDismiss) {
          _handleDismiss();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(16),
                child: _buildDialogContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          
          // Content
          _buildContent(),
          
          // Actions
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.config.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (widget.canDismiss)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _handleDismiss,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Process content flow
            ..._parsedContent.contentFlow.map((element) {
              switch (element.type) {
                case ContentType.markdown:
                  return _buildMarkdownContent(element.markdownContent ?? '');
                case ContentType.component:
                  return _buildComponent(element.component!);
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(String markdown) {
    final html = MarkdownDynamicParser.markdownToHtml(markdown);
    
    return Html(
      data: html,
      style: {
        'h1': Style(
          fontSize: FontSize.large,
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 16, bottom: 8),
        ),
        'h2': Style(
          fontSize: FontSize.medium,
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 14, bottom: 7),
        ),
        'h3': Style(
          fontSize: FontSize.small,
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 12, bottom: 6),
        ),
        'p': Style(
          margin: Margins.only(top: 0, bottom: 12),
        ),
        'strong': Style(
          fontWeight: FontWeight.bold,
        ),
        'em': Style(
          fontStyle: FontStyle.italic,
        ),
        'a': Style(
          color: Theme.of(context).primaryColor,
        ),
      },
    );
  }

  Widget _buildComponent(DynamicComponent component) {
    return DynamicComponentFactory.createComponent(
      component: component,
      onChanged: _handleComponentChange,
      initialValue: _responses[component.id],
      hasError: _componentErrors[component.id] ?? false,
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: BorderDirectional(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.canDismiss && !widget.config.isBlocking)
            TextButton(
              onPressed: _isSubmitting ? null : _handleDismiss,
              child: const Text('Cancel'),
            ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(widget.config.isBlocking ? 'Submit' : 'Continue'),
          ),
        ],
      ),
    );
  }
}