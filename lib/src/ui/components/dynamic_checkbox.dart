import 'package:flutter/material.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

class DynamicCheckbox extends StatefulWidget {
  final DynamicComponent component;
  final Function(String componentId, dynamic value) onChanged;
  final dynamic initialValue;
  final bool hasError;

  const DynamicCheckbox({
    Key? key,
    required this.component,
    required this.onChanged,
    this.initialValue,
    this.hasError = false,
  }) : super(key: key);

  @override
  State<DynamicCheckbox> createState() => _DynamicCheckboxState();
}

class _DynamicCheckboxState extends State<DynamicCheckbox> {
  List<String> selectedValues = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue is List) {
      selectedValues = List<String>.from(widget.initialValue);
    } else if (widget.component.defaultValue != null) {
      selectedValues = [widget.component.defaultValue!];
    }
  }

  void _onChanged(String option, bool? value) {
    setState(() {
      if (value == true) {
        selectedValues.add(option);
      } else {
        selectedValues.remove(option);
      }
    });
    
    widget.onChanged(widget.component.id, selectedValues);
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
          
          // Options
          if (widget.component.optionData != null)
            Column(
              children: widget.component.optionData!.map((optionData) {
                // Use ID if available, otherwise use text
                final optionValue = optionData.id ?? optionData.text;
                return CheckboxListTile(
                  title: Text(
                    optionData.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.hasError ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  value: selectedValues.contains(optionValue),
                  activeColor: widget.hasError ? Colors.red : Theme.of(context).primaryColor,
                  onChanged: (bool? value) {
                    _onChanged(optionValue, value);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
            )
          else if (widget.component.options != null)
            Column(
              children: widget.component.options!.map((option) {
                return CheckboxListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.hasError ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  value: selectedValues.contains(option),
                  activeColor: widget.hasError ? Colors.red : Theme.of(context).primaryColor,
                  onChanged: (bool? value) {
                    _onChanged(option, value);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
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