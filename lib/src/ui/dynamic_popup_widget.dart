import 'package:dynamic_popup/dynamic_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DynamicPopupWidget extends StatefulWidget {
  final PopupConfig config;
  final Function(PopupResponse response) onCompleted;
  final Function()? onDismissed;
  final bool canDismiss;
  final Widget? customTitle; // Custom title widget
  final Widget? customFooter; // Custom footer widget
  final List<Widget>? customActions; // Custom action buttons

  DynamicPopupWidget({
    Key? key,
    required this.config,
    required this.onCompleted,
    this.onDismissed,
    bool? canDismiss,
    this.customTitle,
    this.customFooter,
    this.customActions,
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
  bool _hasValidationErrors = false; // Track if there are validation errors
  bool _dialogClosed = false; // Track if dialog has been closed
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
      // Clear global validation error state when user interacts
      _hasValidationErrors = false;
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
      _hasValidationErrors = !isValid; // Set global validation error state
    });

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || _dialogClosed) return;

    if (!_validateForm()) {
      _showValidationError();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _hasValidationErrors = false; // Clear validation errors on submit
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
      
      // Only close the dialog once
      if (!_dialogClosed) {
        _dialogClosed = true;
        _animationController.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      _showSubmissionError();
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _handleDismiss() {
    if (!widget.canDismiss || _dialogClosed) return;
    
    // Only close the dialog once
    if (!_dialogClosed) {
      _dialogClosed = true;
      _animationController.reverse().then((_) {
        if (mounted) {
          // Call the onDismissed callback
          widget.onDismissed?.call();
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _showValidationError() {
    // Using Flutter's ScaffoldMessenger instead of Get.snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please fill in all required fields to continue'),
        backgroundColor: Colors.red.shade700, // Changed from orange to red
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSubmissionError() {
    // Using Flutter's ScaffoldMessenger instead of Get.snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('An error occurred while submitting. Please try again.'),
        backgroundColor: Colors.red.shade700, // Changed from red.shade100 to red.shade700
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canDismiss,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && widget.canDismiss && !_dialogClosed) {
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
        // Add border to indicate validation errors
        border: Border.all(
          color: _hasValidationErrors ? Colors.red.shade700 : Colors.transparent,
          width: _hasValidationErrors ? 2.0 : 0.0,
        ),
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
          
          // Custom Footer
          if (widget.customFooter != null)
            widget.customFooter!,
          
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
        // Add red border to header when there are validation errors
        border: _hasValidationErrors 
          ? Border(
              top: BorderSide(color: Colors.red.shade700, width: 3.0),
              left: BorderSide(color: Colors.red.shade700, width: 3.0),
              right: BorderSide(color: Colors.red.shade700, width: 3.0),
            )
          : null,
      ),
      child: Row(
        children: [
          if (widget.customTitle != null)
            Expanded(child: widget.customTitle!)
          else
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
      child: SmartScrollView(
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
    // Combine custom actions with default actions
    List<Widget> actions = [];
    
    if (widget.customActions != null && widget.customActions!.isNotEmpty) {
      actions.addAll(widget.customActions!);
      actions.add(const SizedBox(width: 8));
    }
    
    if (widget.canDismiss && !widget.config.isBlocking) {
      actions.add(
        TextButton(
          onPressed: _isSubmitting || _dialogClosed ? null : _handleDismiss,
          child: const Text('Cancel'),
        ),
      );
      actions.add(const SizedBox(width: 8));
    }
    
    actions.add(
      ElevatedButton(
        onPressed: _isSubmitting || _dialogClosed ? null : _handleSubmit,
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
    );

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
        children: actions,
      ),
    );
  }
}

// Smart scroll view widget that provides modern scrolling behavior
class SmartScrollView extends StatefulWidget {
  final Widget child;
  
  const SmartScrollView({Key? key, required this.child}) : super(key: key);
  
  @override
  State<SmartScrollView> createState() => _SmartScrollViewState();
}

class _SmartScrollViewState extends State<SmartScrollView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _showScrollToBottom = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _updateScrollButtons() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    setState(() {
      _showScrollToTop = currentScroll > 50;
      _showScrollToBottom = currentScroll < maxScroll - 50;
    });
  }
  
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              _updateScrollButtons();
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: widget.child,
          ),
        ),
        // Scroll to top button
        if (_showScrollToTop)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                onPressed: _scrollToTop,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        // Scroll to bottom button
        if (_showScrollToBottom)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                onPressed: _scrollToBottom,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
      ],
    );
  }
}