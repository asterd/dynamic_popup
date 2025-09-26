import 'package:flutter/material.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

class DynamicTextField extends StatefulWidget {
  final DynamicComponent component;
  final Function(String componentId, dynamic value) onChanged;
  final dynamic initialValue;
  final bool hasError;

  const DynamicTextField({
    Key? key,
    required this.component,
    required this.onChanged,
    this.initialValue,
    this.hasError = false,
  }) : super(key: key);

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? widget.component.defaultValue ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.hasError ? Colors.red : Colors.grey.shade300,
          width: widget.hasError ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: widget.hasError ? Colors.red.shade50 : Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.component.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.hasError ? Colors.red.shade700 : Colors.black87,
                  ),
                ),
                if (widget.component.isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Text field
          TextField(
            controller: _controller,
            maxLines: widget.component.maxLines ?? 1,
            decoration: InputDecoration(
              hintText: widget.component.placeholder ?? 'Enter text...',
              hintStyle: TextStyle(
                color: widget.hasError ? Colors.red.shade300 : Colors.grey.shade500,
              ),
              filled: true,
              fillColor: widget.hasError ? Colors.red.shade100 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: widget.hasError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: widget.hasError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: widget.hasError ? Colors.red : Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value) {
              widget.onChanged(widget.component.id, value);
            },
          ),
          
          // Error message
          if (widget.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Required field',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
