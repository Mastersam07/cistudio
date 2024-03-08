import 'package:flutter/material.dart';
import '../models/ci_step.dart';

class StepSettingsPanel extends StatefulWidget {
  final CIStep? selectedStep;

  const StepSettingsPanel({Key? key, this.selectedStep}) : super(key: key);

  @override
  StepSettingsPanelState createState() => StepSettingsPanelState();
}

class StepSettingsPanelState extends State<StepSettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return widget.selectedStep == null
        ? const Center(child: Text('Select a step to view/edit its settings'))
        : SingleChildScrollView(
            child: Column(
              children: [
                Text('Editing Step: ${widget.selectedStep!.name}'),
                ...widget.selectedStep!.properties.keys
                    .map((property) =>
                        _buildPropertyEditor(widget.selectedStep!, property))
                    .toList(),
              ],
            ),
          );
  }

  Widget _buildPropertyEditor(CIStep step, String property) {
    var propertyValues = step.properties[property]!;
    var defaultValue = step.defaultProperties[property];

    // Determine if the property should use a dropdown or a text field
    bool isDropdown = propertyValues.isNotEmpty;

    // TextEditingController for text field input
    TextEditingController textController =
        TextEditingController(text: defaultValue);
    textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              property,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (isDropdown) ...[
            DropdownButton<dynamic>(
              key: ValueKey('dropdown-$property'),
              value: defaultValue,
              onChanged: (newValue) {
                setState(() {
                  step.defaultProperties[property] = newValue;
                });
              },
              items: propertyValues.map<DropdownMenuItem<dynamic>>((value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              isExpanded: true,
            ),
          ] else ...[
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter $property',
                border: const OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                setState(() {
                  step.defaultProperties[property] = newValue;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
