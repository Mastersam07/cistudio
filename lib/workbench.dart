import 'package:cistudio/src/editor/editor.dart';
import 'package:flutter/material.dart';

import 'src/models/ci_step.dart';
import 'src/editor/export_config_panel.dart';
import 'src/editor/step_settings_panel.dart';
import 'src/editor/steps_panel.dart';

class Workbench extends StatefulWidget {
  const Workbench({super.key});

  @override
  WorkbenchState createState() => WorkbenchState();
}

class WorkbenchState extends State<Workbench> {
  List<CIStep> availableSteps = [
    CIStep(
      name: 'Runs On',
      isCompulsory: true,
      position: 0,
    ),
    CIStep(
      name: 'Trigger Events',
      isCompulsory: true,
      position: 1,
    ),
    CIStep(name: 'Checkout Repo', position: 1, isCompulsory: true),
    CIStep(name: 'Setup SSH', position: 2),
    CIStep(
      name: 'Setup & Cache Flutter',
      position: 2,
      isCompulsory: true,
    ),
    CIStep(name: 'Get Dependencies', position: 3),
    CIStep(name: 'Dart Format', position: 4),
    CIStep(name: 'Lint Check', position: 5),
    CIStep(name: 'Run Tests', position: 6),
    CIStep(name: 'Build android app', position: 7),
    CIStep(name: 'Upload android binary to firebase distribution', position: 8),
    CIStep(name: 'Upload to playstore', position: 9),
    CIStep(name: 'Build ios app', position: 10),
    CIStep(name: 'Upload ios binary to firebase distribution', position: 11),
    CIStep(name: 'Upload to applestore & testflight', position: 12),
    CIStep(name: 'Notify via email', position: 13),
    CIStep(name: 'Notify via slack', position: 14),
  ];

  List<CIStep> selectedSteps = [];

  CIStep? selectedStep;

  void selectStep(CIStep step) {
    setState(() {
      selectedStep = step;
    });
  }

  @override
  void initState() {
    super.initState();
    _addCompulsorySteps();
  }

  void _addCompulsorySteps() {
    // Automatically add compulsory steps to the selectedSteps list
    for (CIStep step in availableSteps) {
      if (step.isCompulsory) {
        selectedSteps.add(step);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StepPanel(availableSteps: availableSteps),
        ),
        Expanded(
          flex: 3,
          child: Editor(
              selectedSteps: selectedSteps,
              selectedStep: selectedStep,
              onTap: (step) => selectStep(step),
              onAccept: (data) {
                setState(() {
                  if (!selectedSteps.contains(data)) {
                    selectedSteps.add(data);
                  }
                });
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = selectedSteps.removeAt(oldIndex);
                  selectedSteps.insert(newIndex, item);
                });
              }),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: StepSettingsPanel(selectedStep: selectedStep),
              ),
              const Divider(height: 2, thickness: 1, color: Colors.grey),
              ExportConfigPanel(selectedSteps: selectedSteps),
            ],
          ),
        ),
      ],
    );
  }
}
