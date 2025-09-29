import 'package:flutter/material.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

class DynamicRadioButton extends StatefulWidget {
  final DynamicComponent component;
  final Function(String componentId, dynamic value) onChanged;
  final dynamic initialValue;
  final bool hasError;

  const DynamicRadioButton({
    Key? key,
    required this.component,
    required this.onChanged,
    this.initialValue,
    this.hasError = false,
  }) : super(key: key);

  @override
  State<DynamicRadioButton> createState() => _DynamicRadioButtonState();
}

class _DynamicRadioButtonState extends State<DynamicRadioButton> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue?.toString() ?? widget.component.defaultValue;
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
                return RadioListTile<String>(
                  title: Text(
                    optionData.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.hasError ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  value: optionValue,
                  groupValue: selectedValue,
                  activeColor: widget.hasError ? Colors.red : Theme.of(context).primaryColor,
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onChanged(widget.component.id, value);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
            )
          else if (widget.component.options != null)
            Column(
              children: widget.component.options!.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.hasError ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  value: option,
                  groupValue: selectedValue,
                  activeColor: widget.hasError ? Colors.red : Theme.of(context).primaryColor,
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onChanged(widget.component.id, value);
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